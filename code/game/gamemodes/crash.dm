/datum/game_mode/crash
	name = "Crash"
	config_tag = "Crash"
	required_players = 0
	flags_round_type = MODE_INFESTATION|MODE_FOG_ACTIVATED
	flags_landmarks = MODE_LANDMARK_SPAWN_XENO_TUNNELS|MODE_LANDMARK_SPAWN_MAP_ITEM


	// Round start conditions
	var/xeno_required_num = 1
	var/xeno_starting_num = 0
	var/list/xenomorphs = list()
	
	// Round end conditions
	var/marines_evac = FALSE
	var/planet_nuked = FALSE


/datum/game_mode/crash/announce()
	to_chat(world, "<span class='round_header'>The current map is - [SSmapping.config.map_name]!</span>")


/datum/game_mode/crash/can_start()
	. = ..()
	// Check if enough players have signed up for xeno & queen roles.
	initialize_xeno_leader()
	initialize_xenomorphs()
	if(!length(xenomorphs)) // we need at least 1
		return FALSE

	return TRUE


/datum/game_mode/crash/pre_setup()
	. = ..()

	for(var/i in xenomorphs)
		var/datum/mind/M = i
		if(M.assigned_role == ROLE_XENO_QUEEN)
			transform_queen(M)
		else
			transform_xeno(M)


/datum/game_mode/crash/check_finished()
	if(round_finished)
		return TRUE

	if(world.time < (SSticker.round_start_time + 15 SECONDS))
		return FALSE

	var/list/living_player_list = count_humans_and_xenos()
	var/num_humans = living_player_list[1]
	var/num_xenos = living_player_list[2]
	
	var/list/grounded_living_player_list = count_humans_and_xenos(SSmapping.levels_by_any_trait(list(ZTRAIT_GROUND)))
	var/num_grounded_humans = grounded_living_player_list[1]
	
	if(!planet_nuked && num_humans == 0 && num_xenos > 0) // XENO Major (All marines killed)
		message_admins("Round finished: [MODE_CRASH_X_MAJOR]")
		round_finished = MODE_CRASH_X_MAJOR 
	else if(marines_evac && planet_nuked && (num_humans == 0 || num_grounded_humans > 0)) // Marine minor (Planet nuked, no human left on planet)
		message_admins("Round finished: [MODE_CRASH_M_MINOR]")
		round_finished = MODE_CRASH_M_MINOR 
	else if(marines_evac && planet_nuked) // Marine Major (Planet nuked, marines evac)
		message_admins("Round finished: [MODE_CRASH_M_MAJOR]")
		round_finished = MODE_CRASH_M_MAJOR 
	else if(marines_evac && !planet_nuked) // Xeno minor (Marines evac, planet intact)
		message_admins("Round finished: [MODE_CRASH_X_MINOR]")
		round_finished = MODE_CRASH_X_MINOR 
	else if(num_humans == 0 && num_xenos == 0) // Draw, for some unknown reason
		message_admins("Round finished: [MODE_CRASH_DRAW_DEATH]")
		round_finished = MODE_CRASH_DRAW_DEATH 

	return FALSE

/datum/game_mode/crash/declare_completion()
	. = ..()
	to_chat(world, "<span class='round_header'>|Round Complete|</span>")
	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the [CONFIG_GET(string/ship_name)] and their struggle on [SSmapping.config.map_name].</span>")
	
	var/musical_track
	switch(round_finished)
		if(MODE_CRASH_X_MAJOR) // marines killed
			musical_track = pick('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg')
		if(MODE_CRASH_X_MINOR) // marines killed
			musical_track = pick('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg')
		if(MODE_CRASH_M_MAJOR) // planet nuked & marines left
			musical_track = pick('sound/theme/winning_triumph1.ogg','sound/theme/winning_triumph2.ogg')
		if(MODE_CRASH_M_MINOR) // planet nuked & marines left
			musical_track = pick('sound/theme/winning_triumph1.ogg','sound/theme/winning_triumph2.ogg')
		if(MODE_CRASH_DRAW_DEATH) // everyone died.
			musical_track = 'sound/theme/sad_loss1.ogg'


	SEND_SOUND(world, musical_track)
	
	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [round_statistics.total_xenos_created]\nTotal humans spawned: [round_statistics.total_humans_created]")

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
		if(new_queen.assigned_role || jobban_isbanned(new_queen.current, ROLE_XENO_QUEEN) || is_banned_from(new_queen.current?.ckey, ROLE_XENO_QUEEN))
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
		if(new_xeno.assigned_role || jobban_isbanned(new_xeno.current, ROLE_XENOMORPH) || is_banned_from(new_xeno.current?.ckey, ROLE_XENOMORPH))
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