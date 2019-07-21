/datum/game_mode/crash
	name = "Crash"
	config_tag = "Crash"
	required_players = 0
	flags_round_type = MODE_INFESTATION|MODE_FOG_ACTIVATED
	flags_landmarks = MODE_LANDMARK_SPAWN_XENO_TUNNELS|MODE_LANDMARK_SPAWN_MAP_ITEM

	round_end_states = list(MODE_CRASH_X_MAJOR, MODE_CRASH_M_MAJOR, MODE_CRASH_X_MINOR, MODE_CRASH_M_MINOR, MODE_CRASH_DRAW_DEATH)

	// Round end conditions
	var/marines_evac = FALSE
	var/planet_nuked = FALSE

	var/shuttle_id = "tgs_canterbury"
	var/obj/docking_port/mobile/crashmode/shuttle


/datum/game_mode/crash/New()
	. = ..()
	xenomorphs = list()


/datum/game_mode/crash/can_start()
	. = ..()
	// Check if enough players have signed up for xeno & queen roles.
	var/ruler = initialize_xeno_leader()
	var/xenos = initialize_xenomorphs()
	if(!ruler && !xenos) // we need at least 1
		return FALSE

	return TRUE


/datum/game_mode/crash/pre_setup()
	. = ..()
	// Spawn the ship
	if(!SSmapping.shuttle_templates[shuttle_id])
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
		CRASH("Unable to get a valid shuttle target!")
		return

	addtimer(CALLBACK(src, .proc/crash_shuttle, target), 30 SECONDS) // TODO: REMOVE ADMIN TIMING
	// addtimer(CALLBACK(src, .proc/crash_shuttle, target), rand(4 MINUTES, 7 MINUTES) // TODO: FIX timing here


/datum/game_mode/crash/announce()
	to_chat(world, "<span class='round_header'>The current map is - [SSmapping.configs[GROUND_MAP].map_name]!</span>")
	priority_announce("WAKE THE FUCK UP, WE ARE CRASHING INTO THE FUCKING PLANET AHHHHHHH", type = ANNOUNCEMENT_PRIORITY) // TODO: Better text.
	playsound(shuttle, 'sound/machines/alarm.ogg', 75, 0, 30)
	

/datum/game_mode/crash/proc/crash_shuttle(obj/docking_port/stationary/target)
	shuttle.crashing = TRUE
	SSshuttle.moveShuttleToDock(shuttle.id, target, FALSE) // FALSE = instant arrival


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

// Overrides

/datum/game_mode/crash/job_after_spawn(mob/living/carbon/human/H, mob/M, latejoin = FALSE)
	if(!istype(H))
		return FALSE

	H.change_squad("Alpha")
	H.hud_set_squad()
	H.nutrition = rand(250,300)
	if(!H.mind?.assigned_squad)
		return TRUE
	var/datum/squad/S = H.mind.assigned_squad
	to_chat(M, {"\nYou have been assigned to: <b><font size=3 color=[S.color]>[lowertext(S.name)] squad</font></b>."})
	
	return TRUE
