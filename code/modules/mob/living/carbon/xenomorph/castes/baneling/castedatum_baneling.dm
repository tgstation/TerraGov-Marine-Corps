/datum/xeno_caste/baneling
	caste_name = "Baneling"
	display_name = "Baneling"
	upgrade_name = ""
	caste_desc = "Gross, cute, bloated and ready to explode!"
	base_strain_type = /mob/living/carbon/xenomorph/baneling
	caste_type_path = /mob/living/carbon/xenomorph/baneling

	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "baneling" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 16
	attack_delay = 6

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 275
	plasma_gain = 11

	// *** Health *** //
	max_health = 100

	// *** Flags *** //
	caste_flags = CASTE_DO_NOT_ALERT_LOW_LIFE|CASTE_IS_A_MINION
	can_flags = NONE
	caste_traits = null

	// *** Defense *** //
	soft_armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 20, BIO = 20, FIRE = 15, ACID = 100)

	// *** Minimap Icon *** //
	minimap_icon = "xenominion"

	// *** Abilities *** ///
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/select_reagent/baneling,
		/datum/action/ability/xeno_action/baneling_explode,
	)
