/datum/xeno_caste/spiderling
	caste_name = "spiderling"
	display_name = "spiderling"
	upgrade_name = ""
	caste_desc = "An anthropod xenomorph without any qualms to obey their widow, even if it will never grow up and will face death."
	wound_type = ""

	caste_type_path = /mob/living/carbon/xenomorph/spiderling

	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 8

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 1

	// *** Health *** //
	max_health = 125

	// *** Flags *** //
	caste_flags = CASTE_NOT_IN_BIOSCAN|CASTE_DO_NOT_ANNOUNCE_DEATH|CASTE_DO_NOT_ALERT_LOW_LIFE

	// *** Minimap Icon *** //
	minimap_icon = "spiderling"

	// *** Defense *** //
	soft_armor = list(MELEE = 15, BULLET = 0, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	actions = list(
		/datum/action/ability/xeno_action/burrow,
	)
