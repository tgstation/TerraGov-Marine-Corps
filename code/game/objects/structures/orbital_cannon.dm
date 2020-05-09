#define WARHEAD_FLY_TIME 50
#define WARHEAD_FALLING_SOUND_RANGE 15

/obj/structure/orbital_cannon
	name = "\improper Orbital Cannon"
	desc = "The TGMC Orbital Cannon System. Used for shooting large targets on the planet that is orbited. It accelerates its payload with solid fuel for devastating results upon impact."
	icon = 'icons/obj/machines/artillery.dmi'
	icon_state = "OBC_unloaded"
	density = TRUE
	anchored = TRUE
	layer = LADDER_LAYER
	bound_width = 128
	bound_height = 64
	bound_y = 64
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	var/obj/structure/orbital_tray/tray
	var/chambered_tray = FALSE
	var/loaded_tray = FALSE
	var/ob_cannon_busy = FALSE
	var/last_orbital_firing = 0 //stores the last time it was fired to check when we can fire again

/obj/structure/orbital_cannon/Initialize()
	. = ..()
	if(!GLOB.marine_main_ship.orbital_cannon)
		GLOB.marine_main_ship.orbital_cannon = src

	if(!GLOB.marine_main_ship.ob_type_fuel_requirements)
		GLOB.marine_main_ship.ob_type_fuel_requirements = list()
		var/list/L = list(4,5,6)
		var/amt
		for(var/i=1 to 3)
			amt = pick_n_take(L)
			GLOB.marine_main_ship?.ob_type_fuel_requirements += amt

	var/turf/T = locate(x+1,y+2,z)
	var/obj/structure/orbital_tray/O = new(T)
	tray = O
	tray.linked_ob = src


/obj/structure/orbital_cannon/update_icon()
	if(chambered_tray)
		icon_state = "OBC_chambered"
	else
		if(loaded_tray)
			icon_state = "OBC_loaded"
		else
			icon_state = "OBC_unloaded"


/obj/structure/orbital_cannon/proc/load_tray(mob/user)
	set waitfor = 0

	if(!tray)
		return

	if(ob_cannon_busy)
		return

	if(!tray.warhead)
		if(user)
			to_chat(user, "<span class='warning'>No warhead in the tray, loading operation cancelled.</span>")
		return

	if(tray.fuel_amt < 1)
		to_chat(user, "<span class='warning'>No solid fuel in the tray, loading operation cancelled.</span>")
		return

	if(loaded_tray)
		to_chat(user, "<span class='warning'>The tray is already loaded.</span>")
		return

	tray.forceMove(src)

	flick("OBC_loading",src)

	playsound(loc, 'sound/mecha/powerloader_buckle.ogg', 40)

	ob_cannon_busy = TRUE

	sleep(10)

	ob_cannon_busy = FALSE

	loaded_tray = TRUE

	update_icon()




/obj/structure/orbital_cannon/proc/unload_tray(mob/user)
	set waitfor = 0

	if(ob_cannon_busy)
		return

	if(chambered_tray)
		to_chat(user, "<span class='warning'>The tray cannot be unloaded after its chambered, fire the gun first.</span>")
		return

	if(!loaded_tray)
		to_chat(user, "<span class='warning'>The tray is not loaded.</span>")
		return

	flick("OBC_unloading",src)

	playsound(loc, 'sound/mecha/powerloader_unbuckle.ogg', 40)

	ob_cannon_busy = TRUE

	sleep(10)

	ob_cannon_busy = FALSE

	var/turf/T = locate(x+1,y+2,z)

	tray.forceMove(T)
	loaded_tray = FALSE

	update_icon()





/obj/structure/orbital_cannon/proc/chamber_payload(mob/user)
	set waitfor = 0

	if(!loaded_tray)
		to_chat(user, "<span class='warning'>You need to load the tray before chambering it.</span>")
		return

	if(ob_cannon_busy)
		return

	if(chambered_tray)
		return
	if(!tray)
		return
	if(!tray.warhead)
		if(user)
			to_chat(user, "<span class='warning'>No warhead in the tray, cancelling chambering operation.</span>")
		return

	if(tray.fuel_amt < 1)
		if(user)
			to_chat(user, "<span class='warning'>No solid fuel in the tray, cancelling chambering operation.</span>")
		return

	if(last_orbital_firing) //fired at least once
		var/cooldown_left = (last_orbital_firing + 5000) - world.time
		if(cooldown_left > 0)
			if(user)
				to_chat(user, "<span class='warning'>[src]'s barrel is still too hot, let it cool down for [round(cooldown_left/10)] more seconds.</span>")
			return

	flick("OBC_chambering",src)

	playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)

	ob_cannon_busy = TRUE

	sleep(6)

	ob_cannon_busy = FALSE

	chambered_tray = TRUE

	update_icon()

/obj/structure/orbital_cannon/proc/fire_ob_cannon(turf/T, mob/user)
	set waitfor = 0

	if(ob_cannon_busy)
		return

	if(!chambered_tray || !loaded_tray || !tray || !tray.warhead)
		return

	flick("OBC_firing",src)

	ob_cannon_busy = TRUE

	last_orbital_firing = world.time

	playsound(loc, 'sound/weapons/guns/fire/tank_smokelauncher.ogg', 70, 1)
	playsound(loc, 'sound/weapons/guns/fire/pred_plasma_shot.ogg', 70, 1)

	var/inaccurate_fuel = 0

	switch(tray.warhead.warhead_kind)
		if("explosive")
			inaccurate_fuel = abs(GLOB.marine_main_ship?.ob_type_fuel_requirements[1] - tray.fuel_amt)
		if("incendiary")
			inaccurate_fuel = abs(GLOB.marine_main_ship?.ob_type_fuel_requirements[2] - tray.fuel_amt)
		if("cluster")
			inaccurate_fuel = abs(GLOB.marine_main_ship?.ob_type_fuel_requirements[3] - tray.fuel_amt)

	var/turf/target = locate(T.x + inaccurate_fuel * pick(-1,1),T.y + inaccurate_fuel * pick(-1,1),T.z)
	for(var/i in hearers(WARHEAD_FALLING_SOUND_RANGE,target))
		var/mob/M = i
		M.playsound_local(target, 'sound/effects/OB_incoming.ogg', falloff = 2)

	notify_ghosts("<b>[user]</b> has just fired \the <b>[src]</b> !", source = T, action = NOTIFY_JUMP)

	addtimer(CALLBACK(src, /obj/structure/orbital_cannon.proc/impact_callback, target, inaccurate_fuel), WARHEAD_FLY_TIME)

/obj/structure/orbital_cannon/proc/impact_callback(target,inaccurate_fuel)
	tray.warhead.warhead_impact(target, inaccurate_fuel)

	ob_cannon_busy = FALSE
	chambered_tray = FALSE
	tray.fuel_amt = 0
	if(tray.warhead)
		QDEL_NULL(tray.warhead)
	tray.update_icon()

	update_icon()

/obj/structure/orbital_tray
	name = "loading tray"
	desc = "The orbital cannon's loading tray."
	icon = 'icons/Marine/mainship_props64.dmi'
	icon_state = "cannon_tray"
	density = TRUE
	anchored = TRUE
	throwpass = TRUE
	climbable = TRUE
	layer = LADDER_LAYER + 0.01
	bound_width = 64
	bound_height = 32
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	pixel_y = -9
	pixel_x = -6
	var/obj/structure/ob_ammo/warhead/warhead
	var/obj/structure/orbital_cannon/linked_ob
	var/fuel_amt = 0


/obj/structure/orbital_tray/Destroy()
	if(warhead)
		qdel(warhead)
		warhead = null
	if(linked_ob)
		linked_ob.tray = null
		linked_ob = null
	. = ..()


/obj/structure/orbital_tray/update_icon()
	overlays.Cut()
	icon_state = "cannon_tray"
	if(warhead)
		overlays += image("cannon_tray_[warhead.warhead_kind]")
	if(fuel_amt)
		overlays += image("cannon_tray_[fuel_amt]")


/obj/structure/orbital_tray/attackby(obj/item/I, mob/user, params)
	. = ..()


	if(istype(I, /obj/item/powerloader_clamp))
		var/obj/item/powerloader_clamp/PC = I

		if(!PC.linked_powerloader)
			return TRUE

		if(PC.loaded)
			if(!istype(PC.loaded, /obj/structure/ob_ammo))
				return TRUE

			var/obj/structure/ob_ammo/OA = PC.loaded
			if(OA.is_solid_fuel)
				if(fuel_amt >= 6)
					to_chat(user, "<span class='warning'>[src] can't accept more solid fuel.</span>")
					return

				if(!warhead)
					to_chat(user, "<span class='warning'>A warhead must be placed in [src] first.</span>")
					return

				to_chat(user, "<span class='notice'>You load [OA] into [src].</span>")
				playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
				fuel_amt++
				PC.loaded = null
				PC.update_icon()
				qdel(OA)
				update_icon()
			else
				if(warhead)
					to_chat(user, "<span class='warning'>[src] already has a warhead.</span>")
					return

				to_chat(user, "<span class='notice'>You load [OA] into [src].</span>")
				playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
				warhead = OA
				OA.forceMove(src)
				PC.loaded = null
				PC.update_icon()
				update_icon()
		else
			if(fuel_amt)
				var/obj/structure/ob_ammo/ob_fuel/OF = new(PC.linked_powerloader)
				PC.loaded = OF
				fuel_amt--
			else if(warhead)
				warhead.forceMove(PC.linked_powerloader)
				PC.loaded = warhead
				warhead = null
			else
				return TRUE
			PC.update_icon()
			playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
			to_chat(user, "<span class='notice'>You grab [PC.loaded] with [PC].</span>")
			update_icon()

		return TRUE


/obj/structure/ob_ammo
	name = "theoretical ob ammo"
	density = TRUE
	anchored = TRUE
	throwpass = TRUE
	climbable = TRUE
	icon = 'icons/Marine/mainship_props.dmi'
	resistance_flags = XENO_DAMAGEABLE
	coverage = 100
	var/is_solid_fuel = 0

/obj/structure/ob_ammo/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/powerloader_clamp))
		var/obj/item/powerloader_clamp/PC = I
		if(!PC.linked_powerloader)
			return TRUE

		if(PC.loaded)
			return TRUE

		forceMove(PC.linked_powerloader)
		PC.loaded = src
		playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
		PC.update_icon()
		to_chat(user, "<span class='notice'>You grab [PC.loaded] with [PC].</span>")
		update_icon()
		return TRUE

/obj/structure/ob_ammo/examine(mob/user)
	..()
	to_chat(user, "Moving this will require some sort of lifter.")


/obj/structure/ob_ammo/obj_destruction(damage_flag)
	explosion(loc, light_impact_range = 2, flash_range = 3, flame_range = 2)
	return ..()


/obj/structure/ob_ammo/warhead
	name = "theoretical orbital ammo"
	var/warhead_kind


/obj/structure/ob_ammo/warhead/proc/warhead_impact(turf/target, inaccuracy_amt = 0)


/obj/structure/ob_ammo/warhead/explosive
	name = "\improper HE orbital warhead"
	warhead_kind = "explosive"
	icon_state = "ob_warhead_1"

/obj/structure/ob_ammo/warhead/explosive/warhead_impact(turf/target, inaccuracy_amt = 0)
	explosion(target, 5 - inaccuracy_amt, 7 - inaccuracy_amt, 10 - inaccuracy_amt, 11 - inaccuracy_amt)



/obj/structure/ob_ammo/warhead/incendiary
	name = "\improper Incendiary orbital warhead"
	warhead_kind = "incendiary"
	icon_state = "ob_warhead_2"


/obj/structure/ob_ammo/warhead/incendiary/warhead_impact(turf/target, inaccuracy_amt = 0)
	var/range_num = max(15 - inaccuracy_amt, 12)
	flame_radius(range_num, target)


/obj/structure/ob_ammo/warhead/cluster
	name = "\improper Cluster orbital warhead"
	warhead_kind = "cluster"
	icon_state = "ob_warhead_3"

/obj/structure/ob_ammo/warhead/cluster/warhead_impact(turf/target, inaccuracy_amt = 0)
	set waitfor = FALSE

	var/range_num = max(9 - inaccuracy_amt, 6)
	var/list/turf_list = list()
	for(var/turf/T in range(range_num, target))
		turf_list += T
	var/total_amt = max(25 - inaccuracy_amt, 20)
	for(var/i = 1 to total_amt)
		var/turf/U = pick_n_take(turf_list)
		explosion(U, 1, 4, 6, 6, throw_range = 0, adminlog = FALSE) //rocket barrage
		sleep(1)

/obj/structure/ob_ammo/ob_fuel
	name = "solid fuel"
	icon_state = "ob_fuel"
	is_solid_fuel = 1

/obj/structure/ob_ammo/ob_fuel/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)





/obj/machinery/computer/orbital_cannon_console
	name = "\improper Orbital Cannon Console"
	desc = "The console controlling the orbital cannon loading systems."
	icon_state = "ob_console"
	dir = WEST
	flags_atom = ON_BORDER|CONDUCT
	var/orbital_window_page = 0



/obj/machinery/computer/orbital_cannon_console/ex_act()
	return


/obj/machinery/computer/orbital_cannon_console/interact(mob/user)
	. = ..()
	if(.)
		return

	if(user.skills.getRating("engineer") < SKILL_ENGINEER_ENGI)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to use the console.</span>",
		"<span class='notice'>You fumble around figuring out how to use the console.</span>")
		var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating("engineer") )
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
			return

	var/dat
	if(!GLOB.marine_main_ship?.orbital_cannon)
		dat += "No Orbital Cannon System Detected!<BR>"
	else if(!GLOB.marine_main_ship.orbital_cannon.tray)
		dat += "Orbital Cannon System Tray is missing!<BR>"
	else
		if(orbital_window_page == 1)
			dat += "<font size=3>Warhead Fuel Requirements:</font><BR>"
			dat += "- HE Orbital Warhead: <b>[GLOB.marine_main_ship.ob_type_fuel_requirements[1]] Solid Fuel blocks.</b><BR>"
			dat += "- Incendiary Orbital Warhead: <b>[GLOB.marine_main_ship.ob_type_fuel_requirements[2]] Solid Fuel blocks.</b><BR>"
			dat += "- Cluster Orbital Warhead: <b>[GLOB.marine_main_ship?.ob_type_fuel_requirements[3]] Solid Fuel blocks.</b><BR>"

			dat += "<BR><BR><A href='?src=\ref[src];back=1'><font size=3>Back</font></A><BR>"
		else
			var/tray_status = "unloaded"
			if(GLOB.marine_main_ship.orbital_cannon.chambered_tray)
				tray_status = "chambered"
			else if(GLOB.marine_main_ship.orbital_cannon.loaded_tray)
				tray_status = "loaded"
			dat += "Orbital Cannon Tray is <b>[tray_status]</b><BR>"
			if(GLOB.marine_main_ship.orbital_cannon.tray.warhead)
				dat += "[GLOB.marine_main_ship.orbital_cannon.tray.warhead.name] Detected<BR>"
			else
				dat += "No Warhead Detected<BR>"
			dat += "[GLOB.marine_main_ship.orbital_cannon.tray.fuel_amt] Solid Fuel Block\s Detected<BR><HR>"

			dat += "<A href='?src=\ref[src];load_tray=1'><font size=3>Load Tray</font></A><BR>"
			dat += "<A href='?src=\ref[src];unload_tray=1'><font size=3>Unload Tray</font></A><BR>"
			dat += "<A href='?src=\ref[src];chamber_tray=1'><font size=3>Chamber Tray Payload</font></A><BR>"
			dat += "<BR><A href='?src=\ref[src];check_req=1'><font size=3>Check Fuel Requirements</font></A><BR>"

		dat += "<HR><BR><A href='?src=\ref[src];close=1'><font size=3>Close</font></A><BR>"


	var/datum/browser/popup = new(user, "orbital_console", "<div align='center'>Orbital Cannon System Control Console</div>", 500, 350)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/orbital_cannon_console/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["load_tray"])
		GLOB.marine_main_ship?.orbital_cannon?.load_tray(usr)

	else if(href_list["unload_tray"])
		GLOB.marine_main_ship?.orbital_cannon?.unload_tray(usr)

	else if(href_list["chamber_tray"])
		GLOB.marine_main_ship?.orbital_cannon?.chamber_payload(usr)

	else if(href_list["check_req"])
		orbital_window_page = 1

	else if(href_list["back"])
		orbital_window_page = 0

	updateUsrDialog()


/obj/structure/ship_rail_gun
	name = "\improper Rail Gun"
	desc = "A powerful ship-to-ship weapon sometimes used for ground support at reduced efficiency."
	icon = 'icons/obj/machines/artillery.dmi'
	icon_state = "Railgun"
	density = TRUE
	anchored = TRUE
	layer = LADDER_LAYER
	bound_width = 128
	bound_height = 64
	bound_y = 64
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	var/cannon_busy = FALSE
	var/last_firing = 0 //stores the last time it was fired to check when we can fire again
	var/obj/structure/ship_ammo/heavygun/highvelocity/rail_gun_ammo

/obj/structure/ship_rail_gun/Initialize()
	. = ..()
	if(!GLOB.marine_main_ship.rail_gun)
		GLOB.marine_main_ship.rail_gun = src
	rail_gun_ammo = new /obj/structure/ship_ammo/heavygun/highvelocity(src)
	rail_gun_ammo.max_ammo_count = 8000 //200 uses or 15 full minutes of firing.
	rail_gun_ammo.ammo_count = 8000

/obj/structure/ship_rail_gun/proc/fire_rail_gun(turf/T, mob/user)
	set waitfor = 0
	if(cannon_busy)
		return
	if(!rail_gun_ammo?.ammo_count)
		to_chat(user, "<span class='warning'>[src] has ran out of ammo.</span>")
		return
	flick("Railgun_firing",src)
	cannon_busy = TRUE
	last_firing = world.time
	playsound(loc, 'sound/weapons/guns/fire/tank_smokelauncher.ogg', 70, 1)
	playsound(loc, 'sound/weapons/guns/fire/pred_plasma_shot.ogg', 70, 1)
	var/turf/target = locate(T.x + pick(-2,2), T.y + pick(-2,2), T.z)
	sleep(15)
	rail_gun_ammo.detonate_on(target)
	rail_gun_ammo.ammo_count = max(0, rail_gun_ammo.ammo_count - rail_gun_ammo.ammo_used_per_firing)
	cannon_busy = FALSE
