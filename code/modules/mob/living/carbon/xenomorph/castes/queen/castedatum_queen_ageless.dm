/datum/xeno_caste/queen/ageless
	caste_desc = "The leader of the alien hive. The Queen controls the battlefield and plants eggs to bolster her numbers. She won't be easy to take down."

	upgrade = XENO_UPGRADE_AGELESS

	// *** Melee Attacks *** //
	melee_damage = 45

	// *** Tackle *** //
	tackle_damage = 55

	// *** Speed *** //
	speed = 0.3

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 40

	// *** Health *** //
	max_health = 400

	// *** Defense *** //
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = XENO_BOMB_RESIST_3, "bio" = 50, "rad" = 50, "fire" = 100, "acid" = 50)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS

	// *** Pheromones *** //
	aura_strength = 5

	// *** Queen Abilities *** //
	queen_leader_limit = 3
