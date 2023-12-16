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
	melee_damage = 16
	attack_delay = 6

	// *** Speed *** //
	speed = -1.6

	// *** Plasma *** //
	plasma_max = 275
	plasma_gain = 11

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	evolution_threshold = 100
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
	soft_armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 20, BIO = 20, FIRE = 15, ACID = 100)

	// *** Minimap Icon *** //
	minimap_icon = "baneling"

	// *** Abilities *** ///
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno/baneling,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/spawn_pod,
		/datum/action/ability/xeno_action/select_reagent/baneling,
		/datum/action/ability/xeno_action/baneling_explode,
	)

/datum/xeno_caste/baneling/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/baneling/primordial
	upgrade_name = "Primordial"
	caste_desc = "A reckless ball with VERY low temper, it is out for blood at any moment!"
	primordial_message = "Nothing can escape our toxic cloud!"
	upgrade = XENO_UPGRADE_PRIMO

	// *** Abilities *** ///
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno/baneling,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/spawn_pod,
		/datum/action/ability/xeno_action/select_reagent/baneling,
		/datum/action/ability/xeno_action/baneling_explode,
		/datum/action/ability/activable/xeno/dash_explosion,
	)
