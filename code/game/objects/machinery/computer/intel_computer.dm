/obj/item/circuitboard/computer/intel_computer
	name = "circuit board (intel computer)"
	build_path = /obj/machinery/computer/intel_computer


/obj/machinery/computer/intel_computer
	name = "Intelligence computer"
	desc = "A computer used to access the colonies central database. TGMC Intel division will occasionally request remote data retrieval from these computers"
	icon_state = "nuke_red"
	circuit = /obj/item/circuitboard/computer/intel_computer

	resistance_flags = INDESTRUCTIBLE|UNACIDABLE
	interaction_flags = INTERACT_MACHINE_TGUI

	///Whether this computer is activated by the event yet
	var/active = FALSE
	///How much supply points you get for completing the terminal
	var/supply_reward = 60
	///How much dropship points you get for completing the terminal
	var/dropship_reward = 60

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


/obj/machinery/computer/intel_computer/Initialize()
	. = ..()
	GLOB.intel_computers += src

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
		SSpoints.supply_points += supply_reward
		SSpoints.dropship_points += dropship_reward
		priority_announce("Classified transmission recieved from [get_area(src)]. Bonus delivered as [supply_reward] supply points and [dropship_reward] dropship points.", title = "TGMC Intel Division")


/obj/machinery/computer/intel_computer/Destroy()
	GLOB.intel_computers -= src
	return ..()

/obj/machinery/computer/intel_computer/interact(mob/user)
	if(!active)
		to_chat(user, "<span class='notice'> This terminal has nothing of use on it.</span>")
		return
	return ..()

/obj/machinery/computer/intel_computer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "IntelComputer", "IntelComputer", 400, 500, master_ui, state)
		ui.open()

/obj/machinery/computer/intel_computer/ui_data(mob/user)
	var/list/data = list()
	data["logged_in"] = logged_in
	data["first_login"] = first_login
	data["progress"] = progress
	data["printing"] = printing
	data["printed"] = printing_complete

	return data

/obj/machinery/computer/intel_computer/ui_act(action, params)
	if(..())
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
			START_PROCESSING(SSmachines, src)
	update_icon()
