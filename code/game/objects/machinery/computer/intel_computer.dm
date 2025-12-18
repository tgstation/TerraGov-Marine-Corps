/obj/item/circuitboard/computer/intel_computer
	name = "circuit board (intel computer)"
	build_path = /obj/machinery/computer/intel_computer


/obj/machinery/computer/intel_computer
	name = "Intelligence computer"
	desc = "A computer used to access the colonies central database. NTC Intel division will occasionally request remote data retrieval from these computers"
	icon_state = "intel_computer"
	screen_overlay = "intel_computer_screen"
	circuit = /obj/item/circuitboard/computer/intel_computer

	resistance_flags = INDESTRUCTIBLE|UNACIDABLE
	interaction_flags = INTERACT_MACHINE_TGUI

	///Whether this computer is activated by the event yet
	var/active = FALSE
	///How much supply points you get for completing the terminal
	var/supply_reward = 500
	///How much dropship points you get for completing the terminal
	var/dropship_reward = 350

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
	faction = FACTION_TERRAGOV


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
	if(progress < 100)
		return
	active = FALSE
	printing = FALSE
	printing_complete = TRUE
	//NTF edit. Printing a disk instead of instantly giving the points.
	var/obj/item/disk/intel_disk/new_disk = new(get_turf(src), supply_reward, dropship_reward, faction, get_area(src))
	visible_message(span_notice("[src] beeps as it finishes printing the disc."))
	minor_announce("Classified data extraction has been completed in [get_area(src)].", title = "Intel Division")
	SStgui.close_uis(src)
	update_minimap_icon()
	update_icon()
	STOP_PROCESSING(SSmachines, src)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_INTEL_DISK_PRINTED, src, new_disk)

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
	if(active)
		SSminimaps.remove_marker(src)
		SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, "intel[printing ? "_on" : "_off"]", MINIMAP_BLIPS_LAYER))
	else
		SSminimaps.remove_marker(src)

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

// SOL edit start
/obj/item/disk/intel_disk
	name = "classified data disk"
	desc = "Probably, contains some important data."
	icon_state = "nucleardisk"
	w_class = WEIGHT_CLASS_TINY
	/// The faction
	var/who_printed
	var/where_printed
	/// The world.time when the disk was printed.
	var/printed_at
	/// Supply reward. Set up during init. Is set up by an intel computer.
	var/supply_reward
	/// Dropship reward. Set up during init. Is set up by an intel computer.
	var/dropship_reward
	/// After this time, the disk will yield no req points.
	var/duration = 20 MINUTES

/obj/item/disk/intel_disk/Initialize(mapload, supply_reward, dropship_reward, who_printed, where_printed)
	. = ..()
	icon_state = "datadisk[rand(1, 7)]"
	src.supply_reward = supply_reward
	src.dropship_reward = dropship_reward
	src.who_printed = who_printed
	src.where_printed = where_printed
	printed_at = world.time
	name = "\improper [who_printed] Intelligence diskette ([stationTimestamp("hh:mm", printed_at + duration)])"
	desc += " According to the label, this disk was printed by [who_printed] in \the [where_printed]. The time stamp suggests that it was printed at [stationTimestamp("hh:mm", printed_at)]. The tactical information within it will cease to have value and soon after self destruct at [stationTimestamp("hh:mm", printed_at + duration)]."
	addtimer(CALLBACK(src, PROC_REF(disk_warning)), duration, TIMER_STOPPABLE)
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('ntf_modular/icons/UI_icons/map_blips.dmi', null, "intel_carried", MINIMAP_BLIPS_LAYER))

/obj/item/disk/intel_disk/proc/disk_warning()
	SIGNAL_HANDLER
	visible_message("[src] beeps as it is now obsolete. The disk will self destruct in a minute.")
	playsound(src, 'sound/machines/beepalert.ogg', 25)
	addtimer(CALLBACK(src, PROC_REF(disk_cleanup)), 1 MINUTES, TIMER_STOPPABLE)
	SSminimaps.remove_marker(src)

/obj/item/disk/intel_disk/proc/disk_cleanup()
	SIGNAL_HANDLER
	visible_message("[src] beeps a few times and explodes into pieces!")
	explosion(src,0,0,0,1,0,0,0, tiny = TRUE)
	qdel(src)

/obj/item/disk/intel_disk/get_export_value()
	if(world.time > printed_at + duration)
		. = null
	else
		. = list(supply_reward, dropship_reward)

/obj/item/disk/intel_disk/supply_export(faction_selling)
	. = ..()
	if(!.)
		return FALSE

	minor_announce("Classified data disk extracted by [faction_selling] from area of operations. [supply_reward] supply points and [dropship_reward] dropship points were acquired.", title = "Intel Division")
	GLOB.round_statistics.points_from_intel += supply_reward

/obj/item/disk/intel_disk/Destroy()
	SSminimaps.remove_marker(src)
	. = ..()
