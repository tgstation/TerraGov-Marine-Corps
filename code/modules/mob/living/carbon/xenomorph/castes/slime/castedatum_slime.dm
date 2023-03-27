/datum/xeno_caste/slime
	caste_name = "Slime"
	display_name = "Slime"
	upgrade_name = ""
	caste_desc = "A creature whose body is made of an oozy substance that melts anything it touches."
	caste_type_path = /mob/living/carbon/xenomorph/slime

	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = null
	melee_damage = 10
	melee_damage_type = BURN
	speed = -0.1
	plasma_max = 125
	plasma_gain = 12
	max_health = 225
	evolution_threshold = 80
	upgrade_threshold = TIER_ONE_YOUNG_THRESHOLD
	evolves_to = list(
		/mob/living/carbon/xenomorph/wraith,
		/mob/living/carbon/xenomorph/spitter,
	)
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_RIDE_CRUSHER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)
	soft_armor = list(MELEE = 45, BULLET = 45, LASER = 0, ENERGY = 0, BOMB = 45, BIO = 95, FIRE = 0, ACID = 95)
	minimap_icon = "slime"
	additional_stacks = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/acidic_trail,
		/datum/action/xeno_action/activable/attach_pounce,
		/datum/action/xeno_action/spread_tendrils,
		/datum/action/xeno_action/activable/extend_tendril,
	)

/datum/xeno_caste/slime/young
	upgrade_name = "Young"
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/slime/mature
	upgrade_name = "Mature"
	upgrade = XENO_UPGRADE_ONE
	plasma_max = 150
	plasma_gain = 15
	max_health = 250
	upgrade_threshold = TIER_ONE_MATURE_THRESHOLD
	additional_stacks = 1

/datum/xeno_caste/slime/elder
	upgrade_name = "Elder"
	upgrade = XENO_UPGRADE_TWO
	melee_damage = 11
	speed = -0.2
	plasma_max = 175
	plasma_gain = 17
	max_health = 275
	upgrade_threshold = TIER_ONE_ELDER_THRESHOLD
	soft_armor = list(MELEE = 48, BULLET = 48, LASER = 0, ENERGY = 0, BOMB = 48, BIO = 98, FIRE = 0, ACID = 98)
	additional_stacks = 2

/datum/xeno_caste/slime/ancient
	upgrade_name = "Ancient"
	ancient_message = "Let us consume everything."
	upgrade = XENO_UPGRADE_THREE
	melee_damage = 12
	speed = -0.3
	plasma_max = 200
	plasma_gain = 20
	max_health = 300
	upgrade_threshold = TIER_ONE_ANCIENT_THRESHOLD
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 100, FIRE = 0, ACID = 100)
	additional_stacks = 3

/datum/xeno_caste/slime/primordial
	upgrade_name = "Primordial"
	ancient_message = "All will be eroded to oblivion."
	upgrade = XENO_UPGRADE_FOUR
	melee_damage = 12
	speed = -0.3
	plasma_max = 200
	plasma_gain = 20
	max_health = 300
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 100, FIRE = 0, ACID = 100)
	additional_stacks = 3
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/acidic_trail,
		/datum/action/xeno_action/activable/attach_pounce,
		/datum/action/xeno_action/spread_tendrils,
		/datum/action/xeno_action/activable/extend_tendril,
		/datum/action/xeno_action/activable/toxic_burst,
	)
