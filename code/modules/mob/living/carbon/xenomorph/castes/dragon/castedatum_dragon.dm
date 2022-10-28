/datum/xeno_caste/dragon
	caste_name = "Dragon"
	display_name = "Dragon"
	// caste_desc = "todo"
	caste_type_path = /mob/living/carbon/xenomorph/dragon
	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "dragon" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 25

	// *** Speed *** //
	speed = 0.3

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 40

	// *** Health *** //
	max_health = 450

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	deevolves_to = list(/mob/living/carbon/xenomorph/ravager, /mob/living/carbon/xenomorph/shrike, /mob/living/carbon/xenomorph/gorger, /mob/living/carbon/xenomorph/praetorian)

	// *** Flags *** //
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 45, FIRE = 60, ACID = 45)

	// *** Minimap Icon *** //
	// minimap_icon = "todo"


/datum/xeno_caste/dragon/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/dragon/mature
	upgrade_name = "Mature"
	// caste_desc = "todo"
	upgrade = XENO_UPGRADE_ONE

    // *** Melee Attacks *** //
	melee_damage = 30

	// *** Speed *** //
	speed = 0.2

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 550

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 5, BIO = 50, FIRE = 65, ACID = 50)

/datum/xeno_caste/dragon/elder
	upgrade_name = "Elder"
	// caste_desc = "todo"
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 35

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 1100
	plasma_gain = 60

	// *** Health *** //
	max_health = 600

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 5, FIRE = 70, ACID = 55)

/datum/xeno_caste/dragon/ancient
	upgrade_name = "Ancient"
	// caste_desc = "todo"
	upgrade = XENO_UPGRADE_THREE
	// ancient_message = "todo"

	// *** Melee Attacks *** //
	melee_damage = 35

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 1200
	plasma_gain = 70

	// *** Health *** //
	max_health = 700

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 60, FIRE = 85, ACID = 60)

/datum/xeno_caste/dragon/primordial
	upgrade_name = "Primordial"
	// caste_desc = "ODO"
	upgrade = XENO_UPGRADE_FOUR
	// primordial_message = "TODO"

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 1200
	plasma_gain = 70

	// *** Health *** //
	max_health = 700

	// *** Defense *** //
	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 60, FIRE = 85, ACID = 60)

	// *** Abilities *** //
	// actions = list(
	// )
