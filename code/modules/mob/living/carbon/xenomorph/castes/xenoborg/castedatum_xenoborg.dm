/datum/xeno_caste/xenoborg
	caste_name = "Xenoborg"
	display_name = "Xenoborg"
	upgrade_name = ""
	caste_desc = "Oh dear god!"
	caste_type_path = /mob/living/carbon/Xenomorph/Xenoborg

	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage_lower = 24
	melee_damage_upper = 24

	// *** Tackle *** //
	tackle_damage = 50 //How much HALLOSS damage a xeno deals when tackling

	// *** Speed *** //
	speed = -2.1

	// *** Plasma *** //
	plasma_max = 1500
	plasma_gain = 0

	// *** Health *** //
	max_health = 300

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_IS_ROBOTIC|CASTE_FIRE_IMMUNE|CASTE_DECAY_PROOF|CASTE_HIDE_IN_STATUS

	// *** Defense *** //
	armor_deflection = 90 //Chance of deflecting projectiles.

	// *** Ranged Attack *** //
	charge_type = 1 //Pounce
	pounce_delay = 4 SECONDS

/datum/xeno_caste/xenoborg/young
	upgrade = XENO_UPGRADE_INVALID
	