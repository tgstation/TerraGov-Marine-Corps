/datum/xeno_caste/predalien
	caste_name = "Predalien"
	display_name = "Abomination"
	caste_type_path = /mob/living/carbon/xenomorph/predalien
	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "Predalien"

	// *** Melee Attacks *** //
	melee_damage = 60

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 5

	soft_armor = list(MELEE = 60, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 80, BIO = 60, FIRE = 30, ACID = 60)

	// *** Health *** //
	max_health = 650

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD

	// *** Minimap Icon *** //
	minimap_icon = "predalien"

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/pounce/predalien,
		/datum/action/xeno_action/activable/predalien_roar,
		/datum/action/xeno_action/activable/smash,
		/datum/action/xeno_action/activable/devastate,
	)


/datum/xeno_caste/predalien/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/predalien/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_PRIMO

