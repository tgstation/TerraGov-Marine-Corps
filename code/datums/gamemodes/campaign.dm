#define CAMPAIGN_MAX_VICTORY_POINTS 12

/datum/game_mode/hvh/campaign
	name = "Campaign"
	config_tag = "Campaign"
	flags_round_type = MODE_TWO_HUMAN_FACTIONS|MODE_HUMAN_ONLY|MODE_TWO_HUMAN_FACTIONS //any changes needed? MODE_LATE_OPENING_SHUTTER_TIMER handled by rounds
	shutters_drop_time = 2 MINUTES //will need changing
	whitelist_ship_maps = list(MAP_COMBAT_PATROL_BASE) //need changing to these lists
	blacklist_ship_maps = null
	blacklist_ground_maps = list(MAP_WHISKEY_OUTPOST, MAP_OSCAR_OUTPOST)
	bioscan_interval = 3 MINUTES
	///The current round type being played
	var/datum/game_round/current_round = /datum/game_round/tdm
	///campaign stats organised by faction
	var/list/datum/faction_stats/stat_list = list()

/datum/game_mode/hvh/campaign/New()
	. = ..()
	for(var/faction in factions)
		stat_list[faction] = new /datum/faction_stats(faction)

/datum/game_mode/hvh/campaign/announce()
	to_chat(world, "<b>The current game mode is - Campaign!</b>")
	to_chat(world, "<b>The TGMC and SOM both lay claim to this planet. Across contested areas, small combat patrols frequently clash in their bid to enforce their respective claims. Seek and destroy any hostiles you encounter, good hunting!</b>")
	to_chat(world, "<b>WIP, report bugs on the github!</b>")

/datum/game_mode/hvh/campaign/pre_setup()
	. = ..()

/datum/game_mode/hvh/campaign/post_setup()
	. = ..()
	for(var/obj/effect/landmark/patrol_point/exit_point AS in GLOB.patrol_point_list) //normal ground map is still loaded, will need to see if we can even stop that...
		qdel(exit_point)
 	load_new_round(current_round, factions[1]) //we store the initial round in current_round. This might work better in post_setup, needs testing

	for(var/i in stat_list)
		var/datum/faction_stats/selected_faction = stat_list[i]
		selected_faction.choose_faction_leader()

/datum/game_mode/hvh/campaign/setup_blockers() //to be updated
	. = ..()
	addtimer(CALLBACK(SSticker.mode, TYPE_PROC_REF(/datum/game_mode/hvh/campaign, intro_sequence)), SSticker.round_start_time + shutters_drop_time) //starts intro sequence 10 seconds before shutter drop

/datum/game_mode/hvh/campaign/intro_sequence() //update this, new fluff message etc etc, make it faction generic
	var/op_name_tgmc = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	var/op_name_som = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == factions[1])
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_tgmc]</u></span><br>" + "campaign intro here<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Territorial Defense Force Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/tdf)
		else //assuming only 2 factions
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_som]</u></span><br>" + "campaign intro here<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Shokk Infantry Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/shokk)

/datum/game_mode/hvh/campaign/process()
	if(round_finished)
		return PROCESS_KILL

	if(!istype(current_round))  //runtimes as process happens before post_setup, probably need a better method
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_BIOSCAN) || bioscan_interval == 0 || current_round.round_state != GAME_ROUND_STATE_ACTIVE)
		return
	announce_bioscans_marine_som() //todo: make this faction neutral

//End game checks
/datum/game_mode/hvh/campaign/check_finished(game_status) //todo: add the actual logic once the persistance stuff is done
	if(round_finished)
		message_admins("check_finished called when game already over")
		return TRUE

	//placeholder/fall back win condition
	for(var/faction in factions)
		if(stat_list[faction].victory_points >= CAMPAIGN_MAX_VICTORY_POINTS)
			switch(faction)
				if(FACTION_SOM)
					round_finished = MODE_COMBAT_PATROL_SOM_MINOR
				if(FACTION_TERRAGOV)
					round_finished = MODE_COMBAT_PATROL_MARINE_MINOR
			message_admins("Round finished: [round_finished]")
			return TRUE

/datum/game_mode/hvh/campaign/declare_completion() //todo: update fluff message
	. = ..()
	to_chat(world, span_round_header("|[round_finished]|"))
	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal TGMC spawned: [GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV]]\nTotal SOM spawned: [GLOB.round_statistics.total_humans_created[FACTION_SOM]]")
	to_chat(world, span_round_body("Thus ends the story of the brave men and women of both the TGMC and SOM, and their struggle on [SSmapping.configs[GROUND_MAP].map_name]."))

///selects the next round to be played
/datum/game_mode/hvh/campaign/proc/select_next_round(mob/selector) //basic placeholder
	var/choice = tgui_input_list(selector, "What course of action would you like to take?", "Mission selection", stat_list[selector.faction].potential_rounds, timeout = 2 MINUTES)
	if(!choice)
		choice = pick(stat_list[selector.faction].potential_rounds) //placeholder pick
	//probably have some time limit on the choice, so need some logic for that
	load_new_round(choice, selector.faction)

	select_attrition_points() //both teams choose the number of lads to commit

///sets up the newly selected round
/datum/game_mode/hvh/campaign/proc/load_new_round(datum/game_round/new_round, acting_faction)
	current_round = new new_round(acting_faction)
	TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, bioscan_interval)

///each faction chooses how many attrition points to use for the upcoming round
/datum/game_mode/hvh/campaign/proc/select_attrition_points() //placeholder basic
	for(var/i in stat_list)
		var/datum/faction_stats/team = stat_list[i]
		var/choice = tgui_input_number(team.faction_leader, "How much manpower would you like to dedicate to this mission?", "Attrition Point selection", 0, team.total_attrition_points, 0, 60 SECONDS)
		if(!choice)
			choice = 0
		team.total_attrition_points -= choice
		team.active_attrition_points = choice //unused points are lost

///ends the current round and cleans up
/datum/game_mode/hvh/campaign/proc/end_current_round()
	if(check_finished()) //check if the game should end
		return
	send_global_signal(COMSIG_GLOB_CLOSE_TIMED_SHUTTERS)

	for(var/faction in factions)
		for(var/mob/living/carbon/human/human_mob AS in GLOB.alive_human_list_faction[faction]) //forcemove everyone by faction back to their spawn points, to clear out the z-level
			human_mob.revive(TRUE)
			human_mob.forceMove(pick(GLOB.spawns_by_job[human_mob.job.type]))

	for(var/obj/effect/landmark/patrol_point/exit_point AS in GLOB.patrol_point_list)
		qdel(exit_point) //purge all existing links, cutting off the current ground map. Start point links are auto severed, and will reconnect to new points when a new map is loaded and upon use.

	//add a delay probably
	select_next_round(stat_list[current_round.winning_faction].get_selector()) //winning team chooses new round

///respawns the player if attrition points are available
/datum/game_mode/hvh/campaign/proc/attrition_respawn(mob/candidate) //this literally respawns the player. A more elegant solution would be to directly give them the job selection menu etc...
	if(!(candidate.faction in factions))
		return FALSE

	if(stat_list[candidate.faction].active_attrition_points <= 0)
		return FALSE

	if(!candidate?.client)
		return FALSE
	candidate.client.screen.Cut()
	if(!candidate?.client)
		return FALSE

	var/mob/new_player/M = new /mob/new_player()
	M.faction = candidate.faction
	if(!candidate?.client)
		qdel(M)
		return FALSE

	M.key = candidate.key
	stat_list[candidate.faction].active_attrition_points --
	M.late_choices() //just opens the window. todo: look into how feasible it is to directly give the ghost the job selection menu and all the follow up, probably not
