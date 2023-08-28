/datum/xeno_caste/predalien
	caste_name = "Predalien"
	display_name = "Abomination"
	caste_type_path = /mob/living/carbon/xenomorph/predalien
	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "Predalien"

	charge_type = CHARGE_TYPE_LARGE

	// *** Melee Attacks *** //
	melee_damage = 40

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 5

	soft_armor = list(MELEE = 60, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 80, BIO = 60, FIRE = 30, ACID = 60)

	// *** Health *** //
	max_health = 650

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

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


/datum/xeno_caste/predalien/young
	upgrade_name = "Young"
	upgrade = XENO_UPGRADE_ZERO

	// *** Melee Attacks *** //
	melee_damage = 45

/datum/xeno_caste/predalien/mature
	upgrade_name = "Mature"
	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 50

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

/datum/xeno_caste/predalien/elder
	upgrade_name = "Elder"
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 55

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

/datum/xeno_caste/predalien/ancient
	upgrade_name = "Ancient"
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 60

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

/datum/xeno_caste/predalien/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 65
