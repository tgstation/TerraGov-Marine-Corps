/datum/xeno_caste/boiler/ageless
	caste_desc = "A specialized alien capable of bio-artillery barrages. The globs it spits explode into clouds of potent gas on impact."

	upgrade = XENO_UPGRADE_AGELESS

	// *** Melee Attacks *** //
	melee_damage = 30

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = 0.3

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 250

	// *** Defense *** //
	armor = list("melee" = 35, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = XENO_BOMB_RESIST_0, "bio" = 35, "rad" = 35, "fire" = 35, "acid" = 35)

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS

	// *** Boiler Abilities *** //
	bomb_strength = 2.5
	acid_delay = 9 SECONDS //9 seconds delay on acid. Reduced by -1 per upgrade down to 5 seconds
	bomb_delay = 30 SECONDS //20 seconds per glob at Young, -2.5 per upgrade down to 10 seconds