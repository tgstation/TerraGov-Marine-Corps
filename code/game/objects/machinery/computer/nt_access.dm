// -- generate override code computer
//TODO: Make a parent computer to remove all the nuke disk copy paste
/obj/item/circuitboard/computer/nt_access
	name = "circuit board (nuke disk generator)"
	build_path = /obj/machinery/computer/code_generator/nt_access

/obj/effect/landmark/campaign_structure/nt_access
	name = "red NT security override terminal"
	icon = 'icons/obj/structures/campaign/tall_structures.dmi'
	icon_state = "terminal_red"
	mission_types = list(/datum/campaign_mission/destroy_mission/base_rescue)
	spawn_object = /obj/machinery/computer/code_generator/nt_access/red

/obj/effect/landmark/campaign_structure/nt_access/blue
	name = "blue NT security override terminal"
	icon_state = "terminal_blue"
	spawn_object = /obj/machinery/computer/code_generator/nt_access/blue


/obj/machinery/computer/code_generator/nt_access
	name = "NT security override terminal"
	desc = "Used to generate a security override code."
	icon = 'icons/obj/structures/campaign/tall_structures.dmi'
	icon_state = "terminal_red"
	screen_overlay = "terminal_overlay"
	circuit = /obj/item/circuitboard/computer/nt_access
	use_power = NO_POWER_USE
	layer = ABOVE_MOB_LAYER
	ui_style = "NtAccessTerminal"

	segment_time = 1 MINUTES
	start_time = 5 SECONDS
	total_segments = 5

	technobabble = list(
		"Booting up terminal-  -Terminal running",
		"Establishing link to planetary mainframe- Link established",
		"WARNING, DIRECTORY CORRUPTED, running search algorithms- lockdown_override.exe found",
		"Invalid credentials, upgrading permissions through SOM rootkit- Permissions upgraded, lockdown_override.exe available",
		"lockdown_override.exe running - Generating new security lockdown override code",
		"Security lockdown override code sent to NT installation: Aubrey Gamma 16. Have a nice day."
	)

/obj/machinery/computer/code_generator/nt_access/Initialize(mapload)
	. = ..()
	GLOB.campaign_structures += src

/obj/machinery/computer/code_generator/nt_access/Destroy()
	GLOB.campaign_structures -= src
	return ..()

/obj/machinery/computer/code_generator/nt_access/update_icon_state()
	return

/obj/machinery/computer/code_generator/nt_access/start_segment(mob/user)
	. = ..()
	if(!.)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_NT_OVERRIDE_RUNNING, src)

/obj/machinery/computer/code_generator/nt_access/complete_segment()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_NT_OVERRIDE_STOP_RUNNING, src)
	playsound(src, 'sound/machines/ping.ogg', 25, 1)
	deltimer(current_timer)
	current_timer = null
	completed_segments = min(completed_segments + 1, total_segments)
	update_minimap_icon()
	running = FALSE

	if(completed_segments == total_segments)
		visible_message(span_notice("[src] beeps as security override code is ready to send."))
		return

	visible_message(span_notice("[src] beeps as its program requires attention."))

/obj/machinery/computer/code_generator/nt_access/start_final(mob/user)
	busy = TRUE

	user.visible_message("[user] started a program to send the [key_color] security override command.", "You started a program to send the [key_color] security override command.")
	if(!do_after(user, start_time, NONE, src, BUSY_ICON_GENERIC, null, null, CALLBACK(src, TYPE_PROC_REF(/datum, process))))
		busy = FALSE
		return

	visible_message(span_notice("[src] beeps as it finishes sending the security override command."))
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_NT_OVERRIDE_CODE, key_color)
	busy = FALSE
	set_disabled()

/obj/machinery/computer/code_generator/nt_access/red
	name = "red NT security override terminal"
	key_color = MISSION_CODE_RED

/obj/machinery/computer/code_generator/nt_access/green
	name = "green NT security override terminal"
	icon_state = "terminal_green"
	key_color = MISSION_CODE_GREEN

/obj/machinery/computer/code_generator/nt_access/blue
	name = "blue NT security override terminal"
	icon_state = "terminal_blue"
	key_color = MISSION_CODE_BLUE
