#define DISK_CYCLE_REWARD_MIN 100
#define DISK_CYCLE_REWARD_MAX 300


// -- Print disk computer
/obj/item/circuitboard/computer/nuke_disk_generator
	name = "circuit board (nuke disk generator)"
	build_path = /obj/machinery/computer/nuke_disk_generator


/obj/machinery/computer/nuke_disk_generator
	name = "nuke disk generator"
	desc = "A secure terminal used to retrieve nuclear authentication codes and print them onto disks."
	icon_state = "computer"
	screen_overlay = "nuke_red"
	broken_icon = "computer_red_broken"
	interaction_flags = INTERACT_MACHINE_TGUI
	circuit = /obj/item/circuitboard/computer/nuke_disk_generator

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

	///The type of disk we're printing
	var/disk_type

	var/list/technobabble = list(
		"Booting up terminal-  -Terminal running",
		"Establishing link to offsite mainframe- Link established",
		"WARNING, DIRECTORY CORRUPTED, running search algorithms- nuke_fission_timing.exe found",
		"Invalid credentials, upgrading permissions through TGMC military override- Permissions upgraded, nuke_fission_timing.exe available",
		"Downloading nuke_fission_timing.exe to removable storage- nuke_fission_timing.exe downloaded to floppy disk, getting ready to print",
		"Program downloaded to disk. Have a nice day."
	)
	///For designating minimap color icon
	var/disk_color

	///The flavor message that shows up in the UI upon segment completion
	var/message = "error"

/obj/machinery/computer/nuke_disk_generator/Initialize(mapload)
	. = ..()
	update_minimap_icon()

	if(!disk_type)
		WARNING("disk_type is required to be set before init")
		return INITIALIZE_HINT_QDEL

	GLOB.nuke_disk_generators += src
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, PROC_REF(set_broken))

/obj/machinery/computer/nuke_disk_generator/Destroy()
	GLOB.nuke_disk_generators -= src
	return ..()


/obj/machinery/computer/nuke_disk_generator/process()
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


/obj/machinery/computer/nuke_disk_generator/attackby(obj/item/I, mob/living/user, params)
	return attack_hand(user)


/obj/machinery/computer/nuke_disk_generator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NukeDiskGenerator")
		ui.open()


/obj/machinery/computer/nuke_disk_generator/ui_data(mob/user)
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

	data["color"] = disk_color

	return data


/obj/machinery/computer/nuke_disk_generator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
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

				usr.visible_message(span_notice("[usr] inserts a floppy disk into the [src] and begins to type..."),
				span_notice("You insert a floppy disk into the [src] and begin to type..."))
				if(!do_after(usr, printing_time, NONE, src, BUSY_ICON_GENERIC, null, null, CALLBACK(src, TYPE_PROC_REF(/datum, process))))
					busy = FALSE
					return

				new disk_type(get_turf(src))
				visible_message(span_notice("[src] beeps, and spits out a [disk_color] floppy disk!"))
				SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DISK_GENERATED, src)
				busy = FALSE
				return

			busy = TRUE

			usr.visible_message(span_notice("[usr] begins typing away at the [src]'s keyboard..."),
			span_notice("You begin typing away at the [src]'s keyboard..."))
			if(!do_after(usr, start_time, NONE, src, BUSY_ICON_GENERIC, null, null, CALLBACK(src, TYPE_PROC_REF(/datum, process))))
				busy = FALSE
				return

			busy = FALSE

			current_timer = addtimer(CALLBACK(src, PROC_REF(complete_segment)), segment_time, TIMER_STOPPABLE)
			update_minimap_icon()
			running = TRUE

/obj/machinery/computer/nuke_disk_generator/ui_state(mob/user)
	return GLOB.human_adjacent_state

/obj/machinery/computer/nuke_disk_generator/proc/complete_segment()
	playsound(src, 'sound/machines/ping.ogg', 25, 1)
	deltimer(current_timer)
	current_timer = null
	completed_segments = min(completed_segments + 1, total_segments)

	if(iscrashgamemode(SSticker.mode))
		for(var/mob/living/carbon/human/human AS in GLOB.human_mob_list)
			if(!human.job)
				continue
			var/obj/item/card/id/user_id =  human.get_idcard()
			if(!user_id)
				continue
			for(var/i in user_id.marine_points)
				user_id.marine_points[i] += 2

	update_minimap_icon()
	running = FALSE

	if(completed_segments == total_segments)
		say("Program retrieval successful. Standing by to print...")
		return

	say("Program run has concluded! Standing by...")

	// Requisitions points bonus per cycle.
	var/disk_cycle_reward = DISK_CYCLE_REWARD_MIN + ((DISK_CYCLE_REWARD_MAX - DISK_CYCLE_REWARD_MIN) * (SSmonitor.maximum_connected_players_count / HIGH_PLAYER_POP))
	disk_cycle_reward = ROUND_UP(clamp(disk_cycle_reward, DISK_CYCLE_REWARD_MIN, DISK_CYCLE_REWARD_MAX))

	SSpoints.supply_points[FACTION_TERRAGOV] += disk_cycle_reward
	SSpoints.dropship_points += disk_cycle_reward/10
	GLOB.round_statistics.points_from_objectives += disk_cycle_reward

	say("Program has execution has rewarded [disk_cycle_reward] requisitions points!")

///Change minimap icon if its on or off
/obj/machinery/computer/nuke_disk_generator/proc/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips_large.dmi', null, "[disk_color]_disk[current_timer ? "_on" : "_off"]", MINIMAP_LABELS_LAYER))

/obj/machinery/computer/nuke_disk_generator/red
	name = "red nuke disk generator"
	disk_type = /obj/item/disk/nuclear/red
	disk_color = "red"

/obj/machinery/computer/nuke_disk_generator/green
	name = "green nuke disk generator"
	screen_overlay = "nuke_green"
	broken_icon = "computer_broken"
	disk_type = /obj/item/disk/nuclear/green
	disk_color = "green"

/obj/machinery/computer/nuke_disk_generator/blue
	name = "blue nuke disk generator"
	screen_overlay = "nuke_blue"
	broken_icon = "computer_blue_broken"
	disk_type = /obj/item/disk/nuclear/blue
	disk_color = "blue"

//list of disk gens we want to spawn for nuke related gamemodes. Could just use subtypes, but using a list in case more gen related stuff is added in the future
GLOBAL_LIST_INIT(nuke_disk_generator_types, list(/obj/machinery/computer/nuke_disk_generator/red, /obj/machinery/computer/nuke_disk_generator/green, /obj/machinery/computer/nuke_disk_generator/blue))

/obj/structure/nuke_disk_candidate
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "nuke_rand"
	name = "computer"
	desc = "Some dusty old computer. Looks non-functional"
	density = TRUE
	anchored = TRUE
	resistance_flags = RESIST_ALL
	///This list contains disk set keys this list as associated with. Keys must be contained in the map's json combined with their weight. Intended to be at least 3 disks per key. Supports more, does NOT support less.
	var/list/set_associations = list("basic") //These are set by mappers via map vars. Setting this one as its base type so people can skip that part if they only have 3 disks on a map.
	///This will FORCE this disk location to exist for these specific sets. Please do not force more than 3 for a set or I will scream at you.
	var/list/force_for_sets = list() //Mapper var. Edit in map.

//Randomised spawn points for nuke disk generators
/obj/structure/nuke_disk_candidate/Initialize(mapload)
	. = ..()
	GLOB.nuke_disk_spawn_locs += src
	icon_state = "computer"

/obj/structure/nuke_disk_candidate/Destroy()
	GLOB.nuke_disk_spawn_locs -= src
	return ..()
