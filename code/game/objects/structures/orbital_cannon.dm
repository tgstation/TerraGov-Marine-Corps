#define WARHEAD_FLY_TIME 1 SECONDS
#define RG_FLY_TIME 1 SECONDS
#define WARHEAD_FALLING_SOUND_RANGE 15
#define WARHEAD_FUEL_REQUIREMENT 6
GLOBAL_DATUM(orbital_cannon, /obj/structure/orbital_cannon)
GLOBAL_DATUM(rail_gun, /obj/structure/ship_rail_gun)

/obj/structure/orbital_cannon
	name = "\improper Orbital Cannon"
	desc = "The TGMC Orbital Cannon System. Used for shooting large targets on the planet that is orbited. It accelerates its payload with solid fuel for devastating results upon impact."
	icon = 'icons/obj/machines/artillery.dmi'
	icon_state = "OBC_unloaded"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	bound_width = 128
	bound_height = 64
	bound_y = 64
	resistance_flags = RESIST_ALL
	allow_pass_flags = NONE
	var/obj/structure/orbital_tray/tray
	var/chambered_tray = FALSE
	var/loaded_tray = FALSE
	var/ob_cannon_busy = FALSE

/obj/structure/orbital_cannon/Initialize(mapload)
	. = ..()
	if(!GLOB.orbital_cannon)
		GLOB.orbital_cannon = src

	var/turf/T = locate(x+1,y+1,z)
	var/obj/structure/orbital_tray/O = new(T)
	tray = O
	tray.linked_ob = src

/obj/structure/orbital_cannon/Destroy()
	if(tray)
		tray.linked_ob = null
		tray = null
	if(GLOB.orbital_cannon == src)
		GLOB.orbital_cannon = null
	QDEL_NULL(tray)
	return ..()

/obj/structure/orbital_cannon/update_icon_state()
	. = ..()
	if(chambered_tray)
		icon_state = "OBC_chambered"
		return
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
			to_chat(user, span_warning("No warhead in the tray, loading operation cancelled."))
		return

	if(tray.fuel_amt < 1)
		to_chat(user, span_warning("No solid fuel in the tray, loading operation cancelled."))
		return

	if(loaded_tray)
		to_chat(user, span_warning("The tray is already loaded."))
		return

	tray.forceMove(src)

	flick("OBC_loading",src)

	playsound(loc, 'sound/mecha/powerloader_buckle.ogg', 40)

	ob_cannon_busy = TRUE

	sleep(1 SECONDS)

	ob_cannon_busy = FALSE

	loaded_tray = TRUE

	update_icon()




/obj/structure/orbital_cannon/proc/unload_tray(mob/user)
	set waitfor = 0

	if(ob_cannon_busy)
		return

	if(chambered_tray)
		to_chat(user, span_warning("The tray cannot be unloaded after its chambered, fire the gun first."))
		return

	if(!loaded_tray)
		to_chat(user, span_warning("The tray is not loaded."))
		return

	flick("OBC_unloading",src)

	playsound(loc, 'sound/mecha/powerloader_unbuckle.ogg', 40)

	ob_cannon_busy = TRUE

	sleep(1 SECONDS)

	ob_cannon_busy = FALSE

	var/turf/T = locate(x+1,y+1,z)

	tray.forceMove(T)
	loaded_tray = FALSE

	update_icon()





/obj/structure/orbital_cannon/proc/chamber_payload(mob/user)
	set waitfor = 0

	if(!loaded_tray)
		to_chat(user, span_warning("You need to load the tray before chambering it."))
		return

	if(ob_cannon_busy)
		return

	if(chambered_tray)
		return
	if(!tray)
		return
	if(!tray.warhead)
		if(user)
			to_chat(user, span_warning("No warhead in the tray, cancelling chambering operation."))
		return

	if(tray.fuel_amt < 1)
		if(user)
			to_chat(user, span_warning("No solid fuel in the tray, cancelling chambering operation."))
		return

	flick("OBC_chambering",src)

	playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)

	ob_cannon_busy = TRUE

	sleep(0.6 SECONDS)

	ob_cannon_busy = FALSE

	chambered_tray = TRUE

	update_icon()

/// Handles the playing of the Orbital Bombardment incoming sound and other visual and auditory effects of the cannon, usually a spiraling whistle noise but can be overridden.
/obj/structure/orbital_cannon/proc/handle_ob_firing_effects(turf/target, ob_sound = 'sound/effects/OB_incoming.ogg')
	flick("OBC_firing",src)
	playsound(loc, 'sound/effects/obfire.ogg', 100, FALSE, 20, 4)
	new /obj/effect/temp_visual/ob_impact(target, tray.warhead)

	for(var/mob/living/current_mob AS in GLOB.mob_living_list)
		if(current_mob.z == z)
			if(get_dist(src, current_mob) > 20)
				current_mob.playsound_local(current_mob, 'sound/effects/obalarm.ogg', 25)
			shake_camera(current_mob, 0.7 SECONDS)
			to_chat(current_mob, span_warning("The deck of the [SSmapping.configs[SHIP_MAP].map_name] shudders as her orbital cannon opens fire."))
			continue
		if(current_mob.z != target.z)
			continue
		if(get_dist(current_mob, target) > WARHEAD_FALLING_SOUND_RANGE)
			continue
		current_mob.playsound_local(target, ob_sound, falloff = 2)

/obj/structure/orbital_cannon/proc/fire_ob_cannon(turf/T, mob/user)
	set waitfor = FALSE

	if(ob_cannon_busy)
		return

	if(!chambered_tray || !loaded_tray || !tray || !tray.warhead)
		return

	ob_cannon_busy = TRUE

	var/inaccurate_fuel = 0
	inaccurate_fuel = abs(WARHEAD_FUEL_REQUIREMENT - tray.fuel_amt)

	// Give marines a warning if misfuelled.
	var/fuel_warning = "Warhead fuel level: safe."
	if(inaccurate_fuel > 0)
		fuel_warning = "Warhead fuel level: incorrect.<br>Warhead may be inaccurate."

	var/turf/target = locate(T.x + inaccurate_fuel * pick(-1,1),T.y + inaccurate_fuel * pick(-1,1),T.z)
	GLOB.round_statistics.obs_fired++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "obs_fired")
	priority_announce(
		message = "Evacuate the impact zone immediately!<br><br>Warhead type: [tray.warhead.warhead_kind].<br>[fuel_warning]<br>Estimated location of impact: [get_area(T)].",
		title = "Orbital bombardment launch command detected!",
		type = ANNOUNCEMENT_PRIORITY,
		sound = 'sound/effects/OB_warning_announce.ogg',
		channel_override = SSsounds.random_available_channel(), // This way, we can't have it be cut off by other sounds.
		color_override = "red"
	)
	var/list/receivers = (GLOB.alive_human_list + GLOB.ai_list + GLOB.observer_list)
	for(var/mob/living/screentext_receiver AS in receivers)
		screentext_receiver.play_screen_text(HUD_ANNOUNCEMENT_FORMATTING("ORBITAL STRIKE IMMINENT", "TYPE: [uppertext(tray.warhead.warhead_kind)]", LEFT_ALIGN_TEXT), new /atom/movable/screen/text/screen_text/picture/potrait/custom_mugshot(null, null, user))
	playsound(target, 'sound/effects/OB_warning_announce_novoiceover.ogg', 125, FALSE, 30, 10) //VOX-less version for xenomorphs

	var/impact_time = 10 SECONDS + (WARHEAD_FLY_TIME * (GLOB.current_orbit/3))

	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/orbital_cannon, handle_ob_firing_effects), target), impact_time - (0.5 SECONDS))
	var/impact_timerid = addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/orbital_cannon, impact_callback), target, inaccurate_fuel), impact_time, TIMER_STOPPABLE)

	var/canceltext = "Warhead: [tray.warhead.warhead_kind]. Impact at [ADMIN_VERBOSEJMP(target)] <a href='byond://?_src_=holder;[HrefToken(TRUE)];cancelob=[impact_timerid]'>\[CANCEL OB\]</a>"
	message_admins("[span_prefix("OB FIRED:")] <span class='message linkify'> [canceltext]</span>")
	log_game("OB fired by [user] at [AREACOORD(src)], OB type: [tray.warhead.warhead_kind], timerid to cancel: [impact_timerid]")
	notify_ghosts("<b>[user]</b> has just fired \the <b>[src]</b> !", source = T, action = NOTIFY_JUMP)


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
	icon = 'icons/obj/structures/prop/mainship_64.dmi'
	icon_state = "cannon_tray"
	density = TRUE
	anchored = TRUE
	climbable = TRUE
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	layer = BELOW_OBJ_LAYER + 0.01
	bound_width = 64
	bound_height = 32
	resistance_flags = RESIST_ALL
	pixel_y = -9
	pixel_x = -6
	var/obj/structure/ob_ammo/warhead/warhead
	var/obj/structure/orbital_cannon/linked_ob
	var/fuel_amt = 0


/obj/structure/orbital_tray/Destroy()
	QDEL_NULL(warhead)
	if(linked_ob)
		linked_ob.tray = null
		linked_ob = null
	return ..()


/obj/structure/orbital_tray/update_overlays()
	. = ..()
	if(warhead)
		. += image("cannon_tray_[warhead.warhead_kind]")
	if(fuel_amt)
		. += image("cannon_tray_[fuel_amt]")

//Not calling parent because this isn't the typical pick up/put down
/obj/structure/orbital_tray/attack_powerloader(mob/living/user, obj/item/powerloader_clamp/attached_clamp)
	if(attached_clamp.loaded && istype(attached_clamp.loaded, /obj/structure/ob_ammo))
		var/obj/structure/ob_ammo/OA = attached_clamp.loaded

		if(OA.is_solid_fuel)
			if(fuel_amt >= 6)
				to_chat(user, span_warning("[src] can't accept more solid fuel."))
				return

			if(!warhead)
				to_chat(user, span_warning("A warhead must be placed in [src] first."))
				return
			fuel_amt++
			qdel(OA)
		else
			if(warhead)
				to_chat(user, span_warning("[src] already has a warhead."))
				return
			warhead = OA

		to_chat(user, span_notice("You load [OA] into [src]."))
		playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)

		if(!QDELETED(OA))
			OA.forceMove(src)

		attached_clamp.loaded = null
		attached_clamp.update_icon()
		update_icon()
		return

	if(fuel_amt)
		var/obj/structure/ob_ammo/ob_fuel/OF = new(attached_clamp.linked_powerloader)
		attached_clamp.loaded = OF
		fuel_amt--
	else if(warhead)
		warhead.forceMove(attached_clamp.linked_powerloader)
		attached_clamp.loaded = warhead
		warhead = null

	attached_clamp.update_icon()
	playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
	to_chat(user, span_notice("You grab [attached_clamp.loaded] with [attached_clamp]."))
	update_icon()


/obj/structure/ob_ammo
	name = "theoretical ob ammo"
	density = TRUE
	anchored = TRUE
	climbable = TRUE
	icon = 'icons/obj/structures/prop/mainship.dmi'
	resistance_flags = XENO_DAMAGEABLE
	interaction_flags = INTERACT_OBJ_DEFAULT|INTERACT_POWERLOADER_PICKUP_ALLOWED_BYPASS_ANCHOR
	coverage = 100
	var/is_solid_fuel = 0

/obj/structure/ob_ammo/examine(mob/user)
	. = ..()
	. += "Moving this will require some sort of lifter."


/obj/structure/ob_ammo/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	explosion(loc, light_impact_range = 2, flash_range = 3, flame_range = 2, explosion_cause=blame_mob)
	return ..()


/obj/structure/ob_ammo/warhead
	name = "theoretical orbital ammo"
	var/warhead_kind

///Explode the warhead
/obj/structure/ob_ammo/warhead/proc/warhead_impact()
	return

/obj/structure/ob_ammo/warhead/explosive
	name = "\improper HE orbital warhead"
	warhead_kind = "explosive"
	icon_state = "ob_warhead_1"

/obj/structure/ob_ammo/warhead/explosive/warhead_impact(turf/target, inaccuracy_amt = 0)
	. = ..()
	explosion(target, 15 - inaccuracy_amt, 15 - inaccuracy_amt, 15 - inaccuracy_amt, 0, 15 - inaccuracy_amt, explosion_cause=src)



/obj/structure/ob_ammo/warhead/incendiary
	name = "\improper Incendiary orbital warhead"
	warhead_kind = "incendiary"
	icon_state = "ob_warhead_2"


/obj/structure/ob_ammo/warhead/incendiary/warhead_impact(turf/target, inaccuracy_amt = 0)
	. = ..()
	var/range_num = max(15 - inaccuracy_amt, 12)
	flame_radius(range_num, target,	burn_intensity = 46, burn_duration = 40, colour = "blue")
	var/datum/effect_system/smoke_spread/phosphorus/warcrime = new
	warcrime.set_up(17, target, 20)
	warcrime.start()

/obj/structure/ob_ammo/warhead/cluster
	name = "\improper Cluster orbital warhead"
	warhead_kind = "cluster"
	icon_state = "ob_warhead_3"

/obj/structure/ob_ammo/warhead/cluster/warhead_impact(turf/target, inaccuracy_amt = 0)
	set waitfor = FALSE
	. = ..()
	var/range_num = max(9 - inaccuracy_amt, 6)
	var/list/turf_list = RANGE_TURFS(range_num, target)
	var/total_amt = max(25 - inaccuracy_amt, 20)
	for(var/i = 1 to total_amt)
		var/turf/U = pick_n_take(turf_list)
		explosion(U, 2, 4, 6, 0, 6, throw_range = 0, explosion_cause=src)
		sleep(0.1 SECONDS)

/obj/structure/ob_ammo/warhead/plasmaloss
	name = "\improper Plasma draining orbital warhead"
	warhead_kind = "plasma"
	icon_state = "ob_warhead_4"


/obj/structure/ob_ammo/warhead/plasmaloss/warhead_impact(turf/target, inaccuracy_amt = 0)
	. = ..()
	var/datum/effect_system/smoke_spread/plasmaloss/smoke = new
	smoke.set_up(25, target, 30 - (inaccuracy_amt * 2))//Vape nation
	smoke.start()

/obj/structure/ob_ammo/ob_fuel
	name = "solid fuel"
	icon_state = "ob_fuel"
	is_solid_fuel = TRUE

/obj/structure/ob_ammo/ob_fuel/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)





/obj/machinery/computer/orbital_cannon_console
	name = "\improper Orbital Cannon Console"
	desc = "The console controlling the orbital cannon loading systems."
	icon_state = "ob_console"
	screen_overlay = "ob_console_screen"
	dir = WEST
	layer = LOW_ITEM_LAYER
	atom_flags = ON_BORDER|CONDUCT
	var/orbital_window_page = 0

/obj/machinery/computer/orbital_cannon_console/Initialize(mapload)
	. = ..()

	var/static/list/connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_try_exit)
	)
	AddElement(/datum/element/connect_loc, connections)


/obj/machinery/computer/orbital_cannon_console/ex_act()
	return


/obj/machinery/computer/orbital_cannon_console/interact(mob/user)
	. = ..()
	if(.)
		return

	if(!allowed(user))
		return

	if(!isobserver(user) && user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use the console."),
		span_notice("You fumble around figuring out how to use the console."))
		var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return

	var/dat
	if(!GLOB.orbital_cannon)
		dat += "No Orbital Cannon System Detected!<BR>"
	else if(!GLOB.orbital_cannon.tray)
		dat += "Orbital Cannon System Tray is missing!<BR>"
	else
		if(orbital_window_page == 1)
			dat += "<font size=3>Warhead Fuel Requirements:</font><BR>"
			dat += "All orbital warheads require <b>[WARHEAD_FUEL_REQUIREMENT] Solid Fuel blocks.</b><BR>"

			dat += "<BR><BR><A href='byond://?src=[text_ref(src)];back=1'><font size=3>Back</font></A><BR>"
		else
			var/tray_status = "unloaded"
			if(GLOB.orbital_cannon.chambered_tray)
				tray_status = "chambered"
			else if(GLOB.orbital_cannon.loaded_tray)
				tray_status = "loaded"
			dat += "Orbital Cannon Tray is <b>[tray_status]</b><BR>"
			if(GLOB.orbital_cannon.tray.warhead)
				dat += "[GLOB.orbital_cannon.tray.warhead.name] Detected<BR>"
			else
				dat += "No Warhead Detected<BR>"
			dat += "[GLOB.orbital_cannon.tray.fuel_amt] Solid Fuel Block\s Detected<BR><HR>"

			dat += "<A href='byond://?src=[text_ref(src)];load_tray=1'><font size=3>Load Tray</font></A><BR>"
			dat += "<A href='byond://?src=[text_ref(src)];unload_tray=1'><font size=3>Unload Tray</font></A><BR>"
			dat += "<A href='byond://?src=[text_ref(src)];chamber_tray=1'><font size=3>Chamber Tray Payload</font></A><BR>"
			dat += "<BR><A href='byond://?src=[text_ref(src)];check_req=1'><font size=3>Check Fuel Requirements</font></A><BR>"

		dat += "<HR><BR><A href='byond://?src=[text_ref(src)];close=1'><font size=3>Close</font></A><BR>"


	var/datum/browser/popup = new(user, "orbital_console", "<div align='center'>Orbital Cannon System Control Console</div>", 500, 350)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/orbital_cannon_console/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["load_tray"])
		GLOB.orbital_cannon?.load_tray(usr)

	else if(href_list["unload_tray"])
		GLOB.orbital_cannon?.unload_tray(usr)

	else if(href_list["chamber_tray"])
		GLOB.orbital_cannon?.chamber_payload(usr)

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
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	layer = BELOW_OBJ_LAYER
	bound_width = 128
	bound_height = 64
	bound_y = 64
	resistance_flags = RESIST_ALL
	var/cannon_busy = FALSE
	var/last_firing = 0 //stores the last time it was fired to check when we can fire again
	var/last_firing_ai = 0 //same thing as last_firing but only cares when the AI last fired
	var/obj/structure/ship_ammo/railgun/rail_gun_ammo

/obj/structure/ship_rail_gun/Initialize(mapload)
	. = ..()
	if(!GLOB.rail_gun)
		GLOB.rail_gun = src
	rail_gun_ammo = new /obj/structure/ship_ammo/railgun(src)
	rail_gun_ammo.max_ammo_count = 8000 //200 uses or 15 full minutes of firing.
	rail_gun_ammo.ammo_count = 8000

/obj/structure/ship_rail_gun/Destroy()
	if(GLOB.rail_gun == src)
		GLOB.rail_gun = null
	QDEL_NULL(rail_gun_ammo)
	return ..()

/obj/structure/ship_rail_gun/proc/fire_rail_gun(turf/T, mob/user, ignore_cooldown = FALSE, ai_operation = FALSE)
	if(cannon_busy && !ignore_cooldown)
		return
	if(!rail_gun_ammo?.ammo_count)
		to_chat(user, span_warning("[src] has ran out of ammo."))
		return
	flick("Railgun_firing",src)
	cannon_busy = TRUE
	if(ai_operation)
		last_firing_ai = world.time
	else
		last_firing = world.time
	playsound(loc, 'sound/weapons/guns/fire/tank_smokelauncher.ogg', 70, 1)
	playsound(loc, 'sound/weapons/guns/fire/pred_plasma_shot.ogg', 70, 1)
	var/turf/target = locate(T.x + rand(-4, 4), T.y + rand(-4, 4), T.z)
	for(var/mob/living/silicon/ai/AI AS in GLOB.ai_list)
		to_chat(AI, span_notice("NOTICE - \The [src] has fired."))
	rail_gun_ammo.ammo_count = max(0, rail_gun_ammo.ammo_count - rail_gun_ammo.ammo_used_per_firing)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/ship_rail_gun, impact_rail_gun), target), 1 SECONDS + (RG_FLY_TIME * (GLOB.current_orbit/3)))

/obj/structure/ship_rail_gun/proc/impact_rail_gun(turf/T)
	rail_gun_ammo.detonate_on(T)
	cannon_busy = FALSE
