/datum/xeno_caste/ravager/ageless
	caste_desc = "An incredibly strong front line fighter capable of landing devastating hits with her scythe like claws."

	upgrade = XENO_UPGRADE_AGELESS

	// *** Melee Attacks *** //
	melee_damage = 65

	// *** Tackle *** //
	tackle_damage = 65

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 175
	plasma_gain = 13

	// *** Health *** //
	max_health = 300

	// *** Defense *** //
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_1, "bio" = 15, "rad" = 15, "fire" = 50, "acid" = 15)

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.
