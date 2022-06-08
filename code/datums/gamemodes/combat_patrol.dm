/datum/game_mode/combat_patrol
	name = "Combat patrol"
	config_tag = "Combat patrol"
	flags_round_type = MODE_LZ_SHUTTERS|MODE_TWO_HUMAN_FACTIONS|MODE_HUMAN_ONLY //MODE_NO_PERMANENT_WOUNDS is for nerds //also need to unfuck mode_two_human_factions, as it ties into a lot of things
	flags_landmarks = MODE_LANDMARK_SPAWN_SPECIFIC_SHUTTLE_CONSOLE
	shutters_drop_time = 5 MINUTES
	flags_xeno_abilities = ABILITY_CRASH
	respawn_time = 10 MINUTES
	time_between_round = 0 HOURS
	/// Timer used to calculate how long till round ends
	var/game_timer
	//todo: add more som roles
	valid_job_types = list(
		///datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/squad/engineer = 4,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 2,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/som/squad/leader = 4,
		/datum/job/som/squad/veteran = 4,
		/datum/job/som/squad/engineer = 4,
		/datum/job/som/squad/medic = 8,
		/datum/job/som/squad/standard = -1,
	)

/datum/game_mode/combat_patrol/post_setup()
	. = ..()
	for(var/area/area_to_lit AS in GLOB.sorted_areas)
		var/turf/first_turf = area_to_lit.contents[1]
		if(first_turf.z != 2)
			continue
		switch(area_to_lit.ceiling)
			if(CEILING_NONE to CEILING_GLASS)
				area_to_lit.set_base_lighting(COLOR_WHITE, 255)
			if(CEILING_METAL)
				area_to_lit.set_base_lighting(COLOR_WHITE, 150)
			if(CEILING_UNDERGROUND to CEILING_UNDERGROUND_METAL)
				area_to_lit.set_base_lighting(COLOR_WHITE, 50)
	GLOB.join_as_robot_allowed = FALSE

/datum/game_mode/combat_patrol/announce()
	to_chat(world, "<b>The current game mode is - Combat Patrol!</b>")
	to_chat(world, "<b>The TGMC and SOM both lay claim to this planet. Across contested areas, small combat patrols frequently clash in their bid to enforce their respective claims. Seek and destroy any hostiles you encounter, good hunting!</b>")
	to_chat(world, "<b>WIP, report bugs on the github!</b>")



//sets TGMC and SOM squads
/datum/game_mode/combat_patrol/set_valid_squads()
	SSjob.active_squads[FACTION_TERRAGOV] = list()
	SSjob.active_squads[FACTION_SOM] = list()
	for(var/key in SSjob.squads)
		var/datum/squad/squad = SSjob.squads[key]
		if(squad.faction == FACTION_TERRAGOV || squad.faction == FACTION_SOM) //We only want Marine and SOM squads, future proofs if more faction squads are added
			SSjob.active_squads[squad.faction] += squad
	return TRUE

/datum/game_mode/combat_patrol/get_joinable_factions(should_look_balance)
	if(should_look_balance)
		if(length(GLOB.alive_human_list_faction[FACTION_TERRAGOV]) > length(GLOB.alive_human_list_faction[FACTION_SOM]) * MAX_UNBALANCED_RATIO_TWO_HUMAN_FACTIONS)
			return list(FACTION_SOM)
		if(length(GLOB.alive_human_list_faction[FACTION_SOM]) > length(GLOB.alive_human_list_faction[FACTION_TERRAGOV]) * MAX_UNBALANCED_RATIO_TWO_HUMAN_FACTIONS)
			return list(FACTION_TERRAGOV)
	return list(FACTION_TERRAGOV, FACTION_SOM)

/datum/game_mode/combat_patrol/setup_blockers()
	. = ..()
	//Starts the round timer when the game starts proper
	var/datum/game_mode/combat_patrol/D = SSticker.mode
	addtimer(CALLBACK(D, /datum/game_mode/combat_patrol.proc/set_game_timer), SSticker.round_start_time + shutters_drop_time)

///round timer - this probably doesn't need to have some of this stuff
/datum/game_mode/combat_patrol/proc/set_game_timer()
	if(!iscombatpatrolgamemode(SSticker.mode))
		return
	var/datum/game_mode/combat_patrol/D = SSticker.mode

	if(D.game_timer)
		return

	D.game_timer = addtimer(CALLBACK(D, /datum/game_mode/combat_patrol.proc/check_finished), 40 MINUTES, TIMER_STOPPABLE)

/datum/game_mode/combat_patrol/game_end_countdown()
	if(!game_timer)
		return
	var/eta = timeleft(game_timer) * 0.1
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_leading(num2text(eta % 60), 2, "0")]"

///checks how many marines and SOM are still alive
/datum/game_mode/combat_patrol/proc/count_humans(list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND, ZTRAIT_RESERVED)), count_flags)
	//todo: replace main_ship and reserved (marine ship and transit) with home base shit

	///number of TGMC alive
	var/num_marines = 0
	///number of SOM alive
	var/num_som = 0
	///number of TGMC killed - excludes gibbed if that functionality somehow gets added
	var/num_dead_marines = 0
	///number of SOM killed - excludes gibbed if that functionality somehow gets added
	var/num_dead_som = 0

	for(var/z in z_levels)
		//counts the live marines and SOM
		for(var/i in GLOB.humans_by_zlevel["[z]"])
			var/mob/living/carbon/human/H = i
			if(!istype(H)) // Small fix?
				continue
			if(count_flags & COUNT_IGNORE_HUMAN_SSD && !H.client)
				continue
			if(H.status_flags & XENO_HOST)
				continue
			if(H.faction == FACTION_XENO)
				continue
			if(isspaceturf(H.loc)) //not certain why this is here...
				continue
			if(H.faction == FACTION_SOM)
				num_som++
			if(H.faction == FACTION_TERRAGOV)
				num_marines++
	//counts the dead marines and SOM
	for(var/i in GLOB.dead_human_list)
		var/mob/living/carbon/human/H = i
		if(!istype(H)) //I'm not certain if this needs to be here
			continue
		if(H.faction == FACTION_XENO)
			continue
		if(isspaceturf(H.loc)) //not certain why this is here...
			continue
		if(H.faction == FACTION_SOM)
			num_dead_som++
		if(H.faction == FACTION_TERRAGOV)
			num_dead_marines++

	return list(num_marines, num_som, num_dead_marines, num_dead_som)

//End game checks
/datum/game_mode/combat_patrol/check_finished()
	if(round_finished)
		return TRUE

	if(SSmonitor.gamestate != GROUNDSIDE) //check what this does, probs means marines haven't landed yet for civil war
		return

	///pulls the number of marines and SOM, both dead and alive
	var/living_player_list[] = count_humans(count_flags = COUNT_IGNORE_ALIVE_SSD)
	var/num_marines = living_player_list[1]
	var/num_som = living_player_list[2]
	var/num_dead_marines = living_player_list[3]
	var/num_dead_som = living_player_list[4]

	//major victor for wiping out the enemy, or draw if both sides wiped simultaneously somehow
	if(!num_marines)
		if(!num_som)
			message_admins("Round finished: [MODE_COMBAT_PATROL_DRAW]") //everyone died at the same time, no one wins
			round_finished = MODE_COMBAT_PATROL_DRAW
			return TRUE
		message_admins("Round finished: [MODE_SOM_SOM_MAJOR]") //SOM wiped out ALL the marines, SOM major victory
		round_finished = MODE_SOM_SOM_MAJOR
		return TRUE

	if(!num_som)
		message_admins("Round finished: [MODE_SOM_MARINE_MAJOR]") //Marines wiped out ALL the SOM, marine major victory
		round_finished = MODE_SOM_MARINE_MAJOR
		return TRUE

	//minor victories for more kills or draw for equal kills
	if(num_dead_marines > num_dead_som)
		message_admins("Round finished: [MODE_SOM_SOM_MINOR]") //The SOM inflicted greater casualties on the marines, SOM minor victory
		round_finished = MODE_SOM_SOM_MINOR
		return TRUE
	if(num_dead_som > num_dead_marines)
		message_admins("Round finished: [MODE_SOM_MARINE_MINOR]") //The marines inflicted greater casualties on the SOM, marine minor victory
		round_finished = MODE_SOM_MARINE_MINOR
		return TRUE

	message_admins("Round finished: [MODE_COMBAT_PATROL_DRAW]") //equal number of kills, or any other edge cases
	round_finished = MODE_COMBAT_PATROL_DRAW
	return TRUE


/datum/game_mode/combat_patrol/declare_completion()
	. = ..()
	to_chat(world, span_round_header("|[round_finished]|"))
	to_chat(world, span_round_body("Thus ends the story of the brave men and women of both the TGMC and SOM, and their struggle on [SSmapping.configs[GROUND_MAP].map_name]."))

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

	announce_medal_awards()
	announce_round_stats()
