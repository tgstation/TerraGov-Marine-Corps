/datum/game_mode/infestation/crash
	name = "Crash"
	config_tag = "Crash"
	required_players = 2
	flags_round_type = MODE_INFESTATION|MODE_XENO_SPAWN_PROTECT
	flags_landmarks = MODE_LANDMARK_SPAWN_XENO_TUNNELS|MODE_LANDMARK_SPAWN_MAP_ITEM

	round_end_states = list(MODE_CRASH_X_MAJOR, MODE_CRASH_M_MAJOR, MODE_CRASH_X_MINOR, MODE_CRASH_M_MINOR, MODE_CRASH_DRAW_DEATH)
	deploy_time_lock = 45 MINUTES

	squads_max_number = 1

	valid_job_types = list(
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 1,
		/datum/job/terragov/squad/specialist = 1,
		/datum/job/terragov/squad/leader = 1,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/silicon/synthetic = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/xenomorph = 1
	)

	// Round end conditions
	var/shuttle_landed = FALSE
	var/planet_nuked = CRASH_NUKE_NONE
	var/marines_evac = CRASH_EVAC_NONE

	// Shuttle details
	var/shuttle_id = "tgs_canterbury"
	var/obj/docking_port/mobile/crashmode/shuttle

	// Round start info
	var/starting_squad = "Alpha"

	var/larva_check_interval = 0
	var/bioscan_interval = INFINITY


/datum/game_mode/infestation/crash/scale_roles()
	. = ..()
	if(!.)
		return
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	xeno_job.job_points_needed  = CONFIG_GET(number/crash_larvapoints_required)


/datum/game_mode/infestation/crash/pre_setup()
	. = ..()

	// Spawn the ship
	if(!SSmapping.shuttle_templates[shuttle_id])
		CRASH("Shuttle [shuttle_id] wasn't found and can't be loaded")

	var/datum/map_template/shuttle/ST = SSmapping.shuttle_templates[shuttle_id]
	var/obj/docking_port/stationary/L = SSshuttle.getDock("canterbury_loadingdock")
	shuttle = SSshuttle.action_load(ST, L)

	// Redefine the relevant spawnpoints after spawning the ship.
	for(var/job_type in shuttle.spawns_by_job)
		GLOB.spawns_by_job[job_type] = shuttle.spawns_by_job[job_type]

	GLOB.jobspawn_overrides = list()
	GLOB.latejoin = shuttle.latejoins
	GLOB.latejoin_cryo = shuttle.latejoins
	GLOB.latejoin_gateway = shuttle.latejoins
	// Launch shuttle
	var/list/valid_docks = list()
	for(var/obj/docking_port/stationary/crashmode/potential_crash_site in SSshuttle.stationary)
		if(!shuttle.check_dock(potential_crash_site, silent = TRUE))
			continue
		valid_docks += potential_crash_site

	if(!length(valid_docks))
		CRASH("No valid crash sides found!")
	var/obj/docking_port/stationary/crashmode/actual_crash_site = pick(valid_docks)

	shuttle.crashing = TRUE
	SSshuttle.moveShuttleToDock(shuttle.id, actual_crash_site, TRUE) // FALSE = instant arrival
	addtimer(CALLBACK(src, .proc/crash_shuttle, actual_crash_site), 10 MINUTES)


/datum/game_mode/infestation/crash/post_setup()
	. = ..()
	for(var/i in GLOB.xeno_resin_silo_turfs)
		new /obj/structure/resin/silo(i)

	for(var/i in GLOB.nuke_spawn_locs)
		new /obj/machinery/nuclearbomb(i)

	for(var/i in GLOB.shuttle_controls_list)
		var/obj/machinery/computer/shuttle/shuttle_control/computer_to_disable = i
		if(istype(computer_to_disable, /obj/machinery/computer/shuttle/shuttle_control/canterbury))
			continue
		computer_to_disable.machine_stat |= BROKEN
		computer_to_disable.update_icon()

	for(var/i in GLOB.alive_xeno_list)
		if(isxenolarva(i)) // Larva
			var/mob/living/carbon/xenomorph/larva/X = i
			X.amount_grown = X.max_grown
		else // Handles Shrike etc
			var/mob/living/carbon/xenomorph/X = i
			X.upgrade_stored = X.xeno_caste.upgrade_threshold

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_CRASH)
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_EXPLODED, .proc/on_nuclear_explosion)
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_DIFFUSED, .proc/on_nuclear_diffuse)
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_START, .proc/on_nuke_started)
	var/datum/hive_status/normal/HN = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(HN)
		RegisterSignal(HN, COMSIG_XENOMORPH_POSTEVOLVING, .proc/on_xeno_evolve)


/datum/game_mode/infestation/crash/announce()
	to_chat(world, "<span class='round_header'>The current map is - [SSmapping.configs[GROUND_MAP].map_name]!</span>")
	priority_announce("Scheduled for landing in T-10 Minutes. Prepare for landing. Known hostiles near LZ. Detonation Protocol Active, planet disposable. Marines disposable.", type = ANNOUNCEMENT_PRIORITY)
	playsound(shuttle, 'sound/machines/warning-buzzer.ogg', 75, 0, 30)


/datum/game_mode/infestation/crash/process()
	if(round_finished)
		return

	// Burrowed Larva
	if(world.time > larva_check_interval)
		balance_scales()

	// Bioscan alerts
	if(world.time > bioscan_interval)
		announce_bioscans(TRUE, 0, FALSE, TRUE, TRUE)
		bioscan_interval = world.time + 10 MINUTES

/datum/game_mode/infestation/crash/proc/crash_shuttle(obj/docking_port/stationary/target)
	shuttle_landed = TRUE
	shuttle.crashing = FALSE

	// We delay this a little because the shuttle takes some time to land, and we want to the xenos to know the position of the marines.
	bioscan_interval = world.time + 30 SECONDS


/datum/game_mode/infestation/crash/check_finished(force_end)
	if(round_finished)
		return TRUE

	if(!shuttle_landed && !force_end)
		return FALSE

	var/list/living_player_list = count_humans_and_xenos(count_flags = COUNT_IGNORE_HUMAN_SSD)
	var/num_humans = living_player_list[1]

	if(num_humans && planet_nuked == CRASH_NUKE_NONE && marines_evac == CRASH_EVAC_NONE && !force_end)
		return FALSE

	var/num_xenos = living_player_list[2]

	// Draw, for all other reasons
	var/victory_options = ((planet_nuked == CRASH_NUKE_NONE && marines_evac == CRASH_EVAC_NONE) && (num_humans == 0 && num_xenos == 0)) << 0
	// XENO Major (All marines killed)
	victory_options |= (planet_nuked == CRASH_NUKE_NONE && num_humans == 0 && num_xenos > 0) << 1
	// XENO Minor (Marines evac'd for over 5 mins without a nuke)
	victory_options |= (planet_nuked == CRASH_NUKE_NONE && (marines_evac == CRASH_EVAC_COMPLETED || (!length(GLOB.active_nuke_list) && marines_evac != CRASH_EVAC_NONE)))	<< 2
	// Marine minor (Planet nuked, no one evac'd)
	victory_options |= (planet_nuked == CRASH_NUKE_COMPLETED && marines_evac == CRASH_EVAC_NONE) << 3
	// Marine Major (Planet nuked, marines evac, or they wiped the xenos out)
	victory_options |= ((planet_nuked == CRASH_NUKE_COMPLETED && marines_evac != CRASH_EVAC_NONE) || (planet_nuked == CRASH_NUKE_NONE && num_xenos == 0)) << 4

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
		else
			if(!force_end)
				return FALSE

	return TRUE


/datum/game_mode/infestation/crash/declare_completion()
	. = ..()
	to_chat(world, "<span class='round_header'>|[round_finished]|</span>")
	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the TGS Canterbury and their struggle on [SSmapping.configs[GROUND_MAP].map_name].</span>")

	// Music
	var/sound/xeno_track
	var/sound/human_track
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

	xeno_track = sound(xeno_track)
	human_track = sound(human_track)
	human_track.channel = CHANNEL_CINEMATIC
	xeno_track.channel = CHANNEL_CINEMATIC

	for(var/i in GLOB.xeno_mob_list)
		var/mob/M = i
		SEND_SOUND(M, xeno_track)

	for(var/i in GLOB.human_mob_list)
		var/mob/M = i
		SEND_SOUND(M, human_track)

	var/sound/ghost_sound = sound(pick('sound/misc/gone_to_plaid.ogg', 'sound/misc/good_is_dumb.ogg', 'sound/misc/hardon.ogg', 'sound/misc/surrounded_by_assholes.ogg', 'sound/misc/outstanding_marines.ogg', 'sound/misc/asses_kicked.ogg'), channel = CHANNEL_CINEMATIC)
	for(var/i in GLOB.observer_list)
		var/mob/M = i
		if(ishuman(M.mind.current))
			SEND_SOUND(M, human_track)
			continue

		if(isxeno(M.mind.current))
			SEND_SOUND(M, xeno_track)
			continue

		SEND_SOUND(M, ghost_sound)


	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

	announce_medal_awards()
	announce_round_stats()



/datum/game_mode/infestation/crash/attempt_to_join_as_larva(mob/xeno_candidate)
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	return HS.attempt_to_spawn_larva(xeno_candidate)


/datum/game_mode/infestation/crash/spawn_larva(mob/xeno_candidate, mob/living/carbon/xenomorph/mother)
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	return HS.spawn_larva(xeno_candidate, mother)


/datum/game_mode/infestation/crash/mode_new_player_panel(mob/new_player/NP)

	var/output = "<div align='center'>"
	output += "<br><i>You are part of the <b>TerraGov Marine Corps</b>, a military branch of the TerraGov council.</i>"
	output +="<hr>"
	output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=show_preferences'>Setup Character</A> | <a href='byond://?src=[REF(NP)];lobby_choice=lore'>Background</A><br><br><a href='byond://?src=[REF(NP)];lobby_choice=observe'>Observe</A></p>"
	output +="<hr>"
	output += "<center><p>Current character: <b>[NP.client ? NP.client.prefs.real_name : "Unknown User"]</b></p></center>"

	if(SSticker.current_state <= GAME_STATE_PREGAME)
		output += "<p>\[ [NP.ready? "<b>Ready</b>":"<a href='byond://?src=\ref[src];lobby_choice=ready'>Ready</a>"] | [NP.ready? "<a href='byond://?src=[REF(NP)];lobby_choice=ready'>Not Ready</a>":"<b>Not Ready</b>"] \]</p>"
	else
		output += "<a href='byond://?src=[REF(NP)];lobby_choice=manifest'>View the Crew Manifest</A><br>"
		output += "<p><a href='byond://?src=[REF(NP)];lobby_choice=late_join'>Join the Game!</A></p>"

	output += append_player_votes_link(NP)

	output += "</div>"

	var/datum/browser/popup = new(NP, "playersetup", "<div align='center'>Welcome to TGMC[SSmapping?.configs ? " - [SSmapping.configs[SHIP_MAP].map_name]" : ""]</div>", 300, 375)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(FALSE)

	return TRUE

/datum/game_mode/infestation/crash/proc/on_nuclear_diffuse(obj/machinery/nuclearbomb/bomb, mob/living/carbon/xenomorph/X)
	var/list/living_player_list = count_humans_and_xenos(count_flags = COUNT_IGNORE_HUMAN_SSD)
	var/num_humans = living_player_list[1]
	if(!num_humans) // no humans left on planet to try and restart it.
		addtimer(VARSET_CALLBACK(src, marines_evac, CRASH_EVAC_COMPLETED), 10 SECONDS)

	priority_announce("WARNING. WARNING. Planetary Nuke deactivated. WARNING. WARNING. Self destruct failed. WARNING. WARNING.", "Priority Alert")

/datum/game_mode/infestation/crash/proc/on_nuclear_explosion(datum/source, z_level)
	planet_nuked = CRASH_NUKE_INPROGRESS
	INVOKE_ASYNC(src, .proc/play_cinematic, z_level)

/datum/game_mode/infestation/crash/proc/on_nuke_started(obj/machinery/nuclearbomb/nuke)
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	var/area_name = get_area_name(nuke)
	HS.xeno_message("An overwhelming wave of dread ripples throughout the hive... A nuke has been activated[area_name ? " in [area_name]":""]!")

/datum/game_mode/infestation/crash/proc/play_cinematic(z_level)
	GLOB.enter_allowed = FALSE
	priority_announce("DANGER. DANGER. Planetary Nuke Activated. DANGER. DANGER. Self destruct in progress. DANGER. DANGER.", "Priority Alert")
	var/sound/S = sound(pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg'), channel = CHANNEL_CINEMATIC)
	SEND_SOUND(world, S)

	for(var/x in GLOB.player_list)
		var/mob/M = x
		if(isobserver(M) || isnewplayer(M))
			continue
		shake_camera(M, 110, 4)

	var/datum/cinematic/nuke_selfdestruct/C = /datum/cinematic/nuke_selfdestruct
	var/nuketime = initial(C.runtime) + initial(C.cleanup_time)
	addtimer(VARSET_CALLBACK(src, planet_nuked, CRASH_NUKE_COMPLETED), nuketime)
	addtimer(CALLBACK(src, .proc/do_nuke_z_level, z_level), nuketime * 0.5)

	Cinematic(CINEMATIC_SELFDESTRUCT, world)


/datum/game_mode/infestation/crash/proc/do_nuke_z_level(z_level)
	if(!z_level)
		return
	for(var/i in GLOB.alive_living_list)
		var/mob/living/victim = i
		var/turf/victim_turf = get_turf(victim) //Sneaky people on lockers.
		if(QDELETED(victim_turf) || victim_turf.z != z_level)
			continue
		victim.adjustFireLoss(victim.maxHealth*2)
		CHECK_TICK


/datum/game_mode/infestation/crash/proc/on_xeno_evolve(datum/source, mob/living/carbon/xenomorph/new_xeno)
	switch(new_xeno.tier)
		if(XENO_TIER_ONE)
			new_xeno.upgrade_xeno(XENO_UPGRADE_THREE)
		if(XENO_TIER_TWO)
			new_xeno.upgrade_xeno(XENO_UPGRADE_ONE)

/datum/game_mode/infestation/crash/can_summon_dropship(mob/user)
	to_chat(src, "<span class='warning'>This power doesn't work in this gamemode.</span>")
	return FALSE

/datum/game_mode/infestation/crash/proc/balance_scales()
	var/datum/hive_status/normal/xeno_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
	var/num_xenos = xeno_hive.get_total_xeno_number() + stored_larva
	var/larvapoints = (get_total_joblarvaworth() - (num_xenos * xeno_job.job_points_needed )) / xeno_job.job_points_needed
	if(!num_xenos)
		if(!length(GLOB.xeno_resin_silos))
			check_finished(TRUE)
			return //RIP benos.
		if(stored_larva)
			return //No need for respawns nor to end the game. They can use their burrowed larvas.
		xeno_job.add_job_positions(max(1, round(larvapoints, 1))) //At least one, rounded to nearest integer if more.
		return
	if(round(larvapoints, 1) < 1)
		return //Things are balanced, no burrowed needed
	xeno_job.add_job_positions(round(larvapoints, 1)) //However many burrowed they can afford to buy, rounded to nearest integer.
