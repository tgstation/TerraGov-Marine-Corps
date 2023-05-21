#define CAMPAIGN_MAX_VICTORY_POINTS 12

/datum/game_mode/hvh/campaign
	name = "Campaign"
	config_tag = "Campaign"
	flags_round_type = MODE_LATE_OPENING_SHUTTER_TIMER|MODE_TWO_HUMAN_FACTIONS|MODE_HUMAN_ONLY|MODE_TWO_HUMAN_FACTIONS //any changes needed?
	shutters_drop_time = 3 MINUTES //will need changing
	whitelist_ship_maps = list(MAP_COMBAT_PATROL_BASE) //need changing to these lists
	blacklist_ship_maps = null
	blacklist_ground_maps = list(MAP_WHISKEY_OUTPOST, MAP_OSCAR_OUTPOST)
	bioscan_interval = 3 MINUTES
	///The current round type being played
	var/datum/game_round/current_round
	///campaign stats organised by faction
	var/list/datum/faction_stats/stat_list = list()

//stats/points/etc recorded by faction
/datum/faction_stats
	///The faction associated with these stats
	var/faction
	///Victory points earned by this faction
	var/victory_points = 0
	///Dictates how many respawns this faction has access to overall
	var/supply_points = 30
	///Future rounds this faction can currently choose from
	var/list/datum/game_round/potential_rounds = list()
	///Rounds this faction has succesfully completed
	var/list/datum/game_round/finished_rounds = list()
	//probs add persistant rewards here as well

/datum/faction_stats/New(new_faction)
	. = ..()
	faction = new_faction

/datum/game_mode/hvh/campaign/New()
	. = ..()
	for(var/faction in factions)
		stat_list[faction] = new /datum/faction_stats(faction)

/datum/game_mode/hvh/campaign/announce()
	to_chat(world, "<b>The current game mode is - Campaign!</b>")
	to_chat(world, "<b>The TGMC and SOM both lay claim to this planet. Across contested areas, small combat patrols frequently clash in their bid to enforce their respective claims. Seek and destroy any hostiles you encounter, good hunting!</b>")
	to_chat(world, "<b>WIP, report bugs on the github!</b>")

/datum/game_mode/hvh/campaign/setup_blockers() //to be updated
	. = ..()
	//Starts the round timer when the game starts proper
	//var/datum/game_mode/hvh/campaign/D = SSticker.mode
	//addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode/hvh/campaign, respawn_wave)), SSticker.round_start_time + shutters_drop_time) //starts wave respawn on shutter drop and begins timer
	//addtimer(CALLBACK(D, TYPE_PROC_REF(/datum/game_mode/hvh/campaign, intro_sequence)), SSticker.round_start_time + shutters_drop_time - 10 SECONDS) //starts intro sequence 10 seconds before shutter drop
	//TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, SSticker.round_start_time + shutters_drop_time + bioscan_interval)

///datum/game_mode/hvh/campaign/intro_sequence() //update this, new fluff message etc etc
	//op_name_tgmc = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	//op_name_som = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	//for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
	//	if(human.faction == FACTION_TERRAGOV)
	//		human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_tgmc]</u></span><br>" + "[SSmapping.configs[GROUND_MAP].map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Territorial Defense Force Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/tdf)
	//	else
	//		human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_som]</u></span><br>" + "[SSmapping.configs[GROUND_MAP].map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Shokk Infantry Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/shokk)

//End game checks
/datum/game_mode/hvh/campaign/check_finished(game_status) //todo: add the actual logic once the persistance stuff is done
	//placeholder/fall back win condition
	for(var/faction in factions)
		if(stat_list[faction].victory_points >= CAMPAIGN_MAX_VICTORY_POINTS)
			switch(faction)
				if(FACTION_SOM)
					round_finished = MODE_COMBAT_PATROL_SOM_MINOR
				if(FACTION_TERRAGOV)
					round_finished = MODE_COMBAT_PATROL_MARINE_MINOR

	//if(!round_finished) //some assumptions here about key rounds hard setting the end
	//	return FALSE

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

///selects the next round to be played
/datum/game_mode/hvh/campaign/campaign/proc/select_next_round(mob/selector)
	var/choice = tgui_input_list(selector, "What course of action would you like to take?", "Mission selection", stat_list[selector.faction].potential_rounds) //needs ui linked
	if(!choice)
		return
	load_new_round(choice, selector.faction)

///sets up the newly selected round
/datum/game_mode/hvh/campaign/campaign/proc/load_new_round(datum/game_round/new_round, acting_faction)
	current_round = new new_round(acting_faction)
	var/datum/space_level/new_map = current_round.load_map()
	set_lighting(new_map.z_value)

	addtimer(CALLBACK(current_round, TYPE_PROC_REF(/datum/game_round, start_round)), current_round.shutter_delay)

///ends the current round and cleans up
/datum/game_mode/hvh/campaign/campaign/proc/end_current_round()
	send_global_signal(COMSIG_GLOB_CLOSE_TIMED_SHUTTERS)
	//forcemove everyone by faction back to their spawn points, to clear out the z-level
	//delete all existing patrol points
	current_round.apply_outcome() //todo: have this actually make sense
	check_finished() //check if the game should end
