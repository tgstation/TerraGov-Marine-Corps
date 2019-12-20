/datum/xeno_caste/hivemind
	caste_name = "hivemind"
	display_name = "hivemind"
	upgrade_name = ""
	caste_desc = "The mind of the hive"
	caste_type_path = /mob/living/carbon/xenomorph/hivemind
	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "hivemind" //used to match appropriate wound overlays
	// *** Melee Attacks *** //
	melee_damage = 0

	// *** Tackle *** //
	tackle_damage = 0

	// *** Speed *** //
	speed = -2

	// *** Plasma *** //
	plasma_max = 150 //  75 is the cost of plant_weeds
	plasma_gain = 15 // This is 1 weed every 10 secs.

	// *** Health *** //
	max_health = 1000

	// *** Evolution *** //
	evolution_threshold = 180
	upgrade_threshold = 100

	deevolves_to = null

	evolves_to = list()

	// *** Flags *** //
	caste_flags = CASTE_INNATE_PLASMA_REGEN

	can_hold_eggs = CANNOT_HOLD_EGGS

	// *** Defense *** //
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = XENO_BOMB_RESIST_0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	// *** Ranged Attack *** //
	spit_delay = 0 SECONDS
	spit_types = list()

	// *** Pheromones *** //
	aura_strength = 2.5 //hivemind's aura is not extremely strong, but better than Drones.
	aura_allowed = list("frenzy", "warding", "recovery")

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/plant_weeds,
		)

/datum/xeno_caste/hivemind/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/hivemind/mature
	upgrade_name = "Mature"
	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -2.5

	// *** Plasma *** //
	plasma_max = 300 //  75 is the cost of plant_weed
	plasma_gain = 45 // This is 3 weed every 10 secs.

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/activable/psychic_cure,
		)


/datum/xeno_caste/hivemind/elder
	upgrade_name = "Elder"
	upgrade = XENO_UPGRADE_TWO

	// *** Speed *** //
	speed = -3

	// *** Plasma *** //
	plasma_max = 600 
	plasma_gain = 60 // This is 4 weed every 10 secs.

	// *** Health *** //
	max_health = 1000

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/activable/psychic_cure,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin/slow,
		)

/datum/xeno_caste/hivemind/ancient
	upgrade_name = "Ancient"
	ancient_message = "We are a collective. Strongest there can be. Nothing can stop us, we are one"
	upgrade = XENO_UPGRADE_THREE

	// *** Speed *** //
	speed = -3.5

	// *** Plasma *** //
	plasma_max = 1000 
	plasma_gain = 75 // This is 5 weed every 10 secs.

	// *** Health *** //
	max_health = 1000

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/activable/psychic_cure,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin/slow,
		/datum/action/xeno_action/toggle_pheromones,
		)
