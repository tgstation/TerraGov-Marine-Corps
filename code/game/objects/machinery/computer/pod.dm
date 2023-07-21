/obj/machinery/computer/pod
	name = "mass driver launch control"
	desc = "A combined blastdoor and mass driver control unit."
	circuit = /obj/item/circuitboard/computer/pod
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	interaction_flags = INTERACT_MACHINE_TGUI
	/// Connected mass driver
	var/obj/machinery/mass_driver/connected = null
	/// ID of the launch control
	var/id = 1
	/// If the launch timer counts down
	var/timing = FALSE
	/// Time before auto launch
	var/time = 30
	/// Range in which we search for a mass drivers and poddoors nearby
	var/range = 4
	/// Countdown timer for the mass driver's delayed launch functionality.
	COOLDOWN_DECLARE(massdriver_countdown)

/obj/machinery/computer/pod/Initialize(mapload)
	. = ..()
	for(var/obj/machinery/mass_driver/M in range(range, src))
		if(M.id == id)
			connected = M
			break

/obj/machinery/computer/pod/process(seconds_per_tick)
	if(COOLDOWN_CHECK(src, massdriver_countdown))
		timing = FALSE
		// alarm() sleeps, so we want to end processing first and can't rely on return PROCESS_KILL
		STOP_PROCESSING(SSmachines, src)
		alarm()

/**
 * Initiates launching sequence by checking if all components are functional, opening poddoors, firing mass drivers and then closing poddoors
 */
/obj/machinery/computer/pod/proc/alarm()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(!connected)
		say("Cannot locate mass driver connector. Cancelling firing sequence!")
		return

	for(var/obj/machinery/door/poddoor/M in range(range, src))
		if(M.id == id)
			M.open()

	sleep(2 SECONDS)
	for(var/obj/machinery/mass_driver/M in range(range, src))
		if(M.id == id)
			M.power = connected.power
			M.drive()

	sleep(5 SECONDS)
	for(var/obj/machinery/door/poddoor/M in range(range, src))
		if(M.id == id)
			M.close()

/obj/machinery/computer/pod/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MassDriverControl", name)
		ui.open()

/obj/machinery/computer/pod/ui_data(mob/user)
	var/list/data = list()
	// If the cooldown has finished, just display the time. If the cooldown hasn't finished, display the cooldown.
	var/display_time = COOLDOWN_CHECK(src, massdriver_countdown) ? time : COOLDOWN_TIMELEFT(src, massdriver_countdown) * 0.1
	data["connected"] = connected ? TRUE : FALSE
	data["seconds"] = round(display_time % 60)
	data["minutes"] = round((display_time - data["seconds"]) / 60)
	data["timing"] = timing
	data["power"] = connected ? connected.power : 0.25
	data["poddoor"] = FALSE
	for(var/obj/machinery/door/poddoor/door in range(range, src))
		if(door.id == id)
			data["poddoor"] = TRUE
			break
	return data

/obj/machinery/computer/pod/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		to_chat(usr, span_warning("Access denied."))
		return

	switch(action)
		if("set_power")
			if(!connected)
				return
			var/value = text2num(params["power"])
			if(!value)
				return
			value = clamp(value, 0.25, 16)
			connected.power = value
			return TRUE
		if("launch")
			alarm()
			return TRUE
		if("time")
			timing = !timing
			if(timing)
				COOLDOWN_START(src, massdriver_countdown, time SECONDS)
				START_PROCESSING(SSmachines, src)
			else
				time = COOLDOWN_TIMELEFT(src, massdriver_countdown) * 0.1
				COOLDOWN_RESET(src, massdriver_countdown)
				STOP_PROCESSING(SSmachines, src)
			return TRUE
		if("input")
			var/value = text2num(params["adjust"])
			if(!value)
				return
			value = round(time + value)
			time = clamp(value, 0, 120)
			return TRUE
		if("door")
			for(var/obj/machinery/door/poddoor/M in range(range, src))
				if(M.id == id)
					if(M.density)
						M.open()
					else
						M.close()
			return TRUE
		if("driver_test")
			for(var/obj/machinery/mass_driver/M in range(range, src))
				if(M.id == id)
					M.power = connected?.power
					M.drive()
			return TRUE
/obj/machinery/computer/pod/indestructible
	resistance_flags = INDESTRUCTIBLE|UNACIDABLE

/obj/machinery/computer/pod/old
	icon_state = "old"
	name = "DoorMex Control Computer"

/obj/machinery/computer/pod/old/syndicate
	name = "ProComp Executive IIc"
	desc = "The Syndicate operate on a tight budget. Operates external airlocks."

/obj/machinery/computer/pod/old/swf
	name = "Magix System IV"
	desc = "An arcane artifact that holds much magic. Running E-Knock 2.2: Sorceror's Edition"
