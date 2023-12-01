/datum/xeno_caste/puppet
	caste_name = "Puppet"
	display_name = "Puppet"
	upgrade_name = ""
	caste_desc = "A grotesque puppet of a puppeteer."
	wound_type = ""

	caste_type_path = /mob/living/carbon/xenomorph/puppet

	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE
	melee_damage = 15
	speed = -0.8
	plasma_max = 2
	plasma_gain = 0
	max_health = 250
	caste_flags = CASTE_NOT_IN_BIOSCAN|CASTE_DO_NOT_ANNOUNCE_DEATH|CASTE_DO_NOT_ALERT_LOW_LIFE
	minimap_icon = "puppet"
	soft_armor = list(MELEE = 14, BULLET = 3, LASER = 5, ENERGY = 3, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/activable/xeno/feed,
	)
