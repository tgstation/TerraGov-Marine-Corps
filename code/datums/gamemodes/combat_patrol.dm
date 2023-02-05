/datum/game_mode/combat_patrol
	name = "Combat Patrol"
	config_tag = "Combat Patrol"
	flags_round_type = MODE_LZ_SHUTTERS|MODE_TWO_HUMAN_FACTIONS|MODE_HUMAN_ONLY|MODE_SOM_OPFOR //MODE_NO_PERMANENT_WOUNDS is for nerds
	flags_landmarks = MODE_LANDMARK_SPAWN_SPECIFIC_SHUTTLE_CONSOLE
	shutters_drop_time = 3 MINUTES
	flags_xeno_abilities = ABILITY_CRASH
	time_between_round = 0 HOURS
	factions = list(FACTION_TERRAGOV, FACTION_SOM)
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
	whitelist_ship_maps = list(MAP_COMBAT_PATROL_BASE)
	blacklist_ship_maps = null
	blacklist_ground_maps = list(MAP_WHISKEY_OUTPOST, MAP_OSCAR_OUTPOST)
	/// Timer used to calculate how long till round ends
	var/game_timer
	///The length of time until round ends.
	var/max_game_time = 35 MINUTES
	/// Timer used to calculate how long till next respawn wave
	var/wave_timer
	///The length of time until next respawn wave.
	var/wave_timer_length = 5 MINUTES
	///Whether the max game time has been reached
	var/max_time_reached = FALSE
	/// Time between two bioscan
	var/bioscan_interval = 3 MINUTES
	///Delay from shutter drop until game timer starts
	var/game_timer_delay = 5 MINUTES


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
				area_to_lit.set_base_lighting(COLOR_WHITE, 50)
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
	addtimer(CALLBACK(D, /datum/game_mode/combat_patrol.proc/set_game_timer), SSticker.round_start_time + shutters_drop_time + game_timer_delay) //game cannot end until at least 5 minutes after shutter drop
	addtimer(CALLBACK(D, /datum/game_mode/combat_patrol.proc/respawn_wave), SSticker.round_start_time + shutters_drop_time) //starts wave respawn on shutter drop and begins timer
	addtimer(CALLBACK(D, /datum/game_mode/combat_patrol.proc/intro_sequence), SSticker.round_start_time + shutters_drop_time - 10 SECONDS) //starts intro sequence 10 seconds before shutter drop
	TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, SSticker.round_start_time + shutters_drop_time + bioscan_interval)

///plays the intro sequence
/datum/game_mode/combat_patrol/proc/intro_sequence()
	var/op_name_tgmc = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	var/op_name_som = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == FACTION_TERRAGOV)
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_tgmc]</u></span><br>" + "[SSmapping.configs[GROUND_MAP].map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Territorial Defense Force Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/tdf)
		else
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_som]</u></span><br>" + "[SSmapping.configs[GROUND_MAP].map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Shokk Infantry Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/shokk)

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

/datum/game_mode/combat_patrol/wave_countdown()
	if(!wave_timer)
		return
	var/eta = timeleft(wave_timer) * 0.1
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_leading(num2text(eta % 60), 2, "0")]"

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
	D.wave_timer = addtimer(CALLBACK(D, /datum/game_mode/combat_patrol.proc/respawn_wave), wave_timer_length, TIMER_STOPPABLE)

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/M = i
		GLOB.key_to_time_of_role_death[M.key] -= respawn_time
		M.playsound_local(M, 'sound/ambience/votestart.ogg', 75, 1)
		M.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>RESPAWN WAVE AVAILABLE</u></span><br>" + "YOU CAN NOW RESPAWN.", /atom/movable/screen/text/screen_text/command_order)
		to_chat(M, "<br><font size='3'>[span_attack("Reinforcements are gathering to join the fight, you can now respawn to join a fresh patrol!")]</font><br>")

///checks how many marines and SOM are still alive
/datum/game_mode/combat_patrol/proc/count_humans(list/z_levels = SSmapping.levels_by_trait(ZTRAIT_GROUND), count_flags)
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

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal TGMC spawned: [GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV]]\nTotal SOM spawned: [GLOB.round_statistics.total_humans_created[FACTION_SOM]]")

	announce_medal_awards()
	announce_round_stats()

/datum/game_mode/combat_patrol/announce_round_stats()
	//sets up some stats which are added if applicable
	var/tgmc_survival_stat
	var/som_survival_stat
	var/tgmc_accuracy_stat
	var/som_accuracy_stat

	if(GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV])
		if(GLOB.round_statistics.total_human_revives[FACTION_TERRAGOV])
			tgmc_survival_stat = "[GLOB.round_statistics.total_human_revives[FACTION_TERRAGOV]] were revived, for a [(GLOB.round_statistics.total_human_revives[FACTION_TERRAGOV] / max(GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV], 1)) * 100]% revival rate and a [((GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV] + GLOB.round_statistics.total_human_revives[FACTION_TERRAGOV] - GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV]) / GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV]) * 100]% survival rate."
		else
			tgmc_survival_stat = "None were revived, for a [((GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV] - GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV]) / GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV]) * 100]% survival rate."
	if(GLOB.round_statistics.total_human_deaths[FACTION_SOM])
		if(GLOB.round_statistics.total_human_revives[FACTION_SOM])
			som_survival_stat = "[GLOB.round_statistics.total_human_revives[FACTION_SOM]] were revived, for a [(GLOB.round_statistics.total_human_revives[FACTION_SOM] / max(GLOB.round_statistics.total_human_deaths[FACTION_SOM], 1)) * 100]% revival rate and a [((GLOB.round_statistics.total_humans_created[FACTION_SOM] + GLOB.round_statistics.total_human_revives[FACTION_SOM] - GLOB.round_statistics.total_human_deaths[FACTION_SOM]) / GLOB.round_statistics.total_humans_created[FACTION_SOM]) * 100]% survival rate."
		else
			som_survival_stat = "None were revived, for a [((GLOB.round_statistics.total_humans_created[FACTION_SOM] - GLOB.round_statistics.total_human_deaths[FACTION_SOM]) / GLOB.round_statistics.total_humans_created[FACTION_SOM]) * 100]% survival rate."
	if(GLOB.round_statistics.total_projectile_hits[FACTION_SOM] && GLOB.round_statistics.total_projectiles_fired[FACTION_TERRAGOV])
		tgmc_accuracy_stat = ", for an accuracy of [(GLOB.round_statistics.total_projectile_hits[FACTION_SOM] / GLOB.round_statistics.total_projectiles_fired[FACTION_TERRAGOV]) * 100]%!."
	if(GLOB.round_statistics.total_projectile_hits[FACTION_TERRAGOV] && GLOB.round_statistics.total_projectiles_fired[FACTION_SOM])
		som_accuracy_stat = ", for an accuracy of [(GLOB.round_statistics.total_projectile_hits[FACTION_TERRAGOV] / GLOB.round_statistics.total_projectiles_fired[FACTION_SOM]) * 100]%!."

	var/list/dat = list({"[span_round_body("The end of round statistics are:")]<br>
		<br>[GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV]] TGMC personel deployed for the patrol, and [GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV] ? GLOB.round_statistics.total_human_deaths[FACTION_TERRAGOV] : "no"] TGMC personel were killed. [tgmc_survival_stat ? tgmc_survival_stat : ""]
		<br>[GLOB.round_statistics.total_humans_created[FACTION_SOM]] SOM personel deployed for the patrol, and [GLOB.round_statistics.total_human_deaths[FACTION_SOM] ? GLOB.round_statistics.total_human_deaths[FACTION_SOM] : "no"] SOM personel were killed. [som_survival_stat ? som_survival_stat : ""]
		<br>The TGMC fired [GLOB.round_statistics.total_projectiles_fired[FACTION_TERRAGOV] ? GLOB.round_statistics.total_projectiles_fired[FACTION_TERRAGOV] : "no"] projectiles. [GLOB.round_statistics.total_projectile_hits[FACTION_SOM] ? GLOB.round_statistics.total_projectile_hits[FACTION_SOM] : "No"] projectiles managed to hit members of the SOM[tgmc_accuracy_stat ? tgmc_accuracy_stat : "."]
		<br>The SOM fired [GLOB.round_statistics.total_projectiles_fired[FACTION_SOM] ? GLOB.round_statistics.total_projectiles_fired[FACTION_SOM] : "no"] projectiles. [GLOB.round_statistics.total_projectile_hits[FACTION_TERRAGOV] ? GLOB.round_statistics.total_projectile_hits[FACTION_TERRAGOV] : "No"] projectiles managed to hit members of the TGMC[som_accuracy_stat ? som_accuracy_stat : "."]
		"})
	if(GLOB.round_statistics.grenades_thrown)
		dat += "[GLOB.round_statistics.grenades_thrown] grenades were detonated."
	else
		dat += "No grenades exploded."

	var/output = jointext(dat, "<br>")
	for(var/mob/player in GLOB.player_list)
		if(player?.client?.prefs?.toggles_chat & CHAT_STATISTICS)
			to_chat(player, output)
