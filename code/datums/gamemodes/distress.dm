/datum/game_mode/infestation/distress
	name = "Distress Signal"
	config_tag = "Distress Signal"
	silo_scaling = 2.50

	flags_round_type = MODE_INFESTATION|MODE_LATE_OPENING_SHUTTER_TIMER|MODE_XENO_RULER|MODE_PSY_POINTS|MODE_PSY_POINTS_ADVANCED|MODE_DEAD_GRAB_FORBIDDEN|MODE_HIJACK_POSSIBLE|MODE_SILO_RESPAWN|MODE_SILOS_SPAWN_MINIONS|MODE_ALLOW_XENO_QUICKBUILD|MODE_ALLOW_PINPOINTER
	flags_xeno_abilities = ABILITY_DISTRESS
	valid_job_types = list(
		/datum/job/terragov/command/captain = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/command/staffofficer = 4,
		/datum/job/terragov/command/pilot = 2,
		/datum/job/terragov/engineering/chief = 1,
		/datum/job/terragov/engineering/tech = 2,
		/datum/job/terragov/requisitions/officer = 1,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 6,
		/datum/job/terragov/medical/researcher = 2,
		/datum/job/terragov/civilian/liaison = 1,
		/datum/job/terragov/silicon/synthetic = 1,
		/datum/job/terragov/command/mech_pilot = 0,
		/datum/job/terragov/silicon/ai = 1,
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 1,
		/datum/job/terragov/squad/leader = 1,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/xenomorph = FREE_XENO_AT_START,
		/datum/job/xenomorph/queen = 1,
		/datum/job/survivor/rambo = 1,
	)
	var/siloless_hive_timer

/datum/game_mode/infestation/distress/post_setup()
	. = ..()
	SSpoints.add_psy_points(XENO_HIVE_NORMAL, 2000)

	for(var/obj/effect/landmark/corpsespawner/corpse AS in GLOB.corpse_landmarks_list)
		corpse.create_mob()

	for(var/mob/living/carbon/xenomorph/xeno AS in GLOB.alive_xeno_list)
		if(isxenolarva(xeno)) // Larva
			xeno.evolution_stored = xeno.xeno_caste.evolution_threshold //Immediate roundstart evo for larva.

/datum/game_mode/infestation/distress/scale_roles(initial_players_assigned)
	. = ..()
	if(!.)
		return
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/xenomorph) //Xenos
	scaled_job.job_points_needed  = DISTRESS_LARVA_POINTS_NEEDED


/datum/game_mode/infestation/distress/orphan_hivemind_collapse()
	if(round_finished)
		return
	if(round_stage == INFESTATION_MARINE_CRASHING)
		round_finished = MODE_INFESTATION_M_MINOR
		return
	round_finished = MODE_INFESTATION_M_MAJOR


/datum/game_mode/infestation/distress/get_hivemind_collapse_countdown()
	var/eta = timeleft(orphan_hive_timer) MILLISECONDS
	return !isnull(eta) ? round(eta) : 0

/datum/game_mode/infestation/distress/update_silo_death_timer(datum/hive_status/silo_owner)
	if(!(silo_owner.hive_flags & HIVE_CAN_COLLAPSE_FROM_SILO))
		return

	//handle potential stopping
	if(round_stage != INFESTATION_MARINE_DEPLOYMENT)
		if(siloless_hive_timer)
			deltimer(siloless_hive_timer)
			siloless_hive_timer = null
		return
	if(length(GLOB.xeno_resin_silos_by_hive[XENO_HIVE_NORMAL]))
		if(siloless_hive_timer)
			deltimer(siloless_hive_timer)
			siloless_hive_timer = null
		return

	//handle starting
	if(siloless_hive_timer)
		return

	silo_owner.xeno_message("We don't have any silos! The hive will collapse if nothing is done", "xenoannounce", 6, TRUE)
	siloless_hive_timer = addtimer(CALLBACK(src, PROC_REF(siloless_hive_collapse)), DISTRESS_SILO_COLLAPSE, TIMER_STOPPABLE)

///called by [/proc/update_silo_death_timer] after [DISTRESS_SILO_COLLAPSE] elapses to end the round
/datum/game_mode/infestation/distress/proc/siloless_hive_collapse()
	if(!(flags_round_type & MODE_INFESTATION))
		return
	if(round_finished)
		return
	if(round_stage == INFESTATION_MARINE_CRASHING)
		return
	round_finished = MODE_INFESTATION_M_MAJOR


/datum/game_mode/infestation/distress/get_siloless_collapse_countdown()
	var/eta = timeleft(siloless_hive_timer) MILLISECONDS
	return !isnull(eta) ? round(eta) : 0
