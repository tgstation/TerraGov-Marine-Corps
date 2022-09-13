/datum/xeno_caste/spiderling
	caste_name = "spiderling"
	display_name = "spiderling"
	upgrade_name = ""
	caste_desc = ""
	wound_type = ""

	caste_type_path = /mob/living/carbon/xenomorph/spiderling

	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 10

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 1

	// *** Health *** //
	max_health = 150

	// *** Flags *** //
	caste_flags = CASTE_DO_NOT_ALERT_LOW_LIFE|CASTE_NOT_IN_BIOSCAN

	// *** Minimap Icon *** //
	minimap_icon = "spiderling"

	// *** Defense *** //
	soft_armor = list(MELEE = 14, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 5, ACID = 0)

	actions = list()
