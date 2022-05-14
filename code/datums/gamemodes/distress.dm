/datum/game_mode/infestation/distress
	name = "Distress Signal"
	config_tag = "Distress Signal"

	//More larvas in RUTGMC
	silo_scaling = 1.2

	flags_round_type = MODE_INFESTATION|MODE_LZ_SHUTTERS|MODE_XENO_RULER|MODE_PSY_POINTS|MODE_PSY_POINTS_ADVANCED|MODE_DEAD_GRAB_FORBIDDEN|MODE_HIJACK_POSSIBLE|MODE_SILO_RESPAWN|MODE_SPAWNING_MINIONS
	flags_landmarks = MODE_LANDMARK_SPAWN_XENO_TURRETS
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
		/datum/job/terragov/silicon/ai = 1,
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 1,
		/datum/job/terragov/squad/leader = 1,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/xenomorph = FREE_XENO_AT_START,
		/datum/job/xenomorph/queen = 1
	)
	var/siloless_hive_timer

/datum/game_mode/infestation/distress/post_setup()
	. = ..()
	SSpoints.add_psy_points(XENO_HIVE_NORMAL, 2 * SILO_PRICE + 4 * XENO_TURRET_PRICE)

	for(var/i in GLOB.xeno_turret_turfs)
		new /obj/structure/xeno/xeno_turret(i)
	for(var/obj/effect/landmark/corpsespawner/corpse AS in GLOB.corpse_landmarks_list)
		corpse.create_mob(COCOONED_DEATH)


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


/datum/game_mode/infestation/distress/siloless_hive_collapse()
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
