/datum/xeno_caste/mantid
	caste_name = "Mantid"
	display_name = "Mantid"
	upgrade_name = ""
	caste_desc = "An alien with an armored crest. It looks like it's still developing." //Need a desc, this is defender desc

	caste_type_path = /mob/living/carbon/xenomorph/mantid

	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 20

	// *** Health *** //
	max_health = 200

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED

	// *** Defense *** //
	soft_armor = list("melee" = 14, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = XENO_BOMB_RESIST_0, "bio" = 0, "rad" = 0, "fire" = 5, "acid" = 0)

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/ravage,
	)
