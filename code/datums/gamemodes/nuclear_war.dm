/datum/game_mode/infestation/nuclear_war
	name = "Nuclear War"
	config_tag = "Nuclear War"
	silo_scaling = 1.5
	flags_round_type = MODE_INFESTATION|MODE_LATE_OPENING_SHUTTER_TIMER|MODE_XENO_RULER|MODE_PSY_POINTS|MODE_PSY_POINTS_ADVANCED|MODE_DEAD_GRAB_FORBIDDEN|MODE_HIJACK_POSSIBLE|MODE_SILO_RESPAWN|MODE_SILOS_SPAWN_MINIONS|MODE_ALLOW_XENO_QUICKBUILD
	flags_xeno_abilities = ABILITY_NUCLEARWAR
	valid_job_types = list(
		/datum/job/terragov/command/captain = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/command/staffofficer = 4,
		/datum/job/terragov/command/pilot = 2,
		/datum/job/terragov/engineering/chief = 1,
		/datum/job/terragov/engineering/tech = 2,
		/datum/job/terragov/requisitions/officer = 1,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 4,
		/datum/job/terragov/medical/researcher = 2,
		/datum/job/terragov/civilian/liaison = 1,
		/datum/job/terragov/silicon/synthetic = 1,
		/datum/job/terragov/command/mech_pilot = 0,
		/datum/job/terragov/silicon/ai = 1,
		/datum/job/terragov/squad/engineer = 1,
		/datum/job/terragov/squad/corpsman = 1,
		/datum/job/terragov/squad/smartgunner = 1,
		/datum/job/terragov/squad/leader = 1,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/xenomorph = FREE_XENO_AT_START,
		/datum/job/xenomorph/queen = 1
	)
	job_points_needed_by_job_type = list(
		/datum/job/terragov/squad/smartgunner = 20,
		/datum/job/terragov/squad/corpsman = 5,
		/datum/job/terragov/squad/engineer = 5,
		/datum/job/xenomorph = NUCLEAR_WAR_LARVA_POINTS_NEEDED,
	)

/datum/game_mode/infestation/nuclear_war/post_setup()
	. = ..()

	SSpoints.add_psy_points(XENO_HIVE_NORMAL, 1400)

	for(var/obj/effect/landmark/corpsespawner/corpse AS in GLOB.corpse_landmarks_list)
		corpse.create_mob()

	for(var/mob/living/carbon/xenomorph/larva/xeno in GLOB.alive_xeno_list)
		xeno.evolution_stored = xeno.xeno_caste.evolution_threshold //Immediate roundstart evo for larva.

	for(var/i in GLOB.nuke_spawn_locs)
		new /obj/machinery/nuclearbomb(i)
	generate_nuke_disk_spawners()

	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_EXPLODED, PROC_REF(on_nuclear_explosion))
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_DIFFUSED, PROC_REF(on_nuclear_diffuse))
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_START, PROC_REF(on_nuke_started))

/datum/game_mode/infestation/nuclear_war/orphan_hivemind_collapse()
	if(round_finished)
		return
	if(round_stage == INFESTATION_MARINE_CRASHING)
		round_finished = MODE_INFESTATION_M_MINOR
		return
	round_finished = MODE_INFESTATION_M_MAJOR

/datum/game_mode/infestation/nuclear_war/get_hivemind_collapse_countdown()
	var/eta = timeleft(orphan_hive_timer) MILLISECONDS
	return !isnull(eta) ? round(eta) : 0

/datum/game_mode/infestation/nuclear_war/check_finished()
	if(round_finished)
		return TRUE

	if(world.time < (SSticker.round_start_time + 5 SECONDS))
		return FALSE

	var/list/living_player_list = count_humans_and_xenos(count_flags = COUNT_IGNORE_ALIVE_SSD|COUNT_IGNORE_XENO_SPECIAL_AREA)
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

	switch(planet_nuked)
		if(INFESTATION_NUKE_COMPLETED)
			message_admins("Round finished: [MODE_INFESTATION_M_MINOR]") //marines managed to nuke the colony
			round_finished = MODE_INFESTATION_M_MINOR
			return TRUE
		if(INFESTATION_NUKE_COMPLETED_SHIPSIDE)
			message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //marines managed to nuke their own ship
			round_finished = MODE_INFESTATION_X_MAJOR
			return TRUE
		if(INFESTATION_NUKE_COMPLETED_OTHER)
			message_admins("Round finished: [MODE_INFESTATION_X_MINOR]") //marines managed to nuke transit or something
			round_finished = MODE_INFESTATION_X_MINOR
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
