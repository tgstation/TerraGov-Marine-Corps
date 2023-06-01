/datum/xeno_caste/behemoth
	caste_name = "Behemoth"
	display_name = "Behemoth"
	upgrade_name = ""
	caste_type_path = /mob/living/carbon/xenomorph/behemoth
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "behemoth" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 19

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 175
	plasma_gain = 17

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/warrior

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_IS_STRONG|CASTE_STAGGER_RESISTANT
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	caste_traits = null

	// *** Defense *** //
	soft_armor = list(MELEE = 55, BULLET = 55, LASER = 55, ENERGY = 55, BOMB = 100, BIO = 55, FIRE = 55, ACID = 55)

	// *** Minimap Icon *** //
	minimap_icon = "crusher"

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/earth_riser,
		/datum/action/xeno_action/activable/seismic_fracture,
	)


/datum/xeno_caste/behemoth/young
	upgrade_name = "Young"
	upgrade = XENO_UPGRADE_ZERO


/datum/xeno_caste/behemoth/mature
	upgrade_name = "Mature"
	upgrade = XENO_UPGRADE_ONE

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 20

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 110, BIO = 60, FIRE = 60, ACID = 60)


/datum/xeno_caste/behemoth/elder
	upgrade_name = "Elder"
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 225
	plasma_gain = 22

	// *** Health *** //
	max_health = 375

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 65, BULLET = 65, LASER = 65, ENERGY = 65, BOMB = 120, BIO = 65, FIRE = 65, ACID = 65)


/datum/xeno_caste/behemoth/ancient
	upgrade_name = "Ancient"
	upgrade = XENO_UPGRADE_THREE

	// *** Plasma *** //
	plasma_max = 250
	plasma_gain = 25

	// *** Health *** //
	max_health = 400

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 70, BULLET = 70, LASER = 70, ENERGY = 70, BOMB = 130, BIO = 70, FIRE = 70, ACID = 70)


/datum/xeno_caste/behemoth/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 250
	plasma_gain = 25

	// *** Health *** //
	max_health = 400

	// *** Defense *** //
	soft_armor = list(MELEE = 70, BULLET = 70, LASER = 70, ENERGY = 70, BOMB = 130, BIO = 70, FIRE = 70, ACID = 70)

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/earth_riser,
		/datum/action/xeno_action/activable/seismic_fracture,
		/datum/action/xeno_action/primal_wrath,
	)
