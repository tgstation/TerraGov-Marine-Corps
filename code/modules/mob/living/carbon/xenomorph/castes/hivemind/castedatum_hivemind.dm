/datum/xeno_caste/hivemind
	caste_name = "Hivemind"
	display_name = "Hivemind"
	upgrade_name = ""
	caste_desc = "The mind of the hive"
	caste_type_path = /mob/living/carbon/xenomorph/hivemind
	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "hivemind" //used to match appropriate wound overlays
	// *** Melee Attacks *** //
	melee_damage = 0

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 150 //  75 is the cost of plant_weeds
	plasma_gain = 15 // This is 1 weed every 10 secs.

	// *** Health *** //
	max_health = 1000

	// *** Flags *** //
	caste_flags = CASTE_INNATE_PLASMA_REGEN|CASTE_FIRE_IMMUNE|CASTE_IS_BUILDER

	can_hold_eggs = CANNOT_HOLD_EGGS

	// *** Defense *** //
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = XENO_BOMB_RESIST_0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	// *** Ranged Attack *** //
	spit_delay = 0 SECONDS
	spit_types = list()

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/return_to_core,
		/datum/action/xeno_action/change_form,
		/datum/action/xeno_action/activable/rally_hive/hivemind,
	)

/datum/xeno_caste/hivemind_manifestation
	caste_name = "Hivemind"
	display_name = "Hivemind"
	upgrade_name = ""
	caste_desc = "The manifestation of the hivemind"
	caste_type_path = /mob/living/carbon/xenomorph/hivemind
	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_ZERO
	// *** Melee Attacks *** //
	melee_damage = 0

	// *** Speed *** //
	speed = 0.5

	// *** Plasma *** //
	plasma_max = 150 //  75 is the cost of plant_weeds
	plasma_gain = 15 // This is 1 weed every 10 secs.

	// *** Health *** //
	max_health = 100

	deevolves_to = null

	evolves_to = list()

	// *** Flags *** //
	caste_flags = CASTE_INNATE_PLASMA_REGEN|CASTE_IS_BUILDER

	can_hold_eggs = CANNOT_HOLD_EGGS

	// *** Defense *** //
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = XENO_BOMB_RESIST_0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	// *** Ranged Attack *** //
	spit_delay = 0 SECONDS
	spit_types = list()

		// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/change_form,
		/datum/action/xeno_action/activable/rally_hive/hivemind,
	)
