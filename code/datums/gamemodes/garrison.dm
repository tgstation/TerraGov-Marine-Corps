/datum/game_mode/infestation/garrison
	name = "Garrison Defence"
	config_tag = "Garrison Defence"
	flags_round_type = MODE_INFESTATION|MODE_LATE_OPENING_SHUTTER_TIMER|MODE_PSY_POINTS|MODE_PSY_POINTS_ADVANCED|MODE_DEAD_GRAB_FORBIDDEN|MODE_SILO_RESPAWN|MODE_SILOS_SPAWN_MINIONS|MODE_ALLOW_XENO_QUICKBUILD
	flags_xeno_abilities = ABILITY_DISTRESS
	whitelist_ground_maps = list()
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
		/datum/job/xenomorph/queen = 1
	)
	/// Xeno base reference, if this is killed round ends
	var/obj/structure/xeno/silo/core/xeno_base
	/// Marine base reference, if this is killed round ends
	var/obj/structure/control_core/marine_base

/datum/game_mode/infestation/garrison/post_setup()
	. = ..()
	SSpoints.add_psy_points(XENO_HIVE_NORMAL, 2 * SILO_PRICE + 4 * XENO_TURRET_PRICE)

	for(var/i in GLOB.xeno_turret_turfs)
		new /obj/structure/xeno/xeno_turret(i)
	for(var/obj/effect/landmark/corpsespawner/corpse AS in GLOB.corpse_landmarks_list)
		corpse.create_mob()

	xeno_base = new(pick(GLOB.xeno_base_silo_turfs))
	RegisterSignal(xeno_base, COMSIG_OBJ_DECONSTRUCT, .proc/xeno_base_destroyed)
	RegisterSignal(xeno_base, COMSIG_PARENT_QDELETING, .proc/xeno_base_deleted)

	marine_base = new(pick(GLOB.marine_control_unit_turfs))
	RegisterSignal(marine_base, COMSIG_OBJ_DECONSTRUCT, .proc/marine_base_destroyed)
	RegisterSignal(marine_base, COMSIG_PARENT_QDELETING, .proc/marine_base_deleted)

	var/list/obj/structure/xeno_towers = list()
	var/list/obj/structure/marine_towers = list()

	for(var/i in GLOB.xeno_base_turret_turfs)
		xeno_towers += new /obj/structure/xeno/xeno_turret/garrison(i)
	xeno_base.AddComponent(/datum/component/linked_invincibility, xeno_towers)

	for(var/i in GLOB.marine_base_turret_turfs)
		marine_towers += new /obj/item/weapon/gun/sentry/big_sentry/garrison(i)
	marine_base.AddComponent(/datum/component/linked_invincibility, marine_towers)

/datum/game_mode/infestation/garrison/scale_roles(initial_players_assigned)
	. = ..()
	if(!.)
		return
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/xenomorph)
	scaled_job.job_points_needed  = DISTRESS_LARVA_POINTS_NEEDED

///handles game ending upon xeno base being destroyed
/datum/game_mode/infestation/garrison/proc/xeno_base_destroyed(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(xeno_base, COMSIG_PARENT_QDELETING)
	xeno_base = null
	round_finished = MODE_INFESTATION_M_MAJOR
	message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]")

/// Xeno base deleted without deconstruct being called aka admin or bug deleted it
/datum/game_mode/infestation/garrison/proc/xeno_base_deleted(datum/source)
	SIGNAL_HANDLER
	xeno_base = null
	message_admins("Xeno base deleted unexpectedly. Please end the round manually or replace with a new xeno base using VV.")

///handles game ending upon marine base being destroyed
/datum/game_mode/infestation/garrison/proc/marine_base_destroyed(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(marine_base, COMSIG_PARENT_QDELETING)
	marine_base = null
	round_finished = MODE_INFESTATION_X_MAJOR
	message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]")

/// Marine base deleted without deconstruct being called aka admin or bug deleted it
/datum/game_mode/infestation/garrison/proc/marine_base_deleted(datum/source)
	SIGNAL_HANDLER
	marine_base = null
	message_admins("Marine base deleted unexpectedly. Please end the round manually or replace with a new xeno base using VV.")
