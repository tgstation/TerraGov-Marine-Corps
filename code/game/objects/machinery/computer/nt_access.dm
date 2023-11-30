// -- generate override code computer
/obj/item/circuitboard/computer/nt_access
	name = "circuit board (nuke disk generator)"
	build_path = /obj/machinery/computer/nt_access

/obj/machinery/computer/nt_access
	name = "NT security override terminal"
	desc = "Used to generate a security override code."
	icon = 'icons/obj/structures/campaign/tall_structures.dmi'
	icon_state = "terminal_red"
	screen_overlay = "terminal_overlay"
	interaction_flags = INTERACT_MACHINE_TGUI
	circuit = /obj/item/circuitboard/computer/nt_access
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE|UNACIDABLE
	layer = ABOVE_MOB_LAYER
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
	///UI messages for each progress segment
	var/list/technobabble = list(
		"Booting up terminal-  -Terminal running",
		"Establishing link to planetary mainframe- Link established",
		"WARNING, DIRECTORY CORRUPTED, running search algorithms- lockdown_override.exe found",
		"Invalid credentials, upgrading permissions through SOM rootkit- Permissions upgraded, lockdown_override.exe available",
		"lockdown_override.exe running - Generating new security lockdown override code",
		"Security lockdown override code sent to NT installation: Aubrey Gamma 16. Have a nice day."
	)
	///For designating minimap color icon
	var/code_color
	///The flavor message that shows up in the UI upon segment completion
	var/message = "error"

/obj/machinery/computer/nt_access/Initialize(mapload)
	. = ..()
	update_icon()
	update_minimap_icon()
	GLOB.campaign_structures += src

/obj/machinery/computer/nt_access/Destroy()
	GLOB.campaign_structures -= src
	return ..()

/obj/machinery/computer/nt_access/process()
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

/obj/machinery/computer/nt_access/update_icon_state()
	icon_state = initial(icon_state)

/obj/machinery/computer/nt_access/attackby(obj/item/I, mob/living/user, params)
	return attack_hand(user)

/obj/machinery/computer/nt_access/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NtAccessTerminal")
		ui.open()

/obj/machinery/computer/nt_access/ui_data(mob/user)
	var/list/data = list()

	if(completed_segments >= total_segments)
		message = "security override code generated. Run program to send."
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

	data["color"] = code_color

	data["segment_number"] = total_segments

	return data

/obj/machinery/computer/nt_access/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("run_program")
			if(busy || current_timer)
				to_chat(usr, span_warning("A program is already running."))
				return

			if(completed_segments == total_segments) //If we're done, there's no need to run a segment again
				busy = TRUE

				usr.visible_message("[usr] started a program to send the [code_color] security override command.", "You started a program to send the [code_color] security override command.")
				if(!do_after(usr, printing_time, NONE, src, BUSY_ICON_GENERIC, null, null, CALLBACK(src, TYPE_PROC_REF(/datum, process))))
					busy = FALSE
					return

				visible_message(span_notice("[src] beeps as it finishes sending the security override command."))
				SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_NT_OVERRIDE_CODE, code_color)
				busy = FALSE
				return

			busy = TRUE

			usr.visible_message("[usr] started a program to generate a security override code.", "You started a program to generate a security override code.")
			if(!do_after(usr, start_time, NONE, src, BUSY_ICON_GENERIC, null, null, CALLBACK(src, TYPE_PROC_REF(/datum, process))))
				busy = FALSE
				return

			busy = FALSE

			current_timer = addtimer(CALLBACK(src, PROC_REF(complete_segment)), segment_time, TIMER_STOPPABLE)
			update_minimap_icon()
			running = TRUE

/obj/machinery/computer/nt_access/ui_state(mob/user)
	return GLOB.human_adjacent_state

///Completes a stage of program progress
/obj/machinery/computer/nt_access/proc/complete_segment()
	playsound(src, 'sound/machines/ping.ogg', 25, 1)
	deltimer(current_timer)
	current_timer = null
	completed_segments = min(completed_segments + 1, total_segments)
	update_minimap_icon()
	running = FALSE

	if(completed_segments == total_segments)
		visible_message(span_notice("[src] beeps as it ready to send."))
		return

	visible_message(span_notice("[src] beeps as it's program requires attention."))

///Change minimap icon if its on or off
/obj/machinery/computer/nt_access/proc/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips_large.dmi', null, "[code_color]_disk[current_timer ? "_on" : "_off"]"))

/obj/machinery/computer/nt_access/red
	name = "red NT security override terminal"
	code_color = MISSION_CODE_RED

/obj/machinery/computer/nt_access/green
	name = "green NT security override terminal"
	icon_state = "terminal_green"
	code_color = MISSION_CODE_GREEN

/obj/machinery/computer/nt_access/blue
	name = "blue NT security override terminal"
	icon_state = "terminal_blue"
	code_color = MISSION_CODE_BLUE

/obj/effect/landmark/campaign_structure/nt_access
	name = "red NT security override terminal"
	icon = 'icons/obj/structures/campaign/tall_structures.dmi'
	icon_state = "terminal_red"
	mission_types = list(/datum/campaign_mission/destroy_mission/base_rescue)
	spawn_object = /obj/machinery/computer/nt_access/red

/obj/effect/landmark/campaign_structure/nt_access/blue
	name = "blue NT security override terminal"
	icon_state = "terminal_blue"
	spawn_object = /obj/machinery/computer/nt_access/blue
