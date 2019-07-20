/datum/game_mode/crash
	name = "Crash"
	config_tag = "Crash"
	required_players = 0
	flags_round_type = MODE_INFESTATION|MODE_FOG_ACTIVATED
	flags_landmarks = MODE_LANDMARK_SPAWN_XENO_TUNNELS|MODE_LANDMARK_SPAWN_MAP_ITEM

	round_end_states = list(MODE_CRASH_X_MAJOR, MODE_CRASH_M_MAJOR, MODE_CRASH_X_MINOR, MODE_CRASH_M_MINOR, MODE_CRASH_DRAW_DEATH)

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
	to_chat(world, "<span class='round_header'>The current map is - [SSmapping.configs[GROUND_MAP].map_name]!</span>")
	priority_announce("WAKE THE FUCK UP, WE ARE CRASHING INTO THE FUCKING PLANET AHHHHHHH", type = ANNOUNCEMENT_PRIORITY) // TODO: Better text.
	playsound(shuttle, 'sound/machines/alarm.ogg', 75, 0, 30)


/datum/game_mode/crash/can_start()
	. = ..()
	// Check if enough players have signed up for xeno & queen roles.
	initialize_xeno_leader()
	initialize_xenomorphs()
	if(!length(xenomorphs)) // we need at least 1
		return FALSE

	return TRUE


/datum/game_mode/crash/proc/crash_shuttle(obj/docking_port/stationary/target)
	shuttle.crashing = TRUE
	SSshuttle.moveShuttleToDock(shuttle.id, target, FALSE) // FALSE = instant arrival

/datum/game_mode/crash/post_setup()
	. = ..()

	// Reset all spawnpoints after spawning the ship
	GLOB.marine_spawns_by_job = shuttle.marine_spawns_by_job
	GLOB.jobspawn_overrides = list()
	GLOB.latejoin = shuttle.spawnpoints
	GLOB.latejoin_cryo = shuttle.spawnpoints
	GLOB.latejoin_gateway = shuttle.spawnpoints

	var/list/validdocks = list()
	for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
		if(!shuttle.check_dock(S, silent=TRUE))
			continue
		validdocks += S.name

	var/dock = pick(validdocks)

	var/obj/docking_port/stationary/target
	for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
		if(S.name != dock)
			continue
		target = S

	if(!target)
		message_admins("<span class='warning'>Unable to get a valid shuttle target!</span>")
		return

	addtimer(CALLBACK(src, .proc/crash_shuttle, target), 30 SECONDS) // TODO: REMOVE ADMIN TIMING
	// addtimer(CALLBACK(src, .proc/crash_shuttle, target), rand(4 MINUTES, 7 MINUTES) // TODO: FIX timing here

/datum/game_mode/crash/setup()
	SSjob.DivideOccupations() 
	create_characters() //Create player characters
	collect_minds()
	reset_squads()

	// Reassign everyone to the same squad
	for(var/i in GLOB.new_player_list)
		var/mob/new_player/N = i
		var/mob/living/carbon/human/player = N.new_character
		if(!istype(player) || !player?.mind.assigned_role)
			continue

		player.change_squad("Alpha") // TODO: There could be a better way to do this, but we need to rework squads / jobs / etc.

	equip_characters()

	transfer_characters()	//transfer keys to the new mobs

	return TRUE

/datum/game_mode/crash/pre_setup()
	. = ..()
	// Spawn the ship
	if(!SSmapping.shuttle_templates[shuttle_id])
		message_admins("Gamemode: Shuttle [shuttle_id] wasn't found and can't be loaded")
		CRASH("Shuttle [shuttle_id] wasn't found and can't be loaded")
		return FALSE

	var/datum/map_template/shuttle/S = SSmapping.shuttle_templates[shuttle_id]
	var/obj/docking_port/stationary/L = SSshuttle.getDock("crashmodeloading")
	shuttle = SSshuttle.action_load(S, L)

	// Reset all spawnpoints after spawning the ship
	GLOB.marine_spawns_by_job = shuttle.marine_spawns_by_job
	GLOB.jobspawn_overrides = list()
	GLOB.latejoin = shuttle.spawnpoints
	GLOB.latejoin_cryo = shuttle.spawnpoints
	GLOB.latejoin_gateway = shuttle.spawnpoints

	// Create xenos
	var/number_of_xenos = length(xenomorphs)
	var/datum/hive_status/normal/HN = GLOB.hive_datums[XENO_HIVE_NORMAL]
	for(var/i in xenomorphs)
		var/datum/mind/M = i
		if(M.assigned_role == ROLE_XENO_QUEEN)
			transform_ruler(M, number_of_xenos > HN.xenos_per_queen)
		else
			transform_xeno(M)


#define CRASH_DRAW (1 << 0)
#define CRASH_XENO_MAJOR (1 << 1)
#define CRASH_XENO_MINOR (1 << 2)
#define CRASH_MARINE_MINOR (1 << 3)
#define CRASH_MARINE_MAJOR (1 << 4)


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
	
	var/victory_options = (num_humans == 0 && num_xenos == 0 || (planet_nuked && !marines_evac)) 						<< 0 // Draw, for all other reasons
	victory_options |= (!planet_nuked && num_humans == 0 && num_xenos > 0) 												<< 1 // XENO Major (All marines killed)
	victory_options |= (marines_evac && !planet_nuked) 																	<< 2 // XENO Minor (Marines evac'd )
	victory_options |= (marines_evac && planet_nuked && (num_humans == 0 || num_grounded_humans > 0)) 					<< 3 // Marine minor (Planet nuked, some human left on planet)
	victory_options |= ((marines_evac && planet_nuked && num_grounded_humans == 0) || num_xenos == 0 && num_humans > 0) << 4 // Marine Major (Planet nuked, marines evac, or they wiped the xenos out)
	
	switch(victory_options)
		if(CRASH_DRAW)
			message_admins("Round finished: [MODE_CRASH_DRAW_DEATH]")
			round_finished = MODE_CRASH_DRAW_DEATH 
		if(CRASH_XENO_MAJOR)
			message_admins("Round finished: [MODE_CRASH_X_MAJOR]")
			round_finished = MODE_CRASH_X_MAJOR 
		if(CRASH_XENO_MINOR)
			message_admins("Round finished: [MODE_CRASH_X_MINOR]")
			round_finished = MODE_CRASH_X_MINOR 
		if(CRASH_MARINE_MINOR)
			message_admins("Round finished: [MODE_CRASH_M_MINOR]")
			round_finished = MODE_CRASH_M_MINOR 
		if(CRASH_MARINE_MAJOR)
			message_admins("Round finished: [MODE_CRASH_M_MAJOR]")
			round_finished = MODE_CRASH_M_MAJOR 

	return FALSE

/datum/game_mode/crash/declare_completion()
	. = ..()
	to_chat(world, "<span class='round_header'>|[round_finished]|</span>")
	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the TGS Cantebury and their struggle on [SSmapping.configs[GROUND_MAP].map_name].</span>")
	
	// Music
	var/xeno_track
	var/human_track
	switch(round_finished)
		if(MODE_CRASH_X_MAJOR)
			xeno_track = pick('sound/theme/winning_triumph1.ogg','sound/theme/winning_triumph2.ogg')
			human_track = pick('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg')
		if(MODE_CRASH_M_MAJOR)
			xeno_track = pick('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg')
			human_track = pick('sound/theme/winning_triumph1.ogg','sound/theme/winning_triumph2.ogg')
		if(MODE_CRASH_X_MINOR)
			xeno_track = pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg')
			human_track = pick('sound/theme/neutral_melancholy1.ogg','sound/theme/neutral_melancholy2.ogg')
		if(MODE_CRASH_M_MINOR)
			xeno_track = pick('sound/theme/neutral_melancholy1.ogg','sound/theme/neutral_melancholy2.ogg')
			human_track = pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg')
		if(MODE_CRASH_DRAW_DEATH)
			xeno_track = pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg') 
			human_track = pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg')

	for(var/i in GLOB.xeno_mob_list)
		var/mob/M = i
		SEND_SOUND(M, xeno_track)

	for(var/i in GLOB.human_mob_list)
		var/mob/M = i
		SEND_SOUND(M, human_track)

	for(var/i in GLOB.observer_list)
		var/mob/M = i
		if(ishuman(M.mind.current))
			SEND_SOUND(M, human_track)
			continue

		if(isxeno(M.mind.current))
			SEND_SOUND(M, xeno_track)
			continue

		SEND_SOUND(M, pick('sound/misc/gone_to_plaid.ogg', 'sound/misc/good_is_dumb.ogg', 'sound/misc/hardon.ogg', 'sound/misc/surrounded_by_assholes.ogg', 'sound/misc/outstanding_marines.ogg', 'sound/misc/asses_kicked.ogg'))

	
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