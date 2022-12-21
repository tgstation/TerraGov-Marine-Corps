/datum/xeno_caste/hivemind
	caste_name = "Hivemind"
	display_name = "Hivemind"
	upgrade_name = ""
	caste_desc = "The mind of the hive"
	caste_type_path = /mob/living/carbon/xenomorph/hivemind
	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = ""
	// *** Melee Attacks *** //
	melee_damage = 0

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 600 //  75 is the cost of plant_weeds
	plasma_gain = 60

	// *** Health *** //
	max_health = 100

	// *** Flags *** //
	caste_flags = CASTE_INNATE_PLASMA_REGEN|CASTE_FIRE_IMMUNE|CASTE_IS_BUILDER|CASTE_DO_NOT_ALERT_LOW_LIFE
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	// *** Minimap Icon *** //
	minimap_icon = "hivemind"

	// *** Ranged Attack *** //
	spit_delay = 0 SECONDS
	spit_types = list()

	aura_strength = 0

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/watch_xeno/hivemind,
		/datum/action/xeno_action/change_form,
		/datum/action/xeno_action/return_to_core,
		/datum/action/xeno_action/rally_hive/hivemind,
		/datum/action/xeno_action/activable/command_minions,
		/datum/action/xeno_action/activable/plant_weeds/ranged,
		/datum/action/xeno_action/activable/psychic_cure/hivemind,
		/datum/action/xeno_action/activable/transfer_plasma/hivemind,
		/datum/action/xeno_action/pheromones/hivemind,
		/datum/action/xeno_action/pheromones/emit_recovery,
		/datum/action/xeno_action/pheromones/emit_warding,
		/datum/action/xeno_action/pheromones/emit_frenzy,
		/datum/action/xeno_action/activable/secrete_resin/ranged/slow,
	)

/datum/xeno_caste/hivemind/on_caste_applied(mob/xenomorph)
	return

/datum/xeno_caste/hivemind/on_caste_removed(mob/xenomorph)
	return

/datum/xeno_caste/hivemind/hivemind_manifestation
	caste_desc = "The manifestation of the hivemind"
	wound_type = "hivemind"

	upgrade = XENO_UPGRADE_MANIFESTATION

	// *** Flags *** //
	caste_flags = CASTE_IS_BUILDER|CASTE_FIRE_IMMUNE

	aura_strength = 4 //Good pheros

	speed = 1.5
