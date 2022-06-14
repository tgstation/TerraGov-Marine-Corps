/datum/game_mode/infestation/distress/nuclear_war/trouble_in_terrorist_town
	name = "Trouble In Terrorist Town"
	config_tag = "Trouble In Terrorist Town"
	flags_round_type = MODE_INFESTATION|MODE_LZ_SHUTTERS|MODE_XENO_RULER|MODE_PSY_POINTS|MODE_PSY_POINTS_ADVANCED|MODE_DEAD_GRAB_FORBIDDEN|MODE_HIJACK_POSSIBLE|MODE_SILO_RESPAWN|MODE_SPAWNING_MINIONS|MODE_TROUBLE_IN_TERRORIST_TOWN
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
		/datum/job/xenomorph = FREE_XENO_AT_START
	)

/datum/game_mode/infestation/distress/nuclear_war/trouble_in_terrorist_town/pre_setup()
	. = ..()
	GLOB.xeno_caste_datums[/mob/living/carbon/xenomorph/larva][XENO_UPGRADE_INVALID].evolves_to = list(
		/mob/living/carbon/xenomorph/drone,
		/mob/living/carbon/xenomorph/hunter,
	)
	for(var/upgrade in GLOB.xenoupgradetiers)
		var/datum/xeno_caste/caste = GLOB.xeno_caste_datums[/mob/living/carbon/xenomorph/hunter][upgrade]
		if(!caste)
			continue
		caste.actions = list(
			/datum/action/xeno_action/xeno_resting,
			/datum/action/xeno_action/watch_xeno,
			/datum/action/xeno_action/activable/psydrain,
			/datum/action/xeno_action/activable/pounce/hunter,
			/datum/action/xeno_action/stealth/disguise,
			/datum/action/xeno_action/activable/hunter_mark,
			/datum/action/xeno_action/psychic_trace,
			/datum/action/xeno_action/mirage,
			/datum/action/xeno_action/swap,
			)
		caste.evolves_to = list()
		caste.caste_flags |= CASTE_IS_INTELLIGENT

	for(var/upgrade in GLOB.xenoupgradetiers)
		var/datum/xeno_caste/caste =  GLOB.xeno_caste_datums[/mob/living/carbon/xenomorph/drone][upgrade]
		if(!caste)
			continue
		caste.actions = list(
			/datum/action/xeno_action/xeno_resting,
			/datum/action/xeno_action/watch_xeno,
			/datum/action/xeno_action/activable/psydrain,
			/datum/action/xeno_action/activable/cocoon,
			/datum/action/xeno_action/activable/plant_weeds,
			/datum/action/xeno_action/activable/secrete_resin,
			/datum/action/xeno_action/activable/psychic_cure/acidic_salve,
			/datum/action/xeno_action/activable/transfer_plasma/drone,
			/datum/action/xeno_action/activable/corrosive_acid/drone,
			/datum/action/xeno_action/activable/neurotox_sting/ozelomelyn,
			/datum/action/xeno_action/create_jelly/slow,
			/datum/action/xeno_action/pheromones,
			/datum/action/xeno_action/pheromones/emit_recovery,
			/datum/action/xeno_action/pheromones/emit_warding,
			/datum/action/xeno_action/pheromones/emit_frenzy,
			/datum/action/xeno_action/blessing_menu,
			/datum/action/xeno_action/stealth/disguise,
			/datum/action/xeno_action/activable/hunter_mark,
		)
		caste.evolves_to = list()
		caste.caste_flags |= CASTE_IS_INTELLIGENT
