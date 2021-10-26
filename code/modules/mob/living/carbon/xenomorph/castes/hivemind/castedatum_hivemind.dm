/datum/xeno_caste/hivemind
	caste_name = "Hivemind"
	display_name = "Hivemind"
	upgrade_name = ""
	caste_desc = "The mind of the hive"
	caste_type_path = /mob/living/carbon/xenomorph/hivemind
	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = ""
	// *** Melee Attacks *** //
	melee_damage = 0

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 600 //  75 is the cost of plant_weeds
	plasma_gain = 60

	// *** Health *** //
	max_health = 100

	// *** Flags *** //
	caste_flags = CASTE_INNATE_PLASMA_REGEN|CASTE_FIRE_IMMUNE|CASTE_IS_BUILDER

	can_hold_eggs = CANNOT_HOLD_EGGS

	// *** Defense *** //
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = XENO_BOMB_RESIST_1, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	// *** Ranged Attack *** //
	spit_delay = 0 SECONDS
	spit_types = list()

	aura_strength = 0

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/change_form,
		/datum/action/xeno_action/return_to_core,
		/datum/action/xeno_action/activable/rally_hive/hivemind,
		/datum/action/xeno_action/activable/command_minions,
	)

/datum/xeno_caste/hivemind/on_caste_applied(mob/xenomorph)
	return

/datum/xeno_caste/hivemind/on_caste_removed(mob/xenomorph)
	return

/datum/xeno_caste/hivemind/hivemind_manifestation
	caste_desc = "The manifestation of the hivemind"
	wound_type = "hivemind"

	upgrade = XENO_UPGRADE_MANIFESTATION

	// *** Flags *** //
	caste_flags = CASTE_IS_BUILDER|CASTE_FIRE_IMMUNE

	aura_strength = 4 //Good pheros

	speed = 1.5

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/change_form,
		/datum/action/xeno_action/activable/plant_weeds/ranged,
		/datum/action/xeno_action/activable/psychic_cure,
		/datum/action/xeno_action/toggle_pheromones,
		/datum/action/xeno_action/activable/secrete_resin/ranged/slow,
		/datum/action/xeno_action/activable/rally_hive/hivemind,
	)
