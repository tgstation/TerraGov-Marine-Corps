/datum/xeno_caste/warrior
	caste_name = "Warrior"
	display_name = "Warrior"
	upgrade_name = ""
	caste_desc = "A powerful front line combatant."
	caste_type_path = /mob/living/carbon/xenomorph/warrior
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "warrior" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 80
	plasma_gain = 8

	// *** Health *** //
	max_health = 290

	// *** Evolution *** //
	evolution_threshold = 180
	upgrade_threshold = TIER_TWO_YOUNG_THRESHOLD

	evolves_to = list(/mob/living/carbon/xenomorph/crusher, /mob/living/carbon/xenomorph/gorger, /mob/living/carbon/xenomorph/warlock)
	deevolves_to = /mob/living/carbon/xenomorph/defender

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_IS_STRONG
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list(MELEE = 30, BULLET = 40, LASER = 40, ENERGY = 30, BOMB = 20, BIO = 36, FIRE = 40, ACID = 36)

	// *** Minimap Icon *** //
	minimap_icon = "warrior"

	// *** Warrior Abilities *** //
	agility_speed_increase = -0.6
	agility_speed_armor = -30

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/toggle_agility,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/fling,
		/datum/action/xeno_action/activable/toss,
		/datum/action/xeno_action/activable/punch,
	)

/datum/xeno_caste/warrior/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/warrior/mature
	upgrade_name = "Mature"
	caste_desc = "An alien with an armored carapace. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 10

	// *** Health *** //
	max_health = 310

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 34, BULLET = 45, LASER = 45, ENERGY = 34, BOMB = 20, BIO = 36, FIRE = 45, ACID = 36)

	// *** Warrior Abilities *** //
	agility_speed_increase = -0.6
	agility_speed_armor = -30

/datum/xeno_caste/warrior/elder
	upgrade_name = "Elder"
	caste_desc = "An alien with an armored carapace. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -0.45

	// *** Plasma *** //
	plasma_max = 115
	plasma_gain = 11

	// *** Health *** //
	max_health = 330

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 38, BULLET = 50, LASER = 50, ENERGY = 38, BOMB = 20, BIO = 40, FIRE = 50, ACID = 40)

	// *** Warrior Abilities *** //
	agility_speed_increase = -0.6
	agility_speed_armor = -30

/datum/xeno_caste/warrior/ancient
	upgrade_name = "Ancient"
	caste_desc = "An hulking beast capable of effortlessly breaking and tearing through its enemies."
	ancient_message = "None can stand before us. We will annihilate all weaklings who try."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 120
	plasma_gain = 12

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 42, BULLET = 55, LASER = 55, ENERGY = 42, BOMB = 20, BIO = 50, FIRE = 55, ACID = 50)

	// *** Warrior Abilities *** //
	agility_speed_increase = -0.6
	agility_speed_armor = -30

/datum/xeno_caste/warrior/primordial
	upgrade_name = "Primordial"
	caste_desc = "A champion of the hive, methodically shatters its opponents with punches rather slashes."
	primordial_message = "Our rhythm is unmatched and our strikes lethal, no single foe can stand against us."
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 120
	plasma_gain = 12

	// *** Health *** //
	max_health = 350

	// *** Defense *** //
	soft_armor = list(MELEE = 42, BULLET = 55, LASER = 55, ENERGY = 42, BOMB = 20, BIO = 50, FIRE = 55, ACID = 50)

	// *** Warrior Abilities *** //
	agility_speed_increase = -0.6
	agility_speed_armor = -30

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/toggle_agility,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/fling,
		/datum/action/xeno_action/activable/toss,
		/datum/action/xeno_action/activable/punch,
		/datum/action/xeno_action/activable/punch/jab,
	)
