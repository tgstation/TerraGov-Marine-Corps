/datum/xeno_caste/baneling
	caste_name = "Baneling"
	display_name = "baneling"
	upgrade_name = ""
	caste_desc = ""
	caste_type_path = /mob/living/carbon/xenomorph/baneling
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "baneling" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 1
	attack_delay = 1

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 5

	// *** Health *** //
	max_health = 175

	// *** Evolution *** //
	evolution_threshold = 80
	upgrade_threshold = TIER_ONE_YOUNG_THRESHOLD

	evolves_to = list(
		/mob/living/carbon/xenomorph/spitter,
		/mob/living/carbon/xenomorph/bull,
	)

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	// *** Minimap Icon *** //
	minimap_icon = "baneling"

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
	)

/datum/xeno_caste/baneling/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/baneling/mature
	upgrade_name = "Mature"
	caste_desc = ""

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -1.3

	// *** Plasma *** //
	plasma_max = 175
	plasma_gain = 7

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/datum/xeno_caste/baneling/elder
	upgrade_name = "Elder"
	caste_desc = ""

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 1

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 9

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/datum/xeno_caste/baneling/ancient
	upgrade_name = "Ancient"
	caste_desc = ""
	ancient_message = ""
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 21

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 11

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/datum/xeno_caste/baneling/primordial
	upgrade_name = "Primordial"
	caste_desc = ""
	primordial_message = ""
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 21

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 11

	// *** Health *** //
	max_health = 240

	// *** Defense *** //
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
	)
