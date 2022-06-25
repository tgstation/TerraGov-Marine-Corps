/datum/xeno_caste/scorpion
	caste_name = "Scorpion"
	display_name = "Scorpion"
	upgrade_name = ""
	caste_desc = ""
	wound_type = ""

	caste_type_path = /mob/living/carbon/xenomorph/scorpion

	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 12

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 1500// 20 spits
	plasma_gain = 10

	// *** Health *** //
	max_health = 130

	// *** Flags *** //
	caste_flags = CASTE_DO_NOT_ALERT_LOW_LIFE|CASTE_IS_A_MINION
	can_flags = CASTE_CAN_BE_QUEEN_HEALED

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 0, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)

	// *** Ranged Attack *** //
	spit_delay = 1.8 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/passthrough)

	minimap_icon = "xenominion"

	// *** Abilities *** //
	actions = list\(
		/datum/action/xeno_action/show_hivestatus,
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/xeno_spit,
	)
