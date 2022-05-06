/datum/game_mode/combat_patrol
	name = "Combat patrol"
	config_tag = "Combat patrol"
	flags_round_type = MODE_LZ_SHUTTERS|MODE_TWO_HUMAN_FACTIONS|MODE_HUMAN_ONLY|MODE_WIN_POINTS //MODE_NO_PERMANENT_WOUNDS is for nerds
	flags_landmarks = MODE_LANDMARK_SPAWN_SPECIFIC_SHUTTLE_CONSOLE
	shutters_drop_time = 5 MINUTES
	flags_xeno_abilities = ABILITY_CRASH
	respawn_time = 10 MINUTES
	time_between_round = 36 HOURS
	/// Timer used to calculate how long till round ends
	var/game_timer
	valid_job_types = list(
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/squad/engineer = 6,
		/datum/job/terragov/squad/corpsman = 6,
		/datum/job/terragov/squad/smartgunner = 2,
		/datum/job/terragov/squad/leader = 2,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/som/leader = 2
		/datum/job/som/veteran = 6
		/datum/job/som/medic = 6
		/datum/job/som/standard = -1
	)

	win_points_needed = 1000
	///How many points per zone to control, determined by the number of zones
	var/points_per_zone_per_second = 1

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
	for(var/turf/T AS in GLOB.fob_sentries_loc)
		new /obj/item/weapon/gun/sentry/big_sentry/fob_sentry(T)
	for(var/turf/T AS in GLOB.fob_sentries_rebel_loc)
		new /obj/item/weapon/gun/sentry/big_sentry/fob_sentry/rebel(T)
	for(var/turf/T AS in GLOB.sensor_towers)
		new /obj/structure/sensor_tower(T)
	if(GLOB.zones_to_control.len)
		points_per_zone_per_second = 1 / GLOB.zones_to_control.len
	GLOB.join_as_robot_allowed = FALSE

/datum/game_mode/combat_patrol/announce()
	to_chat(world, "<b>The current game mode is - Civil War!</b>")
	to_chat(world, "<b>Capture and defend the constested zones to win. They are in blue on the minimap, and you must activate the sensor towers to capture them. Every seconds (starting at 12:21), every controlled zone gives one point to your faction. The first to [win_points_needed] wins!</b>")
	to_chat(world, "<b>WIP, report bugs on the github!</b>")

/datum/game_mode/combat_patrol/set_valid_squads()
	SSjob.active_squads[FACTION_TERRAGOV] = list()
	SSjob.active_squads[FACTION_SOM] = list()
	for(var/key in SSjob.squads)
		var/datum/squad/squad = SSjob.squads[key]
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

///checks how many marines and SOM are still alive
/datum/game_mode/combat_patrol/proc/count_marines_and_som(list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND, ZTRAIT_RESERVED)), count_flags)
	//replace main_ship and reserved (marine ship and transit) with home base shit

	///number of TGMC alive for game end purposes
	var/num_marines = 0
	///number of SOM alive for game end purposes
	var/num_som = 0

	for(var/z in z_levels)
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
			if(isspaceturf(H.loc))
				continue
			if H.faction = FACTION_SOM
			num_som++
			if H.faction = FACTION_TERRAGOV
			num_marines++

	return list(num_marines, num_som)

///end game? - still need to configure points for kills, trash sensor tower shit.
/datum/game_mode/combat_patrol/check_finished()
	if(round_finished)
		return TRUE

	if(SSmonitor.gamestate != GROUNDSIDE) //check what this does, probs means marines haven't landed yet for civil war
		return

	///pulls the number of alive marines and SOM
	var/living_player_list[] = count_marines_and_som(count_flags = COUNT_IGNORE_ALIVE_SSD)
	var/num_marines = living_player_list[1]
	var/num_som = living_player_list[2]

	//trash this bit
	for(var/obj/structure/sensor_tower/sensor_tower AS in GLOB.zones_to_control)
		if(sensor_tower.faction)
			LAZYSET(points_per_faction, sensor_tower.faction, LAZYACCESS(points_per_faction, sensor_tower.faction) + points_per_zone_per_second)

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
		message_admins("Round finished: [MODE_SOM_MARINE_MAJOR]") //Marines wiped out ALL the SOM, Marine major victory
		round_finished = MODE_SOM_MARINE_MAJOR
		return TRUE

	//todo: minor victor for more kills at game time end
	if(LAZYACCESS(points_per_faction, FACTION_TERRAGOV) >= win_points_needed)
		if(LAZYACCESS(points_per_faction, FACTION_SOM) >= win_points_needed)
			message_admins("Round finished: [MODE_COMBAT_PATROL_DRAW]") //rocks fall, everyone dies
			round_finished = MODE_COMBAT_PATROL_DRAW
			return TRUE
		message_admins("Round finished: [MODE_SOM_MARINE_MAJOR]")
		round_finished = MODE_SOM_MARINE_MAJOR
		return TRUE
	if(LAZYACCESS(points_per_faction, FACTION_SOM) >= win_points_needed)
		message_admins("Round finished: [MODE_SOM_SOM_MAJOR]")
		round_finished = MODE_SOM_SOM_MAJOR
		return TRUE
	return FALSE
/////

/datum/game_mode/combat_patrol/declare_completion()
	. = ..()
	to_chat(world, span_round_header("|[round_finished]|"))
	to_chat(world, span_round_body("Thus ends the story of the brave men and women of the [SSmapping.configs[SHIP_MAP].map_name] and their struggle on [SSmapping.configs[GROUND_MAP].map_name]."))

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

	announce_medal_awards()
	announce_round_stats()
