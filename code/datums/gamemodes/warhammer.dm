/datum/game_mode/infestation/distress/warhammer
	name = "Warhammer 40k"
	config_tag = "Warhammer 40k"
	silo_scaling = 3
	evolve_scaling = 50
	maturity_scaling = 50
	valid_job_types = list(
		/datum/job/imperial/squad/skitarii = 3,
		/datum/job/imperial/squad/tech_priest = 2,
		/datum/job/imperial/squad/sergeant = 4,
		/datum/job/imperial/squad/veteran = 2,
		/datum/job/imperial/squad/medicae = 8,
		/datum/job/imperial/squad/standard = -1,
	)
	whitelist_ship_maps = list(MAP_BATTLEMACE_OF_FURY)

/datum/game_mode/infestation/distress/warhammer/post_setup()
	. = ..()
	for(var/i in GLOB.nuke_spawn_locs)
		new /obj/machinery/nuclearbomb(i)
	for(var/turf/T AS in GLOB.comms_tower)
		new /obj/structure/comms_tower(T)
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_EXPLODED, .proc/on_nuclear_explosion)
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_DIFFUSED, .proc/on_nuclear_diffuse)
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_START, .proc/on_nuke_started)

/datum/game_mode/infestation/distress/warhammer/scale_roles()
	. = ..()
	if(!.)
		return
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/imperial/squad/veteran)
	scaled_job.job_points_needed = 5 //For every 5 non vet late joins, 1 extra veteran

/datum/game_mode/infestation/distress/warhammer/set_valid_squads()
	SSjob.active_squads[FACTION_IMP] = list()
	for(var/key in SSjob.squads)
		var/datum/squad/squad = SSjob.squads[key]
		if(squad.faction == FACTION_IMP)
			SSjob.active_squads[squad.faction] += squad
	return TRUE

/datum/game_mode/infestation/distress/warhammer/check_finished()
	if(round_finished)
		return TRUE

	if(world.time < (SSticker.round_start_time + 5 SECONDS))
		return FALSE

	var/living_player_list[] = count_humans_and_xenos(count_flags = COUNT_IGNORE_ALIVE_SSD|COUNT_IGNORE_XENO_SPECIAL_AREA)
	var/num_humans = living_player_list[1]
	var/num_xenos = living_player_list[2]
	var/num_humans_ship = living_player_list[3]

	if(SSevacuation.dest_status == NUKE_EXPLOSION_FINISHED)
		message_admins("Round finished: [MODE_GENERIC_DRAW_NUKE]") //ship blows, no one wins
		round_finished = MODE_GENERIC_DRAW_NUKE
		return TRUE

	if(round_stage == INFESTATION_DROPSHIP_CAPTURED_XENOS)
		message_admins("Round finished: [MODE_INFESTATION_X_MINOR]")
		round_finished = MODE_INFESTATION_X_MINOR
		return TRUE

	if(planet_nuked == INFESTATION_NUKE_COMPLETED)
		message_admins("Round finished: [MODE_INFESTATION_M_MINOR]") //marines managed to nuke the colony
		round_finished = MODE_INFESTATION_M_MINOR
		return TRUE

	if(!num_humans)
		if(!num_xenos)
			message_admins("Round finished: [MODE_INFESTATION_DRAW_DEATH]") //everyone died at the same time, no one wins
			round_finished = MODE_INFESTATION_DRAW_DEATH
			return TRUE
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //xenos wiped out ALL the marines without hijacking, xeno major victory
		round_finished = MODE_INFESTATION_X_MAJOR
		return TRUE
	if(!num_xenos)
		if(round_stage == INFESTATION_MARINE_CRASHING)
			message_admins("Round finished: [MODE_INFESTATION_M_MINOR]") //marines lost the ground operation but managed to wipe out Xenos on the ship at a greater cost, minor victory
			round_finished = MODE_INFESTATION_M_MINOR
			return TRUE
		message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]") //marines win big
		round_finished = MODE_INFESTATION_M_MAJOR
		return TRUE
	if(round_stage == INFESTATION_MARINE_CRASHING && !num_humans_ship)
		if(SSevacuation.human_escaped > SSevacuation.initial_human_on_ship * 0.5)
			message_admins("Round finished: [MODE_INFESTATION_X_MINOR]") //xenos have control of the ship, but most marines managed to flee
			round_finished = MODE_INFESTATION_X_MINOR
			return
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //xenos wiped our marines, xeno major victory
		round_finished = MODE_INFESTATION_X_MAJOR
		return TRUE
	return FALSE

/datum/game_mode/infestation/distress/warhammer/siloless_hive_collapse()
	return

/datum/game_mode/infestation/distress/warhammer/get_siloless_collapse_countdown()
	return
