/datum/game_mode/infestation/crash
	name = "Crash"
	config_tag = "Crash"
	flags_round_type = MODE_INFESTATION|MODE_XENO_SPAWN_PROTECT
	flags_landmarks = MODE_LANDMARK_SPAWN_XENO_TUNNELS|MODE_LANDMARK_SPAWN_MAP_ITEM
	flags_xeno_abilities = ABILITY_CRASH

	valid_job_types = list(
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 1,
		/datum/job/terragov/squad/leader = 1,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/silicon/synthetic = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/xenomorph = FREE_XENO_AT_START
	)

	// Round end conditions
	var/shuttle_landed = FALSE
	var/planet_nuked = CRASH_NUKE_NONE
	var/marines_evac = CRASH_EVAC_NONE

	// Shuttle details
	var/shuttle_id = SHUTTLE_CANTERBURY
	var/obj/docking_port/mobile/crashmode/shuttle

	// Round start info
	var/starting_squad = "Alpha"

	var/larva_check_interval = 2 MINUTES
	bioscan_interval = 0


/datum/game_mode/infestation/crash/scale_roles()
	. = ..()
	if(!.)
		return
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	xeno_job.job_points_needed  = CRASH_LARVA_POINTS_NEEDED


/datum/game_mode/infestation/crash/pre_setup()
	. = ..()

	// Spawn the ship
	if(TGS_CLIENT_COUNT >= 25)
		shuttle_id = SHUTTLE_BIGBURY
	if(!SSmapping.shuttle_templates[shuttle_id])
		message_admins("Gamemode: couldn't find a valid shuttle template for [shuttle_id]")
		CRASH("Shuttle [shuttle_id] wasn't found and can't be loaded")

	var/datum/map_template/shuttle/ST = SSmapping.shuttle_templates[shuttle_id]
	shuttle = SSshuttle.load_template_to_transit(ST)

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
		new /obj/structure/xeno/silo(i)

	for(var/obj/effect/landmark/corpsespawner/corpse AS in GLOB.corpse_landmarks_list)
		corpse.create_mob(HEADBITE_DEATH)

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
	to_chat(world, span_round_header("The current map is - [SSmapping.configs[GROUND_MAP].map_name]!"))
	priority_announce("Scheduled for landing in T-10 Minutes. Prepare for landing. Known hostiles near LZ. Detonation Protocol Active, planet disposable. Marines disposable.", type = ANNOUNCEMENT_PRIORITY)
	playsound(shuttle, 'sound/machines/warning-buzzer.ogg', 75, 0, 30)


/datum/game_mode/infestation/crash/process()
	. = ..()

	if(world.time > larva_check_interval)
		balance_scales()

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

	if(planet_nuked == CRASH_NUKE_NONE)
		if(!num_humans)
			message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //xenos wiped out ALL the marines
			round_finished = MODE_INFESTATION_X_MAJOR
			return TRUE
		if(marines_evac == CRASH_EVAC_COMPLETED || (!length(GLOB.active_nuke_list) && marines_evac != CRASH_EVAC_NONE))
			message_admins("Round finished: [MODE_INFESTATION_X_MINOR]") //marines evaced without a nuke
			round_finished = MODE_INFESTATION_X_MINOR
			return TRUE

	if(planet_nuked == CRASH_NUKE_COMPLETED)
		if(marines_evac == CRASH_EVAC_NONE)
			message_admins("Round finished: [MODE_INFESTATION_M_MINOR]") //marines nuked the planet but didn't evac
			round_finished = MODE_INFESTATION_M_MINOR
			return TRUE
		message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]") //marines nuked the planet and managed to evac
		round_finished = MODE_INFESTATION_M_MAJOR
		return TRUE
	return FALSE


/datum/game_mode/infestation/crash/proc/on_nuclear_diffuse(obj/machinery/nuclearbomb/bomb, mob/living/carbon/xenomorph/X)
	SIGNAL_HANDLER
	var/list/living_player_list = count_humans_and_xenos(count_flags = COUNT_IGNORE_HUMAN_SSD)
	var/num_humans = living_player_list[1]
	if(!num_humans) // no humans left on planet to try and restart it.
		addtimer(VARSET_CALLBACK(src, marines_evac, CRASH_EVAC_COMPLETED), 10 SECONDS)

	priority_announce("WARNING. WARNING. Planetary Nuke deactivated. WARNING. WARNING. Self destruct failed. WARNING. WARNING.", "Priority Alert")

/datum/game_mode/infestation/crash/proc/on_nuclear_explosion(datum/source, z_level)
	SIGNAL_HANDLER
	planet_nuked = CRASH_NUKE_INPROGRESS
	INVOKE_ASYNC(src, .proc/play_cinematic, z_level)

/datum/game_mode/infestation/crash/proc/on_nuke_started(datum/source, obj/machinery/nuclearbomb/nuke)
	SIGNAL_HANDLER
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	var/area_name = get_area_name(nuke)
	HS.xeno_message("An overwhelming wave of dread ripples throughout the hive... A nuke has been activated[area_name ? " in [area_name]":""]!")
	HS.set_all_xeno_trackers(nuke)

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

	var/datum/cinematic/crash_nuke/C = /datum/cinematic/crash_nuke
	var/nuketime = initial(C.runtime) + initial(C.cleanup_time)
	addtimer(VARSET_CALLBACK(src, planet_nuked, CRASH_NUKE_COMPLETED), nuketime)
	addtimer(CALLBACK(src, .proc/do_nuke_z_level, z_level), nuketime * 0.5)

	Cinematic(CINEMATIC_CRASH_NUKE, world)


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
	SIGNAL_HANDLER
	switch(new_xeno.tier)
		if(XENO_TIER_ONE)
			new_xeno.upgrade_xeno(XENO_UPGRADE_ONE) //This is bad, but this works without more refactoring
			new_xeno.upgrade_xeno(XENO_UPGRADE_TWO)
		if(XENO_TIER_TWO)
			new_xeno.upgrade_xeno(XENO_UPGRADE_ONE)

/datum/game_mode/infestation/crash/can_summon_dropship(mob/user)
	to_chat(src, span_warning("This power doesn't work in this gamemode."))
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
		xeno_job.add_job_positions(1)
		return
	if(round(larvapoints, 1) < 1)
		return //Things are balanced, no burrowed needed
	xeno_job.add_job_positions(1)
