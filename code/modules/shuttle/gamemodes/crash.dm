// -- Docks
/obj/docking_port/stationary/crashmode
	id = "canterbury_dock"
	name = "Canterbury Crash Site"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "crash_site"
	dir = SOUTH
	width = 19
	height = 31
	dwidth = 9
	dheight = 15
	hidden = TRUE  //To make them not block landings during distress


// -- Shuttles

/obj/docking_port/mobile/crashmode
	name = "TGS Canterbury"
	dir = SOUTH
	width = 15
	height = 24
	dwidth = 7
	dheight = 12

	callTime = CRASH_DELAY_TIME
	ignitionTime = 5 SECONDS
	prearrivalTime = 12 SECONDS

	var/list/spawnpoints = list()
	var/list/latejoins = list()
	var/list/spawns_by_job = list()

/obj/docking_port/mobile/crashmode/register()
	. = ..()
	SSshuttle.canterbury = src

/obj/docking_port/mobile/crashmode/on_prearrival()
	. = ..()
	var/op_name = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction != FACTION_TERRAGOV)
			return
		var/initiate_title = op_name
		var/initiate_screen_message = "[SSmapping.configs[GROUND_MAP].map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] █:█<br>" + "Black Ops Platoon<br>" + "[human.job.title], ████"
		human.play_screen_text(HUD_ANNOUNCEMENT_FORMATTING(initiate_title, initiate_screen_message, LEFT_ALIGN_TEXT), /atom/movable/screen/text/screen_text/picture/blackop)

/obj/docking_port/mobile/crashmode/initiate_docking(obj/docking_port/stationary/new_dock, movement_direction, force=FALSE)
	. = ..()
	if(. != DOCKING_SUCCESS)
		return
	SSminimaps.redraw_map(z)

/obj/docking_port/stationary/crashmode/hangar
	name = "Hangar Pad One"
	id = "canterbury"
	roundstart_template = /datum/map_template/shuttle/tgs_canterbury

/obj/docking_port/mobile/crashmode/bigbury
	name = "TGS Bigbury"
	dir = SOUTH
	width = 19
	height = 31
	dwidth = 9
	dheight = 15
