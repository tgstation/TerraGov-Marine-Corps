/datum/xeno_caste/praetorian/ageless
	caste_desc = "A powerful ranged alien that serves to protect her sisters and assist the queen in leading the hive."

	upgrade = XENO_UPGRADE_AGELESS

	// *** Melee Attacks *** //
	melee_damage = 35

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 30

	// *** Health *** //
	max_health = 250

	// *** Defense *** //
	armor = list("melee" = 35, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = XENO_BOMB_RESIST_0, "bio" = 35, "rad" = 35, "fire" = 35, "acid" = 35)

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/heavy/upgrade1, /datum/ammo/xeno/acid/heavy)

	// *** Pheromones *** //
	aura_strength = 4