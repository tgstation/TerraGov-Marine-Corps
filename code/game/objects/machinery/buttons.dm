#define DOOR_FLAG_OPEN_ONLY (1 << 0)

/obj/machinery/button
	name = "button"
	desc = "A remote control switch."
	icon = 'icons/obj/machines/buttons.dmi'
	icon_state = "doorctrl"
	power_channel = ENVIRON
	var/id = null
	var/next_activate = 0
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 70)
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	resistance_flags = LAVA_PROOF | FIRE_PROOF


/obj/machinery/button/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


/obj/machinery/button/Initialize(mapload, ndir = 0)
	. = ..()
	setDir(ndir)
	pixel_x = ( (dir & 3) ? 0 : (dir == 4 ? -24 : 24) )
	pixel_y = ( (dir & 3) ? (dir == 1 ? -24 : 24) : 0 )
	update_icon()


/obj/machinery/button/update_icon()
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = "[initial(icon_state)]-p"
	else
		icon_state = initial(icon_state)


/obj/machinery/button/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/button/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if((machine_stat & (NOPOWER|BROKEN)))
		return

	if(!allowed(user))
		to_chat(user, "<span class='danger'>Access Denied</span>")
		flick("[initial(icon_state)]-denied", src)
		return

	use_power(5)
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
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


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
		INVOKE_ASYNC(M, openclose ? /obj/machinery/door/poddoor.proc/open : /obj/machinery/door/poddoor.proc/close)


/obj/machinery/button/door/open_only
	name = "open button"
	desc = "Opens whatever it is linked to. Does not close. Careful on what you release."
	specialfunctions = DOOR_FLAG_OPEN_ONLY


/obj/machinery/driver_button
	name = "mass driver button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mass driver."
	var/id = null
	var/active = 0
	anchored = TRUE
	use_power = 1
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
	use_power = 1
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
	use_power = 1
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

	attack_paw(mob/user as mob)
		return

/obj/machinery/medical_help_button
	name = "Medical attention required"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A button for alerting doctors that you require assistance."
	var/active = FALSE
	anchored = TRUE
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4
	var/obj/item/radio/radio

/obj/machinery/medical_help_button/Initialize(mapload)
	. = ..()
	radio = new(src)

/obj/machinery/medical_help_button/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/medical_help_button/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(.)
		return
	if(!istype(user))
		return
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='warning'>[src] doesn't seem to be working.</span>")
		return
	if(active)
		return
	use_power(5)
	icon_state = "doorctrl1"

	radio.talk_into(src, "<b>[user.name] is requesting medical attention at: [get_area(src)].</b>", RADIO_CHANNEL_MEDICAL)
	visible_message("Remain calm, someone will be with you shortly.")

	active = TRUE
	addtimer(CALLBACK(src, .proc/icon_update_check), 10 SECONDS)

/obj/machinery/medical_help_button/proc/icon_update_check()
	active = FALSE
	update_icon()

/obj/machinery/medical_help_button/update_icon()
	if(machine_stat & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"


#undef DOOR_FLAG_OPEN_ONLY