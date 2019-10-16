/datum/xeno_caste/hivelord/ageless
	caste_desc = "A builder of REALLY BIG hives, and a powerful supporter of the hive."

	upgrade = XENO_UPGRADE_AGELESS

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = 0.2

	// *** Plasma *** //
	plasma_max = 1200
	plasma_gain = 65

	// *** Health *** //
	max_health = 300

	// *** Defense *** //
	armor = list("melee" = 20, "bullet" = 10, "laser" = 10, "energy" = 20, "bomb" = XENO_BOMB_RESIST_0, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 20)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/sticky)

	// *** Pheromones *** //
	aura_strength = 3
