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
	speed = -1.5

	// *** Plasma *** //
	plasma_max = 250
	plasma_gain = 9

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_THRESHOLD

	evolves_to = list(
		/mob/living/carbon/xenomorph/spitter,
		/mob/living/carbon/xenomorph/bull,
	)

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 20, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 15, FIRE = 10, ACID = 100)

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

/datum/xeno_caste/baneling/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/baneling/primordial
	upgrade_name = "Primordial"
	caste_desc = "A reckless ball with VERY low temper, it is out for blood at any moment!"
	primordial_message = "Nothing can escape our toxic cloud!"
	upgrade = XENO_UPGRADE_PRIMO

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
