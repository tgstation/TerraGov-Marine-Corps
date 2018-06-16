#define CONTROL_POD_DOORS 0
#define CONTROL_NORMAL_DOORS 1
#define CONTROL_EMITTERS 2
#define CONTROL_DROPSHIP 3

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
	/*
	Bitflag, 	1= open
				2= idscan,
				4= bolts
				8= shock
				16= door safties

	*/

	var/exposedwires = 0
	var/wires = 3
	/*
	Bitflag,	1=checkID
				2=Network Access
	*/

	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/door_control/attack_ai(mob/user as mob)
	if(wires & 2)
		return src.attack_hand(user)
	else
		user << "Error, no route to host."

/obj/machinery/door_control/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door_control/attack_alien(mob/user as mob)
	return

/obj/machinery/door_control/attackby(obj/item/W, mob/user as mob)
	/* For later implementation
	if (istype(W, /obj/item/tool/screwdriver))
	{
		if(wiresexposed)
			icon_state = "doorctrl0"
			wiresexposed = 0

		else
			icon_state = "doorctrl-open"
			wiresexposed = 1

		return
	}
	*/
	if(istype(W, /obj/item/device/detective_scanner))
		return
	if(istype(W, /obj/item/card/emag))
		req_access = list()
		req_one_access = list()
		playsound(src.loc, "sparks", 25, 1)
	return src.attack_hand(user)

/obj/machinery/door_control/proc/handle_dropship(var/ship_id)
	var/shuttle_tag
	switch(ship_id)
		if("sh_dropship1")
			shuttle_tag = "[MAIN_SHIP_NAME] Dropship 1"
		if("sh_dropship2")
			shuttle_tag = "[MAIN_SHIP_NAME] Dropship 2"
	if(!shuttle_tag)
		return
	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(shuttle))
		return
	if(shuttle.door_override)
		return // its been locked down by the queen
	if(z == 3) // on the almayer
		return
	for(var/obj/machinery/door/airlock/dropship_hatch/M in machines)
		if(M.id == ship_id)
			if(M.locked && M.density)
				continue // jobs done
			else if(!M.locked && M.density)
				M.lock() // closed but not locked yet
				continue
			else
				M.do_command("secure_close")

	var/obj/machinery/door/airlock/multi_tile/almayer/reardoor
	switch(ship_id)
		if("sh_dropship1")
			for(var/obj/machinery/door/airlock/multi_tile/almayer/dropshiprear/ds1/D in machines)
				reardoor = D
		if("sh_dropship2")
			for(var/obj/machinery/door/airlock/multi_tile/almayer/dropshiprear/ds2/D in machines)
				reardoor = D

	if(!reardoor.locked && reardoor.density)
		reardoor.lock() // closed but not locked yet
	else if(reardoor.locked && !reardoor.density)
		spawn()
			reardoor.unlock()
			sleep(1)
			reardoor.close()
			sleep(reardoor.openspeed + 1) // let it close
			reardoor.lock() // THEN lock it
	else
		spawn()
			reardoor.close()
			sleep(reardoor.openspeed + 1)
			reardoor.lock()

/obj/machinery/door_control/proc/handle_door()
	for(var/obj/machinery/door/airlock/D in range(range))
		if(D.id_tag == src.id)
			if(specialfunctions & OPEN)
				if (D.density)
					spawn(0)
						D.open()
						return
				else
					spawn(0)
						D.close()
						return
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
					if(!D.isWireCut(4) && D.arePowerSystemsOn())
						D.unlock()
				if(specialfunctions & SHOCK)
					D.secondsElectrified = 0
				if(specialfunctions & SAFE)
					D.safe = 1

/obj/machinery/door_control/proc/handle_pod()
	for(var/obj/machinery/door/poddoor/M in machines)
		if(M.id == id)
			var/datum/shuttle/ferry/marine/S
			var/area/A = get_area(M)
			for(var/i = 1 to 2)
				if(istype(A, text2path("/area/shuttle/drop[i]")))
					S = shuttle_controller.shuttles["[MAIN_SHIP_NAME] Dropship [i]"]
					if(S.moving_status == SHUTTLE_INTRANSIT) r_FAL
			if(M.density)
				spawn()
					M.open()
			else
				spawn()
					M.close()

/obj/machinery/door_control/proc/handle_emitters(mob/user as mob)
	for(var/obj/machinery/power/emitter/E in range(range))
		if(E.id == src.id)
			spawn(0)
				E.activate(user)
				return

/obj/machinery/door_control/attack_hand(mob/user)
	src.add_fingerprint(user)
	if(istype(user,/mob/living/carbon/Xenomorph))
		return
	if(stat & (NOPOWER|BROKEN))
		user << "<span class='warning'>[src] doesn't seem to be working.</span>"
		return

	if(!allowed(user) && (wires & 1))
		user << "\red Access Denied"
		flick("doorctrl-denied",src)
		return

	use_power(5)
	icon_state = "doorctrl1"
	add_fingerprint(user)

	switch(normaldoorcontrol)
		if(CONTROL_NORMAL_DOORS)
			handle_door()
		if(CONTROL_POD_DOORS)
			handle_pod()
		if(CONTROL_EMITTERS)
			handle_emitters(user)
		if(CONTROL_DROPSHIP)
			handle_dropship(id)

	desiredstate = !desiredstate
	spawn(15)
		if(!(stat & NOPOWER))
			icon_state = "doorctrl0"

/obj/machinery/door_control/power_change()
	..()
	if(stat & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"

/obj/machinery/driver_button/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/driver_button/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/driver_button/attackby(obj/item/W, mob/user as mob)

	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/driver_button/attack_hand(mob/user as mob)

	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return
	add_fingerprint(user)

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/door/poddoor/M in machines)
		if(M.id == src.id)
			spawn(0)
				M.open()
				return

	sleep(20)

	for(var/obj/machinery/mass_driver/M in machines)
		if(M.id == src.id)
			M.drive()

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in machines)
		if(M.id == src.id)
			spawn(0)
				M.close()
				return

	icon_state = "launcherbtt"
	active = 0

	return

/obj/machinery/door_control/timed_automatic
	var/trigger_delay = 1 //in minutes
	var/trigger_time
	var/triggered = 0
	use_power = 0

/obj/machinery/door_control/timed_automatic/New()
		..()
		trigger_time = world.time + trigger_delay*600
		processing_objects.Add(src)
		//start_processing()  // should really be using this -spookydonut

/obj/machinery/door_control/timed_automatic/process()
	if (!triggered && world.time >= trigger_time)
		icon_state = "doorctrl1"

		switch(normaldoorcontrol)
			if(CONTROL_NORMAL_DOORS)
				handle_door()
			if(CONTROL_POD_DOORS)
				handle_pod()
			if(CONTROL_EMITTERS)
				handle_emitters()
			if(CONTROL_DROPSHIP)
				handle_dropship(id)

		desiredstate = !desiredstate
		triggered = 1
		processing_objects.Remove(src)
		//stop_processing()
		spawn(15)
			if(!(stat & NOPOWER))
				icon_state = "doorctrl0"
