/datum/xeno_caste/nymph
	caste_name = "Nymph"
	display_name = "Nymph"
	upgrade_name = ""
	caste_desc = ""
	wound_type = ""

	caste_type_path = /mob/living/carbon/xenomorph/nymph

	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 5

	// *** Speed *** //
	speed = 1

	// *** Plasma *** //
	plasma_max = 320 ///4 forward charges
	plasma_gain = 10

	// *** Health *** //
	max_health = 100

	// *** Flags *** //
	caste_flags = CASTE_DO_NOT_ALERT_LOW_LIFE|CASTE_IS_A_MINION
	can_flags = CASTE_CAN_BE_QUEEN_HEALED

	// *** Defense *** //
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/plant_weeds/free,
	)
