/datum/xeno_caste/spitter/ageless
	caste_desc = "A ranged alien with deadly acid spit."

	upgrade = XENO_UPGRADE_AGELESS

	// *** Melee Attacks *** //
	melee_damage = 30

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -0.7

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 25

	// *** Health *** //
	max_health = 225

	// *** Defense *** //
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS

	acid_delay = 30 SECONDS //30 second delay on acid spray.