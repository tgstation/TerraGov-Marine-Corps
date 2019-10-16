/datum/xeno_caste/sentinel/ageless
	caste_desc = "A ranged non-lethal alien with neurotoxic spit."

	upgrade = XENO_UPGRADE_AGELESS

	// *** Melee Attacks *** //
	melee_damage = 25

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 15

	// *** Health *** //
	max_health = 175

	// *** Defense *** //
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = XENO_BOMB_RESIST_0, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 20)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/upgrade1)
