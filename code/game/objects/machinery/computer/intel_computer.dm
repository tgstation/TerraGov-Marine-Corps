/obj/item/circuitboard/computer/intel_computer
	name = "circuit board (intel computer)"
	build_path = /obj/machinery/computer/intel_computer

/obj/machinery/computer/intel_computer
	name = "Secured equipment computer"
	desc = "A computer used to access specialised equipment. TGMC Intel division will occasionally report the location of active computers"
	icon_state = "intel_computer"
	screen_overlay = "intel_computer_screen"
	circuit = /obj/item/circuitboard/computer/intel_computer

	resistance_flags = INDESTRUCTIBLE|UNACIDABLE
	interaction_flags = INTERACT_MACHINE_TGUI

	///Whether this computer is activated by the event yet
	var/active = FALSE

	///How much progress we get every tick, up to 100
	var/progress_interval = 1
	///Tracks how much of the terminal is completed
	var/progress = 0
	///have we logged into the terminal yet?
	var/logged_in = FALSE
	///On first login we want it to play a cool animation
	var/first_login = TRUE
	///Is it currently active?
	var/printing = FALSE
	///When we reach max progress and get the points
	var/printing_complete = FALSE
	///What faction has launched the intel process
	var/faction = FACTION_TERRAGOV

/obj/machinery/computer/intel_computer/Initialize(mapload)
	. = ..()
	GLOB.intel_computers += src
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, PROC_REF(disable_on_hijack))

/obj/machinery/computer/intel_computer/process()
	. = ..()
	if(!printing)
		STOP_PROCESSING(SSmachines, src)
		return
	progress += progress_interval
	if(progress >= 100)
		STOP_PROCESSING(SSmachines, src)
		printing = FALSE
		printing_complete = TRUE
		new /obj/item/loot_box/securelootcrate(get_turf(src))
		visible_message(span_notice("[src] beeps as it finishes bypassing security protocols, the secure compartment opens up to reveal its contents"))
		SSminimaps.remove_marker(src)

/obj/machinery/computer/intel_computer/Destroy()
	GLOB.intel_computers -= src
	return ..()

/obj/machinery/computer/intel_computer/interact(mob/user)
	if(!active)
		to_chat(user, span_notice("you aren't able to bypass the security protocols to use this terminal."))
		return
	return ..()

/obj/machinery/computer/intel_computer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IntelComputer", "IntelComputer")
		ui.open()

/obj/machinery/computer/intel_computer/ui_data(mob/user)
	var/list/data = list()
	data["logged_in"] = logged_in
	data["first_login"] = first_login
	data["progress"] = progress
	data["printing"] = printing
	data["printed"] = printing_complete

	return data

/obj/machinery/computer/intel_computer/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("login")
			logged_in = TRUE
			. = TRUE
		if("first_load")
			first_login = FALSE
			. = TRUE
		if("start_progressing")
			printing = TRUE
			var/mob/living/ui_user = ui.user
			faction = ui_user.faction
			START_PROCESSING(SSmachines, src)
	update_icon()

/// Deactivates this intel computer, for use on hijack
/obj/machinery/computer/intel_computer/proc/disable_on_hijack()
	GLOB.intel_computers -= src // prevents the event running
	if(!active)
		return
	SStgui.close_uis(src)
	SSminimaps.remove_marker(src)
	active = FALSE
	if(printing)
		STOP_PROCESSING(SSmachines, src)
