

//global vars
var/obj/structure/orbital_cannon/almayer_orbital_cannon
var/list/ob_type_fuel_requirements

/obj/structure/orbital_cannon
	name = "\improper Orbital Cannon"
	desc = "The USCM Orbital Cannon System. Used for shooting large targets on the planet that is orbited. It accelerates its payload with solid fuel for devastating results upon impact."
	icon = 'icons/effects/128x128.dmi'
	icon_state = "OBC_unloaded"
	density = 1
	anchored = 1
	layer = LADDER_LAYER
	bound_width = 128
	bound_height = 64
	bound_y = 64
	unacidable = TRUE
	var/obj/structure/orbital_tray/tray
	var/chambered_tray = FALSE
	var/loaded_tray = FALSE
	var/ob_cannon_busy = FALSE
	var/last_orbital_firing = 0 //stores the last time it was fired to check when we can fire again

/obj/structure/orbital_cannon/New()
	..()
	if(!almayer_orbital_cannon)
		almayer_orbital_cannon = src

	if(!ob_type_fuel_requirements)
		ob_type_fuel_requirements = list()
		var/list/L = list(4,5,6)
		var/amt
		for(var/i=1 to 3)
			amt = pick_n_take(L)
			ob_type_fuel_requirements += amt

	var/turf/T = locate(x+1,y+2,z)
	var/obj/structure/orbital_tray/O = new(T)
	tray = O
	tray.linked_ob = src



/obj/structure/orbital_cannon/ex_act()
	return

/obj/structure/orbital_cannon/bullet_act()
	return



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
			user << "no warhead in the tray, loading operation cancelled."
		return

	if(tray.fuel_amt < 1)
		user << "no solid fuel in the tray, loading operation cancelled."
		return

	if(loaded_tray)
		user << "Tray is already loaded."
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
		user << "Tray cannot be unloaded after its chambered, fire the gun first."
		return

	if(!loaded_tray)
		user << "No loaded tray to unload."
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

	if(ob_cannon_busy)
		return

	if(chambered_tray)
		return
	if(!tray)
		return
	if(!tray.warhead)
		if(user)
			user << "<span class='warning'>no warhead in the tray, cancelling chambering operation.</span>"
		return

	if(tray.fuel_amt < 1)
		if(user)
			user << "<span class='warning'>no solid fuel in the tray, cancelling chambering operation.</span>"
		return

	if(last_orbital_firing) //fired at least once
		var/cooldown_left = (last_orbital_firing + 5000) - world.time
		if(cooldown_left > 0)
			if(user)
				user << "<span class='warning'>[src]'s barrel is still too hot, let it cool down for [round(cooldown_left/10)] more seconds.</span>"
			return

	flick("OBC_chambering",src)

	playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)

	ob_cannon_busy = TRUE

	sleep(6)

	ob_cannon_busy = FALSE

	chambered_tray = TRUE

	update_icon()




/obj/structure/orbital_cannon/proc/fire_ob_cannon(turf/T, mob/user, x_offset, y_offset)
	set waitfor = 0

	if(ob_cannon_busy)
		return

	if(!chambered_tray || !loaded_tray || !tray || !tray.warhead)
		return

	flick("OBC_firing",src)

	ob_cannon_busy = TRUE

	last_orbital_firing = world.time

	playsound(loc, 'sound/weapons/tank_smokelauncher_fire.ogg', 70, 1)
	playsound(loc, 'sound/weapons/pred_plasma_shot.ogg', 70, 1)

	var/inaccurate_fuel = 0

	switch(tray.warhead.warhead_kind)
		if("explosive")
			inaccurate_fuel = abs(ob_type_fuel_requirements[1] - tray.fuel_amt)
		if("incendiary")
			inaccurate_fuel = abs(ob_type_fuel_requirements[2] - tray.fuel_amt)
		if("cluster")
			inaccurate_fuel = abs(ob_type_fuel_requirements[3] - tray.fuel_amt)

	var/turf/target = locate(T.x + inaccurate_fuel * pick(-1,1),T.y + inaccurate_fuel * pick(-1,1),T.z)

	tray.warhead.warhead_impact(target, inaccurate_fuel)

	sleep(11)

	ob_cannon_busy = FALSE

	chambered_tray = FALSE
	tray.fuel_amt = 0
	if(tray.warhead)
		cdel(tray.warhead)
		tray.warhead = null
	tray.update_icon()

	update_icon()




/obj/structure/orbital_tray
	name = "loading tray"
	desc = "The orbital cannon's loading tray."
	icon = 'icons/Marine/almayer_props64.dmi'
	icon_state = "cannon_tray"
	density = 1
	anchored = 1
	throwpass = TRUE
	climbable = TRUE
	layer = LADDER_LAYER + 0.01
	bound_width = 64
	bound_height = 32
	unacidable = TRUE
	pixel_y = -9
	pixel_x = -6
	var/obj/structure/ob_ammo/warhead/warhead
	var/obj/structure/orbital_cannon/linked_ob
	var/fuel_amt = 0


/obj/structure/orbital_tray/Dispose()
	if(warhead)
		cdel(warhead)
		warhead = null
	if(linked_ob)
		linked_ob.tray = null
		linked_ob = null
	. = ..()


/obj/structure/orbital_tray/ex_act()
	return

/obj/structure/orbital_tray/bullet_act()
	return


/obj/structure/orbital_tray/update_icon()
	overlays.Cut()
	icon_state = "cannon_tray"
	if(warhead)
		overlays += image("cannon_tray_[warhead.warhead_kind]")
	if(fuel_amt)
		overlays += image("cannon_tray_[fuel_amt]")


/obj/structure/orbital_tray/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/powerloader_clamp))
		var/obj/item/powerloader_clamp/PC = I
		if(PC.linked_powerloader)
			if(PC.loaded)
				if(istype(PC.loaded, /obj/structure/ob_ammo))
					var/obj/structure/ob_ammo/OA = PC.loaded
					if(OA.is_solid_fuel)
						if(fuel_amt >= 6)
							user << "<span class='warning'>[src] can't accept more solid fuel.</span>"
						else if(!warhead)
							user << "<span class='warning'>A warhead must be placed in [src] first.</span>"
						else
							user << "<span class='notice'>You load [OA] into [src].</span>"
							playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
							fuel_amt++
							PC.loaded = null
							PC.update_icon()
							cdel(OA)
							update_icon()
					else
						if(warhead)
							user << "<span class='warning'>[src] already has a warhead.</span>"
						else
							user << "<span class='notice'>You load [OA] into [src].</span>"
							playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
							warhead = OA
							OA.forceMove(src)
							PC.loaded = null
							PC.update_icon()
							update_icon()

			else

				if(fuel_amt)
					var/obj/structure/ob_ammo/ob_fuel/OF = new (PC.linked_powerloader)
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
				user << "<span class='notice'>You grab [PC.loaded] with [PC].</span>"
				update_icon()
		return TRUE
	else
		. = ..()




/obj/structure/ob_ammo
	name = "theoretical ob ammo"
	density = 1
	anchored = 1
	throwpass = TRUE
	climbable = TRUE
	icon = 'icons/Marine/almayer_props.dmi'
	var/is_solid_fuel = 0

/obj/structure/ob_ammo/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/powerloader_clamp))
		var/obj/item/powerloader_clamp/PC = I
		if(PC.linked_powerloader)
			if(!PC.loaded)
				forceMove(PC.linked_powerloader)
				PC.loaded = src
				playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
				PC.update_icon()
				user << "<span class='notice'>You grab [PC.loaded] with [PC].</span>"
				update_icon()
		return TRUE
	else
		. = ..()

/obj/structure/ob_ammo/examine(mob/user)
	..()
	user << "Moving this will require some sort of lifter."


/obj/structure/ob_ammo/warhead
	name = "theoretical orbital ammo"
	var/warhead_kind


/obj/structure/ob_ammo/warhead/proc/warhead_impact(turf/target, inaccuracy_amt = 0)


/obj/structure/ob_ammo/warhead/explosive
	name = "\improper HE orbital warhead"
	warhead_kind = "explosive"
	icon_state = "ob_warhead_1"

/obj/structure/ob_ammo/warhead/explosive/warhead_impact(turf/target, inaccuracy_amt = 0)
	var/reduc = min(inaccuracy_amt*3, 5)
	explosion(target,5 - reduc,7 - reduc,10 - reduc,12 - reduc,1,0) //massive boom



/obj/structure/ob_ammo/warhead/incendiary
	name = "\improper Incendiary orbital warhead"
	warhead_kind = "incendiary"
	icon_state = "ob_warhead_2"

/obj/structure/ob_ammo/warhead/incendiary/warhead_impact(turf/target, inaccuracy_amt = 0)
	var/range_num = max(8 - inaccuracy_amt*2, 3)
	for(var/turf/TU in range(range_num,target))
		if(!locate(/obj/flamer_fire) in TU)
			new/obj/flamer_fire(TU, 10, 50) //super hot flames


/obj/structure/ob_ammo/warhead/cluster
	name = "\improper Cluster orbital warhead"
	warhead_kind = "cluster"
	icon_state = "ob_warhead_3"

/obj/structure/ob_ammo/warhead/cluster/warhead_impact(turf/target, inaccuracy_amt = 0)
	set waitfor = 0

	var/range_num = max(8 - inaccuracy_amt*2, 3)
	var/list/turf_list = list()
	for(var/turf/T in range(range_num,target))
		turf_list += T
	var/total_amt = max(8 - inaccuracy_amt*3, 2)
	for(var/i = 1 to total_amt)
		var/turf/U = pick_n_take(turf_list)
		explosion(U,1,3,5,6,1,0) //rocket barrage
		sleep(1)




/obj/structure/ob_ammo/ob_fuel
	name = "solid fuel"
	icon_state = "ob_fuel"
	is_solid_fuel = 1

/obj/structure/ob_ammo/ob_fuel/New()
	..()
	pixel_x = rand(-5,5)
	pixel_y = rand(-5,5)





/obj/machinery/computer/orbital_cannon_console
	name = "\improper Orbital Cannon Console"
	desc = "The console controlling the orbital cannon loading systems."
	icon_state = "ob_console"
	dir = WEST
	flags_atom = ON_BORDER|CONDUCT|FPRINT
	var/orbital_window_page = 0



/obj/machinery/computer/orbital_cannon_console/ex_act()
	return

/obj/machinery/computer/orbital_cannon_console/bullet_act()
	return


/obj/machinery/computer/orbital_cannon_console/attack_hand(mob/user)
	if(..())
		return

	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
		user << "<span class='warning'>You have no idea how to use that console.</span>"
		return 1

	user.set_interaction(src)

	var/dat = "<font size=5><center>Orbital Cannon System Control Console</center></font><HR>"
	if(!almayer_orbital_cannon)
		dat += "No Orbital Cannon System Detected!<BR>"
	else if(!almayer_orbital_cannon.tray)
		dat += "Orbital Cannon System Tray is missing!<BR>"
	else
		if(orbital_window_page == 1)
			dat += "<font size=3>Warhead Fuel Requirements:</font><BR>"
			dat += "- HE Orbital Warhead: <b>[ob_type_fuel_requirements[1]] Solid Fuel blocks.</b><BR>"
			dat += "- Incendiary Orbital Warhead: <b>[ob_type_fuel_requirements[2]] Solid Fuel blocks.</b><BR>"
			dat += "- Cluster Orbital Warhead: <b>[ob_type_fuel_requirements[3]] Solid Fuel blocks.</b><BR>"

			dat += "<BR><BR><A href='?src=\ref[src];back=1'><font size=3>Back</font></A><BR>"
		else
			var/tray_status = "unloaded"
			if(almayer_orbital_cannon.chambered_tray)
				tray_status = "chambered"
			else if(almayer_orbital_cannon.loaded_tray)
				tray_status = "loaded"
			dat += "Orbital Cannon Tray is <b>[tray_status]</b><BR>"
			if(almayer_orbital_cannon.tray.warhead)
				dat += "[almayer_orbital_cannon.tray.warhead.name] Detected<BR>"
			else
				dat += "No Warhead Detected<BR>"
			dat += "[almayer_orbital_cannon.tray.fuel_amt] Solid Fuel Block\s Detected<BR><HR>"

			dat += "<A href='?src=\ref[src];load_tray=1'><font size=3>Load Tray</font></A><BR>"
			dat += "<A href='?src=\ref[src];unload_tray=1'><font size=3>Unload Tray</font></A><BR>"
			dat += "<A href='?src=\ref[src];chamber_tray=1'><font size=3>Chamber Tray Payload</font></A><BR>"
			dat += "<BR><A href='?src=\ref[src];check_req=1'><font size=3>Check Fuel Requirements</font></A><BR>"

		dat += "<HR><BR><A href='?src=\ref[src];close=1'><font size=3>Close</font></A><BR>"

	user << browse(dat, "window=orbital_console;size=500x350")
	onclose(user, "orbital_console")


/obj/machinery/computer/orbital_cannon_console/Topic(href, href_list)
	if(..())
		return

	if(href_list["load_tray"])
		almayer_orbital_cannon.load_tray(usr)

	else if(href_list["unload_tray"])
		almayer_orbital_cannon.unload_tray(usr)

	else if(href_list["chamber_tray"])
		almayer_orbital_cannon.chamber_payload(usr)

	else if(href_list["check_req"])
		orbital_window_page = 1

	else if(href_list["back"])
		orbital_window_page = 0

	else if(href_list["close"])
		usr << browse(null, "window=orbital_console")
		usr.unset_interaction()

	add_fingerprint(usr)
//	updateUsrDialog()
	attack_hand(usr)
