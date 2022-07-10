// -- Print disk computer
/obj/item/circuitboard/computer/nuke_disk_generator
	name = "circuit board (nuke disk generator)"
	build_path = /obj/machinery/computer/nuke_disk_generator


/obj/machinery/computer/nuke_disk_generator
	name = "nuke disk generator"
	desc = "Used to generate the correct auth discs for the nuke."
	icon_state = "nuke_red"
	circuit = /obj/item/circuitboard/computer/nuke_disk_generator

	resistance_flags = INDESTRUCTIBLE|UNACIDABLE

	var/generate_time = 1.5 MINUTES // time for the machine to generate the disc
	var/segment_time = 15 SECONDS // time to start the hack
	var/printing_time = 15 SECONDS // time to print a disk

	var/total_segments = 5 // total number of times the hack is required
	var/completed_segments = 0 // what segment we are on, (once this hits total, disk is printed)
	var/current_timer

	var/reprintable = FALSE // once the disk is printed, reprinting is enabled
	var/printing = FALSE // check if someone is printing already

	var/disk_type
	var/obj/item/disk/nuclear/disk

	var/list/technobabble = list(
		"Booting up terminal-  -Terminal running",
		"Establishing link to offsite mainframe- Link established",
		"WARNING, DIRECTORY CORRUPTED, running search algorithms- nuke_fission_timing.exe found",
		"Invalid credentials, upgrading permissions through TGMC military override- Permissions upgraded, nuke_fission_timing.exe available",
		"Downloading nuke_fission_timing.exe to removable storage- nuke_fission_timing.exe downloaded to floppy disk, have a nice day"
	)

/obj/machinery/computer/nuke_disk_generator/Initialize()
	. = ..()

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
	visible_message("<b>[src]</b> shuts down as it loses power. Any running programs will now exit")
	return PROCESS_KILL


/obj/machinery/computer/nuke_disk_generator/attackby(obj/item/I, mob/living/user, params)
	return attack_hand(user)


/obj/machinery/computer/nuke_disk_generator/interact(mob/user)
	. = ..()
	if(.)
		return
	var/dat = ""
	dat += "<div align='center'><a href='?src=[REF(src)];generate=1'>Run Program</a></div>"
	dat += "<br/>"
	dat += "<hr/>"
	dat += "<div align='center'><h2>Status</h2></div>"

	var/message = "Error"
	if(completed_segments >= total_segments)
		message = "Disk generated. Run program to print."
	else if(current_timer)
		message = "Program running"
	else if(completed_segments == 0)
		message = "Idle"
	else if(completed_segments < total_segments)
		message = "Restart required. Please rerun the program"
	else
		message = "Unknown"

	var/progress = round((completed_segments / total_segments) * 100)

	dat += "<br/><span><b>Progress</b>: [progress]%</span>"
	dat += "<br/><span><b>Time left</b>: [current_timer ? round(timeleft(current_timer) * 0.1, 2) : 0.0]</span>"
	dat += "<br/><span><b>Message</b>: [message]</span>"

	var/flair = ""
	for(var/i in 1 to completed_segments)
		flair += "[technobabble[i]]<br />"

	dat += "<br /><br /><span style='font-family: monospace, monospace;'>[flair]</span>"

	var/datum/browser/popup = new(user, "computer", "<div align='center'>Nuke Disk Generator</div>")
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/nuke_disk_generator/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["generate"])
		if(printing || current_timer)
			to_chat(usr, span_warning("A program is already running."))
			return
		if(reprintable)
			printing = TRUE
			addtimer(VARSET_CALLBACK(src, printing, FALSE), printing_time)

			usr.visible_message("[usr] started a program to regenerate a nuclear disk code.", "You started a program to generate a nuclear disk code.")
			if(!do_after(usr, printing_time, TRUE, src, BUSY_ICON_GENERIC, null, null, CALLBACK(src, /datum.proc/process)))
				return

			print_disc()
			return

		printing = TRUE
		addtimer(VARSET_CALLBACK(src, printing, FALSE), segment_time)

		usr.visible_message("[usr] started a program to generate a nuclear disk code.", "You started a program to generate a nuclear disk code.")
		if(!do_after(usr, segment_time, TRUE, src, BUSY_ICON_GENERIC, null, null, CALLBACK(src, /datum.proc/process)))
			return

		current_timer = addtimer(CALLBACK(src, .proc/complete_segment), generate_time, TIMER_STOPPABLE)

	updateUsrDialog()


/obj/machinery/computer/nuke_disk_generator/proc/complete_segment()
	playsound(src, 'sound/machines/ping.ogg', 25, 1)
	current_timer = null
	completed_segments = min(completed_segments + 1, total_segments)

	if(completed_segments == total_segments)
		reprintable = TRUE
		visible_message(span_notice("[src] beeps as it ready to print."))
		return

	visible_message(span_notice("[src] beeps as it program requires attention."))


/obj/machinery/computer/nuke_disk_generator/proc/print_disc()
	disk = new disk_type(loc)
	visible_message(span_notice("[src] beeps as it finishes printing the disc."))
	reprintable = TRUE

/obj/machinery/computer/nuke_disk_generator/red
	name = "red nuke disk generator"
	disk_type = /obj/item/disk/nuclear/red

/obj/machinery/computer/nuke_disk_generator/red/Initialize()
	. = ..()
	SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "red_disk")

/obj/machinery/computer/nuke_disk_generator/green
	name = "green nuke disk generator"
	icon_state = "nuke_green"
	disk_type = /obj/item/disk/nuclear/green

/obj/machinery/computer/nuke_disk_generator/green/Initialize()
	. = ..()
	SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "green_disk")

/obj/machinery/computer/nuke_disk_generator/blue
	name = "blue nuke disk generator"
	icon_state = "nuke_blue"
	disk_type = /obj/item/disk/nuclear/blue

/obj/machinery/computer/nuke_disk_generator/blue/Initialize()
	. = ..()
	SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "blue_disk")
