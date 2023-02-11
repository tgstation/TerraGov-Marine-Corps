// -- Print disk computer
/obj/item/circuitboard/computer/nuke_disk_generator
	name = "circuit board (nuke disk generator)"
	build_path = /obj/machinery/computer/nuke_disk_generator


/obj/machinery/computer/nuke_disk_generator
	name = "nuke disk generator"
	desc = "Used to generate the correct auth discs for the nuke."
	icon_state = "nuke_red"
	circuit = /obj/item/circuitboard/computer/nuke_disk_generator

	interaction_flags = INTERACT_OBJ_UI
	resistance_flags = INDESTRUCTIBLE|UNACIDABLE

	///Time  to complete one stage of disk generation
	var/generate_time = 1.5 MINUTES
	///time to start next stage of disk generation
	var/segment_time = 15 SECONDS
	///time to print a disk
	var/printing_time = 15 SECONDS

	///total number of times the hack is required
	var/total_segments = 5
	///what segment we are on, (once this hits total, disk is printed)
	var/completed_segments = 0
	///Holder for the current generation timer
	var/current_timer

	///Whether the disk can be printed or not
	var/printable = FALSE
	///If a disk is currently being printed
	var/running = FALSE

	///The type of disk this machine produces
	var/disk_type
	///The actual disk object produced by this machine
	var/obj/item/disk/nuclear/disk
	///Fluff text used to show generation progress
	var/list/technobabble = list(
		"Booting up terminal-  -Terminal running",
		"Establishing link to offsite mainframe- Link established",
		"WARNING, DIRECTORY CORRUPTED, running search algorithms- nuke_fission_timing.exe found",
		"Invalid credentials, upgrading permissions through TGMC military override- Permissions upgraded, nuke_fission_timing.exe available",
		"Downloading nuke_fission_timing.exe to removable storage- nuke_fission_timing.exe downloaded to floppy disk, have a nice day"
	)
	///For designating minimap color icon
	var/disk_color

/obj/machinery/computer/nuke_disk_generator/Initialize()
	. = ..()
	update_minimap_icon()

	if(!disk_type)
		WARNING("disk_type is required to be set before init")
		return INITIALIZE_HINT_QDEL

	GLOB.nuke_disk_generators += src
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, .proc/set_broken)

/obj/machinery/computer/nuke_disk_generator/Destroy()
	GLOB.nuke_disk_generators -= src
	return ..()

/obj/machinery/computer/nuke_disk_generator/process()
	. = ..()
	if(. || !current_timer)
		return

	deltimer(current_timer)
	current_timer = null
	update_minimap_icon()
	visible_message("<b>[src]</b> shuts down as it loses power. Any running programs will now exit")
	return PROCESS_KILL

/obj/machinery/computer/nuke_disk_generator/attackby(obj/item/I, mob/living/user, params)
	return attack_hand(user)

/obj/machinery/computer/nuke_disk_generator/ui_data(mob/user)
	var/message_output = "Unknown"
	if(completed_segments >= total_segments)
		message_output = "Disk generated. Run program to print."
	else if(current_timer)
		message_output = "Program running"
	else if(completed_segments <= 0)
		message_output = "Idle"
	else if(completed_segments < total_segments)
		message_output = "Restart required. Please rerun the program"

	var/list/log_output = list("Nuclear control authentication system - standing by")

	for(var/i in 1 to completed_segments)
		log_output.Add(technobabble[i])

	var/list/data = list(
		"progress" = completed_segments,
		"progress_max" = total_segments,
		"time_left" = current_timer ? round(timeleft(current_timer) * 0.1, 2) : 0.0,
		"time_max" = generate_time / 10,
		"message" = message_output,
		"log" = log_output
	)

	return data

/obj/machinery/computer/nuke_disk_generator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "NukeDiskGenerator", name)
		ui.open()

/obj/machinery/computer/nuke_disk_generator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "run_program")
		start_prog(usr)

///Starts the next stage of disc generation
/obj/machinery/computer/nuke_disk_generator/proc/start_prog(mob/user)
	if(running || current_timer)
		balloon_alert(user, "program already running")
		return

	if(printable)
		running = TRUE
		balloon_alert(user, "generating disk")
		user.visible_message("[user] started a program to print a nuclear authentication disk.", "You started a program to print a nuclear authentication disk.")

		if(!do_after(user, printing_time, TRUE, src, BUSY_ICON_GENERIC, null, null, CALLBACK(src, /datum.proc/process)))
			running = FALSE
			return

		running = FALSE
		print_disc()
		return

	running = TRUE
	balloon_alert(user, "starting program")
	user.visible_message("[user] started a program to generate a nuclear disk code.", "You started a program to generate a nuclear disk code.")

	if(!do_after(user, segment_time, TRUE, src, BUSY_ICON_GENERIC, null, null, CALLBACK(src, /datum.proc/process)))
		running = FALSE
		return

	running = FALSE
	current_timer = addtimer(CALLBACK(src, .proc/complete_segment), generate_time, TIMER_STOPPABLE)
	update_minimap_icon()

///Finishes the current stage if disk generation
/obj/machinery/computer/nuke_disk_generator/proc/complete_segment()
	playsound(src, 'sound/machines/ping.ogg', 25, 1)
	current_timer = null
	completed_segments = min(completed_segments + 1, total_segments)
	update_minimap_icon()

	if(completed_segments == total_segments)
		printable = TRUE
		visible_message(span_notice("[src] beeps as it ready to print."))
		return

	visible_message(span_notice("[src] beeps as it program requires attention."))

///Creates a copy of the nuke disk
/obj/machinery/computer/nuke_disk_generator/proc/print_disc()
	disk = new disk_type(loc)
	visible_message(span_notice("[src] beeps as it finishes printing the disc."))
	printable = TRUE

///Change minimap icon if its on or off
/obj/machinery/computer/nuke_disk_generator/proc/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "[disk_color]_disk[current_timer ? "_on" : "_off"]", 'icons/UI_icons/map_blips_large.dmi')

/obj/machinery/computer/nuke_disk_generator/red
	name = "red nuke disk generator"
	disk_type = /obj/item/disk/nuclear/red
	disk_color = "red"

/obj/machinery/computer/nuke_disk_generator/green
	name = "green nuke disk generator"
	icon_state = "nuke_green"
	disk_type = /obj/item/disk/nuclear/green
	disk_color = "green"

/obj/machinery/computer/nuke_disk_generator/blue
	name = "blue nuke disk generator"
	icon_state = "nuke_blue"
	disk_type = /obj/item/disk/nuclear/blue
	disk_color = "blue"
