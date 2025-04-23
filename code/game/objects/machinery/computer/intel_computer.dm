/obj/item/circuitboard/computer/intel_computer
	name = "circuit board (intel computer)"
	build_path = /obj/machinery/computer/intel_computer


/obj/machinery/computer/intel_computer
	name = "Intelligence computer"
	desc = "A computer used to access the colonies central database. TGMC Intel division will occasionally request remote data retrieval from these computers"
	icon_state = "intel_computer"
	screen_overlay = "intel_computer_screen"
	circuit = /obj/item/circuitboard/computer/intel_computer

	resistance_flags = INDESTRUCTIBLE|UNACIDABLE
	interaction_flags = INTERACT_MACHINE_TGUI

	faction = FACTION_TERRAGOV

	///Whether this computer is activated by the event yet
	var/active = FALSE
	///How much supply points you get for completing the terminal
	var/supply_reward = 1000
	///How much dropship points you get for completing the terminal
	var/dropship_reward = 100

	///How much progress we get every tick, up to 100
	var/progress_interval = 0.75
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

/obj/machinery/computer/intel_computer/Initialize(mapload)
	. = ..()
	GLOB.intel_computers += src
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, PROC_REF(disable_on_hijack))

/obj/machinery/computer/intel_computer/process()
	. = ..()
	if(!printing)
		STOP_PROCESSING(SSmachines, src)
		return
	if (machine_stat & NOPOWER)
		printing = FALSE
		update_minimap_icon()
		visible_message("<b>[src]</b> shuts down as it loses power. Any running programs will now exit.")
		if(progress >= 50)
			progress = 50
		else
			progress = 0
		return
	progress += progress_interval
	if(progress <= 100)
		return
	STOP_PROCESSING(SSmachines, src)
	printing = FALSE
	printing_complete = TRUE
	update_minimap_icon()
	SSpoints.supply_points[faction] += supply_reward
	SSpoints.dropship_points += dropship_reward
	minor_announce("Classified transmission recieved from [get_area(src)]. Bonus delivered as [supply_reward] supply points and [dropship_reward] dropship points.", title = "TGMC Intel Division")
	SSminimaps.remove_marker(src)

/obj/machinery/computer/intel_computer/Destroy()
	GLOB.intel_computers -= src
	return ..()

/obj/machinery/computer/intel_computer/interact(mob/user)
	if(!active)
		to_chat(user, span_notice("This terminal has nothing of use on it."))
		return
	return ..()

/obj/machinery/computer/intel_computer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IntelComputer", "IntelComputer")
		ui.open()

///Change minimap icon if its on or off
/obj/machinery/computer/intel_computer/proc/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, "intel[printing ? "_on" : "_off"]", MINIMAP_LABELS_LAYER))

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
			update_minimap_icon()
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
