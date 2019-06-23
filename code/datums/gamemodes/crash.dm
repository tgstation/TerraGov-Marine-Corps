#define GAMEMODE_CRASH_MUSIC list(\
	MODE_CRASH_X_MAJOR = list('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg'),\
	MODE_CRASH_X_MINOR = list('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg'),\
	MODE_CRASH_M_MAJOR = list('sound/theme/winning_triumph1.ogg','sound/theme/winning_triumph2.ogg'),\
	MODE_CRASH_M_MINOR = list('sound/theme/winning_triumph1.ogg','sound/theme/winning_triumph2.ogg'),\
	MODE_CRASH_DRAW_DEATH = list('sound/theme/sad_loss1.ogg'),\
)

/datum/game_mode/crash
	name = "Crash"
	config_tag = "Crash"
	required_players = 0
	flags_round_type = MODE_INFESTATION|MODE_FOG_ACTIVATED
	flags_landmarks = MODE_LANDMARK_SPAWN_XENO_TUNNELS|MODE_LANDMARK_SPAWN_MAP_ITEM

	// Round start conditions
	var/xeno_required_num = 1
	var/xeno_starting_num = 0
	var/list/xenomorphs
	
	// Round end conditions
	var/marines_evac = FALSE
	var/planet_nuked = FALSE

	var/shuttle_id = "tgs_canterbury"
	var/obj/docking_port/mobile/crashmode/shuttle

/datum/game_mode/crash/New()
	. = ..()

	xenomorphs = list()

/datum/game_mode/crash/announce()
	to_chat(world, "<span class='round_header'>The current map is - [SSmapping.config.map_name]!</span>")


/datum/game_mode/crash/can_start()
	. = ..()
	return TRUE
	// Check if enough players have signed up for xeno & queen roles.
	initialize_xeno_leader()
	initialize_xenomorphs()
	if(!length(xenomorphs)) // we need at least 1
		return FALSE

	return TRUE


/datum/game_mode/crash/pre_setup()
	. = ..()
	// Spawn the ship
	if(!SSmapping.shuttle_templates[shuttle_id])
		message_admins("Gamemode: Shuttle [shuttle_id] wasn't found and can't be loaded")
		CRASH("Shuttle [shuttle_id] wasn't found and can't be loaded")
		return FALSE


	// Reset all spawnpoints before spawning the ship
	GLOB.marine_spawns_by_job = list()
	GLOB.jobspawn_overrides = list()
	GLOB.latejoin = list()
	GLOB.latejoin_cryo = list()
	GLOB.latejoin_gateway = list()

	var/datum/map_template/shuttle/S = SSmapping.shuttle_templates[shuttle_id]
	var/obj/docking_port/stationary/L = SSshuttle.getDock("crashmodeloading")
	shuttle = SSshuttle.action_load(S, L)
	
	// shuttle = SSshuttle.getShuttle(shuttle_id)
	// GLOB.marine_spawns_by_job = shuttle.marine_spawns_by_job

	// Create xenos
	for(var/i in xenomorphs)
		var/datum/mind/M = i
		if(M.assigned_role == ROLE_XENO_QUEEN)
			transform_queen(M)
		else
			transform_xeno(M)


#define PLANET_NUKED (1 << 0)
#define NO_HUMANS (1 << 1)
#define NO_ALIENS (1 << 2)


/datum/game_mode/crash/check_finished()
	return FALSE
	if(round_finished)
		return TRUE

	if(world.time < (SSticker.round_start_time + 15 SECONDS))
		return FALSE

	var/list/living_player_list = count_humans_and_xenos()
	var/num_humans = living_player_list[1]
	var/num_xenos = living_player_list[2]
	
	var/list/grounded_living_player_list = count_humans_and_xenos(SSmapping.levels_by_any_trait(list(ZTRAIT_GROUND)))
	var/num_grounded_humans = grounded_living_player_list[1]
	

	// var/victory_options = planet_nuked << 0
	// victory_options |= (num_humans == 0) << 1
	// victory_options |= (num_xenos == 0) << 2
	// switch(victory_options)
	// 	if(NO_HUMANS)
	// 		xenowin()

	if(!planet_nuked && num_humans == 0 && num_xenos > 0) // XENO Major (All marines killed)
		message_admins("Round finished: [MODE_CRASH_X_MAJOR]")
		round_finished = MODE_CRASH_X_MAJOR 
	else if(marines_evac && planet_nuked && (num_humans == 0 || num_grounded_humans > 0)) // Marine minor (Planet nuked, some human left on planet)
		message_admins("Round finished: [MODE_CRASH_M_MINOR]")
		round_finished = MODE_CRASH_M_MINOR 
	else if(marines_evac && planet_nuked) // Marine Major (Planet nuked, marines evac)
		message_admins("Round finished: [MODE_CRASH_M_MAJOR]")
		round_finished = MODE_CRASH_M_MAJOR 
	else if(marines_evac && !planet_nuked) // Xeno minor (Marines evac, planet intact)
		message_admins("Round finished: [MODE_CRASH_X_MINOR]")
		round_finished = MODE_CRASH_X_MINOR 
	else if(num_humans == 0 && num_xenos == 0 || (planet_nuked && !marines_evac)) // Draw, for all other reasons
		message_admins("Round finished: [MODE_CRASH_DRAW_DEATH]")
		round_finished = MODE_CRASH_DRAW_DEATH 

	return FALSE

/datum/game_mode/crash/declare_completion()
	. = ..()
	to_chat(world, "<span class='round_header'>|[round_finished]|</span>")
	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the [CONFIG_GET(string/ship_name)] and their struggle on [SSmapping.config.map_name].</span>")
	
	SEND_SOUND(world, GAMEMODE_CRASH_MUSIC[round_finished])
	
	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

	announce_medal_awards()
	announce_round_stats()
	end_of_round_deathmatch()


/datum/game_mode/crash/proc/initialize_xeno_leader()
	var/list/possible_queens = get_players_for_role(BE_QUEEN)
	if(!length(possible_queens))
		return FALSE

	var/found = FALSE
	for(var/i in possible_queens)
		var/datum/mind/new_queen = i
		if(new_queen.assigned_role || is_banned_from(new_queen.current?.ckey, ROLE_XENO_QUEEN))
			continue
		if(queen_age_check(new_queen.current?.client))
			continue
		new_queen.assigned_role = ROLE_XENO_QUEEN
		xenomorphs += new_queen
		found = TRUE
		break

	return found

/datum/game_mode/crash/proc/initialize_xenomorphs()
	var/list/possible_xenomorphs = get_players_for_role(BE_ALIEN)
	if(length(possible_xenomorphs) < xeno_required_num)
		return FALSE

	for(var/i in possible_xenomorphs)
		var/datum/mind/new_xeno = i
		if(new_xeno.assigned_role || is_banned_from(new_xeno.current?.ckey, ROLE_XENOMORPH))
			continue
		new_xeno.assigned_role = ROLE_XENOMORPH
		xenomorphs += new_xeno
		possible_xenomorphs -= new_xeno
		if(length(xenomorphs) >= xeno_starting_num)
			break

	if(!length(xenomorphs))
		return FALSE

	xeno_required_num = CONFIG_GET(number/min_xenos)

	if(length(xenomorphs) < xeno_required_num)
		for(var/i = 1 to xeno_starting_num - length(xenomorphs))
			new /mob/living/carbon/xenomorph/larva(pick(GLOB.xeno_spawn))

	else if(length(xenomorphs) < xeno_starting_num)
		var/datum/hive_status/normal/HN = GLOB.hive_datums[XENO_HIVE_NORMAL]
		HN.stored_larva += xeno_starting_num - length(xenomorphs)

	return TRUE