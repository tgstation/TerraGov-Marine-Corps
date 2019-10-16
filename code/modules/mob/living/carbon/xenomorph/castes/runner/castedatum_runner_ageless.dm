/datum/xeno_caste/runner/ageless
	caste_desc = "An incredibly fast four-legged terror, it is pretty weak in direct combat, and thus generally focuses on hit and run tactics."

	upgrade = XENO_UPGRADE_AGELESS

	// *** Melee Attacks *** //
	melee_damage = 25

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -2

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 2

	// *** Health *** //
	max_health = 150

	// *** Defense *** //
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = XENO_BOMB_RESIST_0, "bio" = 5, "rad" = 5, "fire" = 5, "acid" = 5)

	// *** Ranged Attack *** //
	pounce_delay = 3.5 SECONDS