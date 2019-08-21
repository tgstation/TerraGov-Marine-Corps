#define CONTROL_POD_DOORS 0
#define CONTROL_NORMAL_DOORS 1

/obj/machinery/door_control
	name = "remote door-control"
	desc = "It controls doors, remotely."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control-switch for a door."
	power_channel = ENVIRON
	var/id = null
	var/range = 10
	var/normaldoorcontrol = CONTROL_POD_DOORS
	var/desiredstate = 0 // Zero is closed, 1 is open.
	var/specialfunctions = 1
	anchored = TRUE
	var/pressed = FALSE
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4


/obj/machinery/door_control/attack_paw(mob/living/carbon/monkey/user)
	return src.attack_hand(user)

/obj/machinery/door_control/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/detective_scanner))
		return
	else 
		return attack_hand(user)

/obj/machinery/door_control/proc/handle_door()
	for(var/obj/machinery/door/airlock/D in range(range))
		if(D.id_tag == src.id)
			if(specialfunctions & OPEN)
				if (D.density)
					INVOKE_ASYNC(D, /obj/machinery/door.proc/open)
				else
					INVOKE_ASYNC(D, /obj/machinery/door.proc/close)
			if(desiredstate == 1)
				if(specialfunctions & IDSCAN)
					D.aiDisabledIdScanner = 1
				if(specialfunctions & BOLTS)
					D.lock()
				if(specialfunctions & SHOCK)
					D.secondsElectrified = -1
				if(specialfunctions & SAFE)
					D.safe = 0
			else
				if(specialfunctions & IDSCAN)
					D.aiDisabledIdScanner = 0
				if(specialfunctions & BOLTS)
					if(!D.wires.is_cut(WIRE_BOLTS) && D.hasPower())
						D.unlock()
				if(specialfunctions & SHOCK)
					D.secondsElectrified = 0
				if(specialfunctions & SAFE)
					D.safe = 1

/obj/machinery/door_control/proc/handle_pod()
	for(var/obj/machinery/door/poddoor/M in GLOB.machines)
		if(M.id == id)
			if(M.density)
				INVOKE_ASYNC(M, /obj/machinery/door/.proc/open)
			else
				INVOKE_ASYNC(M, /obj/machinery/door/.proc/close)

/obj/machinery/door_control/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(istype(user,/mob/living/carbon/xenomorph))
		return
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='warning'>[src] doesn't seem to be working.</span>")
		return

	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied</span>")
		flick("doorctrl-denied",src)
		return

	use_power(5)
	pressed = TRUE
	update_icon()

	switch(normaldoorcontrol)
		if(CONTROL_NORMAL_DOORS)
			handle_door()
		if(CONTROL_POD_DOORS)
			handle_pod()

	desiredstate = !desiredstate
	addtimer(CALLBACK(src, .proc/unpress), 15, TIMER_OVERRIDE|TIMER_UNIQUE)


/obj/machinery/door_control/attack_ai(mob/living/silicon/ai/AI)
	return attack_hand(AI)


/obj/machinery/door_control/proc/unpress()
	pressed = FALSE
	update_icon()

/obj/machinery/door_control/update_icon()
	if(machine_stat & NOPOWER)
		icon_state = "doorctrl-p"
	else if(pressed)
		icon_state = "doorctrl1"
	else
		icon_state = "doorctrl0"

/obj/machinery/driver_button/attack_ai(mob/living/silicon/ai/AI)
	return attack_hand(AI)

/obj/machinery/driver_button/attack_paw(mob/living/carbon/monkey/user)
	return src.attack_hand(user)

/obj/machinery/driver_button/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/detective_scanner))
		return
	else
		return attack_hand(user)

/obj/machinery/driver_button/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/door/poddoor/M in GLOB.machines)
		if(M.id == src.id)
			INVOKE_ASYNC(M, /obj/machinery/door.proc/open)

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in GLOB.machines)
		if(M.id == src.id)
			INVOKE_ASYNC(M, /obj/machinery/door.proc/close)

	icon_state = "launcherbtt"
	active = 0
