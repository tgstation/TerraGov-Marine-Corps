/datum/game_mode/hvh/campaign
	name = "Campaign"
	config_tag = "Campaign"
	flags_round_type = MODE_LATE_OPENING_SHUTTER_TIMER|MODE_TWO_HUMAN_FACTIONS|MODE_HUMAN_ONLY|MODE_TWO_HUMAN_FACTIONS //any changes needed?
	shutters_drop_time = 3 MINUTES //will need changing
	whitelist_ship_maps = list(MAP_COMBAT_PATROL_BASE) //need changing to these lists
	blacklist_ship_maps = null
	blacklist_ground_maps = list(MAP_WHISKEY_OUTPOST, MAP_OSCAR_OUTPOST)
	bioscan_interval = 3 MINUTES

/datum/game_mode/hvh/campaign/announce()
	to_chat(world, "<b>The current game mode is - Combat Patrol!</b>")
	to_chat(world, "<b>The TGMC and SOM both lay claim to this planet. Across contested areas, small combat patrols frequently clash in their bid to enforce their respective claims. Seek and destroy any hostiles you encounter, good hunting!</b>")
	to_chat(world, "<b>WIP, report bugs on the github!</b>")

/datum/game_mode/hvh/campaign/setup_blockers() //to be updated
	. = ..()
	//Starts the round timer when the game starts proper
	//var/datum/game_mode/hvh/campaign/D = SSticker.mode
	//addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode/hvh/campaign, respawn_wave)), SSticker.round_start_time + shutters_drop_time) //starts wave respawn on shutter drop and begins timer
	//addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode/hvh/campaign, intro_sequence)), SSticker.round_start_time + shutters_drop_time - 10 SECONDS) //starts intro sequence 10 seconds before shutter drop
	//TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, SSticker.round_start_time + shutters_drop_time + bioscan_interval)

/datum/game_mode/hvh/campaign/intro_sequence() //update this, new fluff message etc etc
	var/op_name_tgmc = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	var/op_name_som = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == FACTION_TERRAGOV)
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_tgmc]</u></span><br>" + "[SSmapping.configs[GROUND_MAP].map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Territorial Defense Force Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/tdf)
		else
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_som]</u></span><br>" + "[SSmapping.configs[GROUND_MAP].map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Shokk Infantry Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/shokk)

//End game checks
/datum/game_mode/hvh/campaign/check_finished(game_status) //todo: add the actual logic once the persistance stuff is done
	if(!round_finished)
		return FALSE

	//switch(round_finished)
	//	if(MODE_COMBAT_PATROL_SOM_MAJOR)

	//	if(MODE_COMBAT_PATROL_SOM_MINOR)

	//	if(MODE_COMBAT_PATROL_MARINE_MAJOR)

	//	if(MODE_COMBAT_PATROL_MARINE_MINOR)

	//	if(MODE_COMBAT_PATROL_DRAW)

	message_admins("Round finished: [round_finished]")
	return TRUE

/datum/game_mode/hvh/campaign/declare_completion() //todo: update fluff message
	. = ..()
	to_chat(world, span_round_header("|[round_finished]|"))
	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal TGMC spawned: [GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV]]\nTotal SOM spawned: [GLOB.round_statistics.total_humans_created[FACTION_SOM]]")
	to_chat(world, span_round_body("Thus ends the story of the brave men and women of both the TGMC and SOM, and their struggle on [SSmapping.configs[GROUND_MAP].map_name]."))

///Generates a new z level for the round
/datum/game_mode/hvh/campaign/campaign/proc/load_new_map(file, name)
	var/datum/space_level/new_level = load_new_z_level(file, name)
	SSminimaps.generate_minimap(new_level.z_value)
	set_lighting(new_level.z_value)
