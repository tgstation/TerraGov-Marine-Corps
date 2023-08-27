/datum/xeno_caste/baneling
	caste_name = "Baneling"
	display_name = "Baneling"
	upgrade_name = ""
	caste_desc = "Gross, cute, bloated and ready to explode!"
	caste_type_path = /mob/living/carbon/xenomorph/baneling
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "baneling" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 14
	attack_delay = 6

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 200
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
	soft_armor = list(MELEE = 10, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 5, BIO = 5, FIRE = 0, ACID = 100)

	// *** Minimap Icon *** //
	minimap_icon = "baneling"

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/spawn_pod,
		/datum/action/xeno_action/select_reagent/baneling,
		/datum/action/xeno_action/baneling_explode,
	)

/datum/xeno_caste/baneling/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/baneling/mature
	upgrade_name = "Mature"
	caste_desc = "A bloated, rolling cute thing. It looks a little more denser and dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -1.4

	// *** Plasma *** //
	plasma_max = 225
	plasma_gain = 7

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 15, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, FIRE = 5, ACID = 100)

/datum/xeno_caste/baneling/elder
	upgrade_name = "Elder"
	caste_desc = "A bloated, rolling cute thing. It looks a pretty big."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 14

	// *** Speed *** //
	speed = -1.5

	// *** Plasma *** //
	plasma_max = 250
	plasma_gain = 9

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 20, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 15, FIRE = 10, ACID = 100)

/datum/xeno_caste/baneling/ancient
	upgrade_name = "Ancient"
	caste_desc = "It looks like it's going to explode in any moment!"
	ancient_message = "We are the biological explosive ordnance ready to explode at marine. Show them what you are made out of!"
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 16

	// *** Speed *** //
	speed = -1.6

	// *** Plasma *** //
	plasma_max = 275
	plasma_gain = 11

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 20, BIO = 20, FIRE = 15, ACID = 100)

/datum/xeno_caste/baneling/primordial
	upgrade_name = "Primordial"
	caste_desc = "A reckless ball with VERY low temper, it is out for blood at any moment!"
	primordial_message = "Nothing can escape our toxic cloud!"
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 16

	// *** Speed *** //
	speed = -1.6

	// *** Plasma *** //
	plasma_max = 275
	plasma_gain = 11

	// *** Health *** //
	max_health = 240

	// *** Defense *** //
	soft_armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 20, BIO = 20, FIRE = 15, ACID = 100)

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_MEDIUM

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/spawn_pod,
		/datum/action/xeno_action/select_reagent/baneling,
		/datum/action/xeno_action/baneling_explode,
		/datum/action/xeno_action/activable/dash_explosion,
	)
