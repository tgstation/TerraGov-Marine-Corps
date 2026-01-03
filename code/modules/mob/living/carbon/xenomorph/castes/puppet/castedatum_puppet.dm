/datum/xeno_caste/puppet
	caste_name = "Puppet"
	display_name = "Puppet"
	upgrade_name = ""
	caste_desc = "A grotesque puppet of a puppeteer."
	wound_type = ""
	base_strain_type = /mob/living/carbon/xenomorph/puppet
	caste_type_path = /mob/living/carbon/xenomorph/puppet

	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_BASETYPE
	melee_damage = 12
	accuracy_malus = 65
	speed = -0.5
	plasma_max = 100
	plasma_gain = 3
	max_health = 150
	caste_flags = CASTE_NOT_IN_BIOSCAN|CASTE_DO_NOT_ANNOUNCE_DEATH|CASTE_DO_NOT_ALERT_LOW_LIFE
	minimap_icon = "puppet"
	soft_armor = list(MELEE = 14, BULLET = 3, LASER = 5, ENERGY = 3, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/activable/xeno/feed,
		/datum/action/ability/xeno_action/psychic_whisper,
		/datum/action/ability/xeno_action/psychic_influence,
		/datum/action/ability/xeno_action/create_edible_jelly,
		/datum/action/ability/activable/xeno/impregnate,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/devour,
		/datum/action/ability/xeno_action/place_stew_pod,
	)
