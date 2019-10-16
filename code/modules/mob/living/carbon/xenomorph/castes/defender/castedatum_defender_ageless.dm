/datum/xeno_caste/defender/ageless
	caste_desc = "An alien with a heavily armored crest. It is capable of even absorbing bullet impacts when fully fortified."

	upgrade = XENO_UPGRADE_AGELESS

	// *** Melee Attacks *** //
	melee_damage = 25

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 175
	plasma_gain = 13

	// *** Health *** //
	max_health = 275

	// *** Defense *** //
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_0, "bio" = 30, "rad" = 30, "fire" = 30, "acid" = 30)

	// *** Defender Abilities *** //
	crest_defense_armor = 35
	fortify_armor = 70