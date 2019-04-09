/datum/xeno_caste/larva
	caste_name = "Bloody Larva"
	display_name = "Bloody Larva"
	upgrade_name = ""
	caste_desc = "D'awwwww, so cute!"
	caste_type_path = /mob/living/carbon/Xenomorph/Larva
	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "alien" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage_lower = 0
	melee_damage_upper = 0

	// *** Speed *** //
	speed = -1.6

	// *** Plasma *** //
	plasma_gain = 1

	// *** Health *** //
	max_health = 35
	crit_health = -25

	// *** Evolution *** //
	evolves_to = list(/mob/living/carbon/Xenomorph/Drone, /mob/living/carbon/Xenomorph/Runner, /mob/living/carbon/Xenomorph/Sentinel, /mob/living/carbon/Xenomorph/Defender)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_INNATE_HEALING|CASTE_DECAY_PROOF

/datum/xeno_caste/larva/young
	upgrade = XENO_UPGRADE_INVALID
	