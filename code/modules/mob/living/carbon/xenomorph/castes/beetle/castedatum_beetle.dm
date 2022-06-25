/datum/xeno_caste/beetle
	caste_name = "Beetle"
	display_name = "Beetle"
	upgrade_name = ""
	caste_desc = ""
	wound_type = ""

	caste_type_path = /mob/living/carbon/xenomorph/beetle

	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 17

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 320 ///4 forward charges
	plasma_gain = 10

	// *** Health *** //
	max_health = 260

	// *** Flags *** //
	caste_flags = CASTE_DO_NOT_ALERT_LOW_LIFE|CASTE_IS_A_MINION
	can_flags = CASTE_CAN_BE_QUEEN_HEALED

	// *** Defense *** //
	soft_armor = list("melee" = 30, "bullet" = 30, "laser" = 25, "energy" = 20, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 30, "acid" = 20)

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_LARGE

	minimap_icon = "xenominion"

	actions = list\(
		/datum/action/xeno_action/show_hivestatus,
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/forward_charge/unprecise,
	)
