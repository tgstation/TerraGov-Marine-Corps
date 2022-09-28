#define DOOR_FLAG_OPEN_ONLY (1 << 0)

/obj/machinery/button
	name = "button"
	desc = "A remote control switch."
	icon = 'icons/obj/machines/buttons.dmi'
	icon_state = "doorctrl"
	power_channel = ENVIRON
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 5
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 100, "rad" = 100, FIRE = 90, ACID = 70)
	var/id = null
	var/next_activate = 0


/obj/machinery/button/indestructible
	resistance_flags = RESIST_ALL


/obj/machinery/button/Initialize(mapload, ndir = 0)
	. = ..()
	setDir(ndir)
	pixel_x = ( (dir & 3) ? 0 : (dir == 4 ? -24 : 24) )
	pixel_y = ( (dir & 3) ? (dir == 1 ? -24 : 24) : 0 )
	update_icon()


/obj/machinery/button/update_icon_state()
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = "[initial(icon_state)]-p"
	else
		icon_state = initial(icon_state)


/obj/machinery/button/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/button/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if((machine_stat & (NOPOWER|BROKEN)))
		return

	if(!allowed(user))
		to_chat(user, span_danger("Access Denied"))
		flick("[initial(icon_state)]-denied", src)
		return

	use_power(active_power_usage)
	icon_state = "[initial(icon_state)]1"

	pulsed()

	addtimer(CALLBACK(src, /atom/movable/.proc/update_icon), 1.5 SECONDS)


/obj/machinery/button/proc/pulsed()
	if(next_activate > world.time)
		return FALSE
	next_activate = world.time + 3 SECONDS
	return TRUE

/obj/machinery/button/door
	name = "door button"
	desc = "A door remote control switch."
	var/specialfunctions = NONE


/obj/machinery/button/door/indestructible
	resistance_flags = RESIST_ALL


/obj/machinery/button/door/pulsed()
	. = ..()
	if(!.)
		return
	var/openclose
	for(var/obj/machinery/door/poddoor/M in GLOB.machines)
		if(M.id != src.id)
			continue
		if(!specialfunctions)
			openclose = M.density
		else if(CHECK_BITFIELD(specialfunctions, DOOR_FLAG_OPEN_ONLY))
			openclose = TRUE
		if(openclose)
			M.open()
			continue
		M.close()


/obj/machinery/button/door/open_only
	name = "open button"
	desc = "Opens whatever it is linked to. Does not close. Careful on what you release."
	specialfunctions = DOOR_FLAG_OPEN_ONLY

/obj/machinery/button/door/open_only/Initialize(mapload)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_y = -12
		if(SOUTH)
			pixel_y = 29
		if(EAST)
			pixel_x = -21
		if(WEST)
			pixel_x = 21


/obj/machinery/button/door/open_only/landing_zone
	name = "lockdown override"
	id = "landing_zone"
	icon_state = "shutterctrl"
	use_power = NO_POWER_USE
	resistance_flags = RESIST_ALL
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_DROPSHIP_REBEL)
	/// Has the shutters alarm been played?
	var/alarm_played = FALSE

/obj/machinery/button/door/open_only/landing_zone/Initialize(mapload)
	. = ..()
	var/area/area = get_area(src)
	area.flags_area |= MARINE_BASE

/obj/machinery/button/door/open_only/landing_zone/attack_hand(mob/living/user)
	if((machine_stat & (NOPOWER|BROKEN)))
		return
	if(!allowed(user))
		to_chat(user, span_danger("Access Denied"))
		flick("[initial(icon_state)]-denied", src)
		return
	if(alarm_played)
		flick("[initial(icon_state)]-denied", src)
		return
	use_power(active_power_usage)
	icon_state = "[initial(icon_state)]1"

	alarm_played = TRUE
	playsound_z(z, 'sound/effects/shutters_alarm.ogg', 15) // woop woop, shutters opening.
	addtimer(CALLBACK(src, /atom/movable/.proc/update_icon), 1.5 SECONDS)
	addtimer(CALLBACK(src, .proc/pulsed), 185)

/obj/machinery/button/door/open_only/landing_zone/pulsed()
	. = ..()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_OPEN_SHUTTERS_EARLY)

/obj/machinery/button/door/open_only/landing_zone/lz2
	id = "landing_zone_2"


/obj/machinery/driver_button
	name = "mass driver button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mass driver."
	var/id = null
	var/active = 0
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/ignition_switch
	name = "ignition switch"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mounted igniter."
	var/id = null
	var/active = 0
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/flasher_button
	name = "flasher button"
	desc = "A remote control switch for a mounted flasher."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	var/id = null
	var/active = 0
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/crema_switch
	desc = "Burn baby burn!"
	name = "crematorium igniter"
	icon = 'icons/obj/power.dmi'
	icon_state = "crema_switch"
	anchored = TRUE
	req_access = list(ACCESS_MARINE_MEDBAY)
	var/on = 0
	var/area/area = null
	var/otherarea = null
	var/id = 1

/obj/machinery/medical_help_button
	name = "Medical attention required"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A button for alerting doctors that you require assistance."
	var/active = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	var/obj/item/radio/radio

/obj/machinery/medical_help_button/Initialize(mapload)
	. = ..()
	radio = new(src)

/obj/machinery/medical_help_button/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/medical_help_button/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!istype(user))
		return
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_warning("[src] doesn't seem to be working."))
		return
	if(active)
		return
	use_power(active_power_usage)
	icon_state = "doorctrl1"

	radio.talk_into(src, "<b>[user.name] is requesting medical attention at: [get_area(src)].</b>", RADIO_CHANNEL_MEDICAL)
	visible_message("Remain calm, someone will be with you shortly.")

	active = TRUE
	addtimer(CALLBACK(src, .proc/icon_update_check), 10 SECONDS)

/obj/machinery/medical_help_button/proc/icon_update_check()
	active = FALSE
	update_icon()

/obj/machinery/medical_help_button/update_icon_state()
	if(machine_stat & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"

/obj/machinery/button/valhalla_button
	name = "Xeno spawner"
	resistance_flags = INDESTRUCTIBLE
	///The xeno created by the spawner
	var/mob/living/xeno
	///What spawner is linked with this spawner
	var/link = CLOSE

/obj/machinery/button/valhalla_button/attack_hand(mob/living/user)
	var/xeno_wanted = tgui_input_list(user, "What xeno do you want to spawn?", "Xeno spawn", GLOB.all_xeno_types)
	if(!xeno_wanted)
		return
	QDEL_NULL(xeno)
	xeno = new xeno_wanted(get_turf(GLOB.valhalla_xeno_spawn_landmark[link]))
	RegisterSignal(xeno, COMSIG_PARENT_QDELETING, .proc/clean_xeno)

/obj/machinery/button/valhalla_button/proc/clean_xeno()
	SIGNAL_HANDLER
	xeno = null

/obj/machinery/button/valhalla_button/far
	link = FAR

/obj/machinery/button/valhalla_button/far2
	link = FAR2

/obj/machinery/button/valhalla_button/close2
	link = CLOSE2

#undef DOOR_FLAG_OPEN_ONLY
