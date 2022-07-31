/datum/game_mode/combat_patrol
	name = "Combat Patrol"
	config_tag = "Combat Patrol"
	flags_round_type = MODE_LZ_SHUTTERS|MODE_TWO_HUMAN_FACTIONS|MODE_HUMAN_ONLY|MODE_SOM_OPFOR|MODE_SPECIFIC_SHIP_MAP //MODE_NO_PERMANENT_WOUNDS is for nerds
	flags_landmarks = MODE_LANDMARK_SPAWN_SPECIFIC_SHUTTLE_CONSOLE
	shutters_drop_time = 5 MINUTES
	flags_xeno_abilities = ABILITY_CRASH
	respawn_time = 6 MINUTES
	time_between_round = 0 HOURS
	valid_job_types = list(
		/datum/job/terragov/squad/engineer = 4,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 4,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/som/squad/leader = 4,
		/datum/job/som/squad/veteran = 2,
		/datum/job/som/squad/engineer = 4,
		/datum/job/som/squad/medic = 8,
		/datum/job/som/squad/standard = -1,
	)
	/// Timer used to calculate how long till round ends
	var/game_timer
	///The length of time until round ends.
	var/max_game_time = 35 MINUTES
	///The length of time until next wave.
	var/wave_timer = 5 MINUTES
	///Whether the max game time has been reached
	var/max_time_reached = FALSE
	/// Time between two bioscan
	var/bioscan_interval = 5 MINUTES

/datum/game_mode/combat_patrol/post_setup()
	. = ..()
	for(var/area/area_to_lit AS in GLOB.sorted_areas)
		switch(area_to_lit.ceiling)
			if(CEILING_NONE to CEILING_GLASS)
				area_to_lit.set_base_lighting(COLOR_WHITE, 200)
			if(CEILING_METAL)
				area_to_lit.set_base_lighting(COLOR_WHITE, 100)
			if(CEILING_UNDERGROUND to CEILING_UNDERGROUND_METAL)
				area_to_lit.set_base_lighting(COLOR_WHITE, 75)
			if(CEILING_DEEP_UNDERGROUND to CEILING_DEEP_UNDERGROUND_METAL)
				area_to_lit.set_base_lighting(COLOR_WHITE, 25)
	GLOB.join_as_robot_allowed = FALSE

/datum/game_mode/combat_patrol/scale_roles()
	. = ..()
	if(!.)
		return
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/som/squad/veteran)
	scaled_job.job_points_needed  = 5 //Every 5 non vets join, a new vet slot opens

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
	addtimer(CALLBACK(D, /datum/game_mode/combat_patrol.proc/set_game_timer), SSticker.round_start_time + shutters_drop_time + 5 MINUTES) //game cannot end until at least 5 minutes after shutter drop
	addtimer(CALLBACK(D, /datum/game_mode/combat_patrol.proc/respawn_wave), SSticker.round_start_time + shutters_drop_time + wave_timer) //first respawn wave is 5 minutes after shutters
	TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, SSticker.round_start_time + shutters_drop_time + 5 MINUTES)

///round timer
/datum/game_mode/combat_patrol/proc/set_game_timer()
	if(!iscombatpatrolgamemode(SSticker.mode))
		return
	var/datum/game_mode/combat_patrol/D = SSticker.mode

	if(D.game_timer)
		return

	D.game_timer = addtimer(CALLBACK(D, /datum/game_mode/combat_patrol.proc/set_game_end), max_game_time, TIMER_STOPPABLE)

/datum/game_mode/combat_patrol/game_end_countdown()
	if(!game_timer)
		return
	var/eta = timeleft(game_timer) * 0.1
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_leading(num2text(eta % 60), 2, "0")]"
	else
		return "Patrol finished"

/datum/game_mode/combat_patrol/proc/set_game_end()
	max_time_reached = TRUE

/datum/game_mode/combat_patrol/process()
	if(round_finished)
		return PROCESS_KILL

	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_BIOSCAN) || bioscan_interval == 0)
		return
	announce_bioscans_marine_som()

// make sure you don't turn 0 into a false positive
#define BIOSCAN_DELTA(count, delta) count ? max(0, count + rand(-delta, delta)) : 0

///Annonce to everyone the number of xeno and marines on ship and ground
/datum/game_mode/combat_patrol/proc/announce_bioscans_marine_som(show_locations = TRUE, delta = 2, announce_marines = TRUE, announce_som = TRUE)
	TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, bioscan_interval)
	//pulls the number of marines and SOM
	var/list/player_list = count_humans(count_flags = COUNT_IGNORE_ALIVE_SSD)
	var/list/som_list = player_list[1]
	var/list/tgmc_list = player_list[2]
	var/num_som = length(player_list[1])
	var/num_tgmc = length(player_list[2])
	var/tgmc_location
	var/som_location

	if(num_som)
		som_location = get_area(pick(player_list[1]))
	if(num_tgmc)
		tgmc_location = get_area(pick(player_list[2]))

	//Adjust the randomness there so everyone gets the same thing
	var/num_tgmc_delta = BIOSCAN_DELTA(num_tgmc, delta)
	var/num_som_delta = BIOSCAN_DELTA(num_som, delta)

	//announcement for SOM
	var/som_scan_name = "Long Range Tactical Bioscan Status"
	var/som_scan_input = {"Bioscan complete.

Sensors indicate [num_tgmc_delta || "no"] unknown lifeform signature[num_tgmc_delta > 1 ? "s":""] present in the area of operations[tgmc_location ? ", including one at: [tgmc_location]":""]"}

	if(announce_som)
		priority_announce(som_scan_input, som_scan_name, sound = 'sound/AI/bioscan.ogg', receivers = (som_list + GLOB.observer_list))

	//announcement for TGMC
	var/marine_scan_name = "Long Range Tactical Bioscan Status"
	var/marine_scan_input = {"Bioscan complete.

Sensors indicate [num_som_delta || "no"] unknown lifeform signature[num_som_delta > 1 ? "s":""] present in the area of operations[som_location ? ", including one at: [som_location]":""]"}

	if(announce_marines)
		priority_announce(marine_scan_input, marine_scan_name, sound = 'sound/AI/bioscan.ogg', receivers = (tgmc_list + GLOB.observer_list))

	log_game("Bioscan. [num_tgmc] active TGMC personnel[tgmc_location ? " Location: [tgmc_location]":""] and [num_som] active SOM personnel[som_location ? " Location: [som_location]":""]")

	for(var/i in GLOB.observer_list)
		var/mob/M = i
		to_chat(M, "<h2 class='alert'>Detailed Information</h2>")
		to_chat(M, {"<span class='alert'>[num_som] SOM alive.
[num_tgmc] Marine\s alive."})

	message_admins("Bioscan - Marines: [num_tgmc] active TGMC personnel[tgmc_location ? " .Location:[tgmc_location]":""]")
	message_admins("Bioscan - SOM: [num_som] active SOM personnel[som_location ? " .Location:[som_location]":""]")

#undef BIOSCAN_DELTA

///Allows all the dead to respawn together
/datum/game_mode/combat_patrol/proc/respawn_wave()
	var/datum/game_mode/combat_patrol/D = SSticker.mode
	addtimer(CALLBACK(D, /datum/game_mode/combat_patrol.proc/respawn_wave), wave_timer)

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/M = i
		GLOB.key_to_time_of_role_death[M.key] = 0
		M.playsound_local(M, 'sound/ambience/votestart.ogg', 75, 1)
		M.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>RESPAWN WAVE AVAILABLE</u></span><br>" + "YOU CAN NOW RESPAWN.", /obj/screen/text/screen_text/command_order)
		to_chat(M, "<br><font size='3'>[span_attack("Reinforcements are gathering to join the fight, you can now respawn to join a fresh patrol!")]</font><br>")

///checks how many marines and SOM are still alive
/datum/game_mode/combat_patrol/proc/count_humans(list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_GROUND)), count_flags)
	var/list/som_alive = list()
	var/list/som_dead = list()
	var/list/tgmc_alive = list()
	var/list/tgmc_dead = list()

	for(var/z in z_levels)
		//counts the live marines and SOM
		for(var/i in GLOB.humans_by_zlevel["[z]"])
			var/mob/living/carbon/human/H = i
			if(!istype(H))
				continue
			if(count_flags & COUNT_IGNORE_HUMAN_SSD && !H.client)
				continue
			if(H.faction == FACTION_SOM)
				som_alive += H
			else if(H.faction == FACTION_TERRAGOV)
				tgmc_alive += H
	//counts the dead marines and SOM
	for(var/i in GLOB.dead_human_list)
		var/mob/living/carbon/human/H = i
		if(!istype(H))
			continue
		if(H.faction == FACTION_SOM)
			som_dead += H
		else if(H.faction == FACTION_TERRAGOV)
			tgmc_dead += H

	return list(som_alive, tgmc_alive, som_dead, tgmc_dead)

//End game checks
/datum/game_mode/combat_patrol/check_finished()
	if(round_finished)
		return TRUE

	if(SSmonitor.gamestate != GROUNDSIDE || !game_timer)
		return

	///pulls the number of marines and SOM, both dead and alive
	var/list/player_list = count_humans(count_flags = COUNT_IGNORE_ALIVE_SSD)
	var/num_som = length(player_list[1])
	var/num_tgmc = length(player_list[2])
	var/num_dead_som = length(player_list[3])
	var/num_dead_marines = length(player_list[4])

	if(num_tgmc && num_som && !max_time_reached)
		return //fighting is ongoing

	//major victor for wiping out the enemy, or draw if both sides wiped simultaneously somehow
	if(!num_tgmc)
		if(!num_som)
			message_admins("Round finished: [MODE_COMBAT_PATROL_DRAW]") //everyone died at the same time, no one wins
			round_finished = MODE_COMBAT_PATROL_DRAW
			return TRUE
		message_admins("Round finished: [MODE_COMBAT_PATROL_SOM_MAJOR]") //SOM wiped out ALL the marines, SOM major victory
		round_finished = MODE_COMBAT_PATROL_SOM_MAJOR
		return TRUE

	if(!num_som)
		message_admins("Round finished: [MODE_COMBAT_PATROL_MARINE_MAJOR]") //Marines wiped out ALL the SOM, marine major victory
		round_finished = MODE_COMBAT_PATROL_MARINE_MAJOR
		return TRUE

	//minor victories for more kills or draw for equal kills
	if(num_dead_marines > num_dead_som)
		message_admins("Round finished: [MODE_COMBAT_PATROL_SOM_MINOR]") //The SOM inflicted greater casualties on the marines, SOM minor victory
		round_finished = MODE_COMBAT_PATROL_SOM_MINOR
		return TRUE
	if(num_dead_som > num_dead_marines)
		message_admins("Round finished: [MODE_COMBAT_PATROL_MARINE_MINOR]") //The marines inflicted greater casualties on the SOM, marine minor victory
		round_finished = MODE_COMBAT_PATROL_MARINE_MINOR
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
