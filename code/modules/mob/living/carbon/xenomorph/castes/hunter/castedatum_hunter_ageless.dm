/datum/xeno_caste/hunter/ageless
	caste_desc = "A fast, powerful assassin. She blends into the shadows, able to do devastating damage with sneak attacks."

	upgrade = XENO_UPGRADE_AGELESS

	// *** Melee Attacks *** //
	melee_damage = 40
	attack_delay = 6.5

	// *** Tackle *** //
	tackle_damage = 45

	// *** Speed *** //
	speed = -1.6

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 15

	// *** Health *** //
	max_health = 225

	// *** Defense *** //
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = XENO_BOMB_RESIST_0, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)

	// *** Ranged Attack *** //
	pounce_delay = 10.0 SECONDS