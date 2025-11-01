/obj/machinery/computer/code_generator
	name = "Generic generator"
	desc = "A secure terminal used to do generic things. You shouldn't see this."
	icon_state = "computer"
	interaction_flags = INTERACT_MACHINE_TGUI
	resistance_flags = RESIST_ALL|DROPSHIP_IMMUNE

	///Time needed for the machine to generate the disc
	var/segment_time = 1.5 MINUTES
	///Time to start a segment
	var/start_time = 15 SECONDS
	///Time to print a disk
	var/printing_time = 15 SECONDS

	///Total number of times the hack is required
	var/total_segments = 5
	///What segment we are on, (once this hits total, disk is printed)
	var/completed_segments = 0
	///The current ID of the timer running
	var/current_timer
	///Overall seconds elapsed
	var/seconds_elapsed = 0

	///Check if someone is printing already
	var/busy = FALSE
	///Is a segment currently running?
	var/running = FALSE
	///List of fluff text used in orger, each time a segment is completed
	var/list/technobabble
	///For designating minimap color icon
	var/key_color
	///The flavor message that shows up in the UI upon segment completion
	var/message = "error"
	///UI style used by this computer
	var/ui_style = "NukeDiskGenerator"

/obj/machinery/computer/code_generator/Initialize(mapload)
	. = ..()
	update_minimap_icon()

/obj/machinery/computer/code_generator/process()
	. = ..()
	if(. || !current_timer)
		if(running)
			seconds_elapsed += 2
		return

	seconds_elapsed = (segment_time/10) * completed_segments
	running = FALSE
	deltimer(current_timer)
	current_timer = null
	update_minimap_icon()
	visible_message("<b>[src]</b> shuts down as it loses power. Any running programs will now exit")

/obj/machinery/computer/code_generator/attackby(obj/item/I, mob/living/user, params)
	return attack_hand(user)

/obj/machinery/computer/code_generator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, ui_style)
		ui.open()

/obj/machinery/computer/code_generator/ui_data(mob/user)
	var/list/data = list()

	if(completed_segments >= total_segments)
		message = "Disk generated. Run program to print."
	else if(current_timer)
		message = "Program running."
	else if(!completed_segments)
		message = "Idle."
	else if(completed_segments < total_segments)
		message = "Restart required. Please re-run the program."

	data["message"] = message

	data["progress"] = seconds_elapsed * 10 / (segment_time * total_segments) //*10 because we need to convert to deciseconds

	data["time_left"] = current_timer ? round(timeleft(current_timer) * 0.1, 2) : "You shouldn't be seeing this, yell at coders."

	data["flavor_text"] = technobabble[completed_segments + 1]

	data["completed"] = (completed_segments == total_segments)

	data["running"] = running

	data["segment_time"] = segment_time

	data["color"] = key_color

	return data

/obj/machinery/computer/code_generator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("run_program")
			if(busy || current_timer)
				to_chat(usr, span_warning("A program is already running."))
				return

			if(completed_segments == total_segments) //If we're done, there's no need to run a segment again
				start_final(usr)
				return

			start_segment(usr)

/obj/machinery/computer/code_generator/ui_state(mob/user)
	return GLOB.human_adjacent_state

///What the computer does when completed
/obj/machinery/computer/code_generator/proc/start_segment(mob/user)
	busy = TRUE

	user.visible_message(span_notice("[user] begins typing away at the [src]'s keyboard..."),
	span_notice("You begin typing away at the [src]'s keyboard..."))
	if(!do_after(user, start_time, NONE, src, BUSY_ICON_GENERIC, null, null, CALLBACK(src, TYPE_PROC_REF(/datum, process))))
		busy = FALSE
		return FALSE

	busy = FALSE
	running = TRUE
	current_timer = addtimer(CALLBACK(src, PROC_REF(complete_segment)), segment_time, TIMER_STOPPABLE)
	update_minimap_icon()
	return TRUE

///What happens when a segment finishes running
/obj/machinery/computer/code_generator/proc/complete_segment()
	return

///What the computer does when run after completion
/obj/machinery/computer/code_generator/proc/start_final(mob/user)
	return

///Change minimap icon if its on or off
/obj/machinery/computer/code_generator/proc/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips_large.dmi', null, "[key_color]_disk[current_timer ? "_on" : "_off"]", MINIMAP_LABELS_LAYER))
