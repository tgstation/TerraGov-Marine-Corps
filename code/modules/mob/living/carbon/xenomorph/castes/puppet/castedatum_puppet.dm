/datum/xeno_caste/puppet
	caste_name = "Puppet"
	display_name = "Puppet"
	upgrade_name = ""
	caste_desc = "A grotesque puppet of a puppeteer."
	wound_type = ""

	caste_type_path = /mob/living/carbon/xenomorph/puppet

	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 15

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 2
	plasma_gain = 0

	// *** Health *** //
	max_health = 150

	// *** Flags *** //
	caste_flags = CASTE_NOT_IN_BIOSCAN|CASTE_DO_NOT_ANNOUNCE_DEATH|CASTE_DO_NOT_ALERT_LOW_LIFE

	// *** Minimap Icon *** //
	minimap_icon = "puppet"

	// *** Defense *** //
	soft_armor = list(MELEE = 14, BULLET = 0, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/feed,
	)
