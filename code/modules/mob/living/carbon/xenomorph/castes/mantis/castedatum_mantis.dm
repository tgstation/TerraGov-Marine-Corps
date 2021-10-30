/datum/xeno_caste/mantis
	caste_name = "Mantis"
	display_name = "Mantis"
	upgrade_name = ""
	caste_desc = ""
	wound_type = ""

	caste_type_path = /mob/living/carbon/xenomorph/mantis

	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 600 //3 ravage
	plasma_gain = 20

	// *** Health *** //
	max_health = 200

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED

	// *** Defense *** //
	soft_armor = list("melee" = 14, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = XENO_BOMB_RESIST_0, "bio" = 0, "rad" = 0, "fire" = 5, "acid" = 0)

	minimap_icon = "xenominion"

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/ravage,
	)
