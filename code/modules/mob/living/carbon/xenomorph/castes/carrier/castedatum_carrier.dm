/datum/xeno_caste/carrier
	caste_name = "Carrier"
	display_name = "Carrier"
	upgrade_name = ""
	caste_desc = "A carrier of huggies."

	caste_type_path = /mob/living/carbon/xenomorph/carrier

	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "carrier" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 17

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 20

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	evolution_threshold = 180
	upgrade_threshold = TIER_TWO_YOUNG_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/drone

	evolves_to = list(/mob/living/carbon/xenomorph/defiler, /mob/living/carbon/xenomorph/widow)

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_hold_eggs = CAN_HOLD_ONE_HAND
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 0, BIO = 5, FIRE = 15, ACID = 5)

	// *** Pheromones *** //
	aura_strength = 1.5

	// *** Minimap Icon *** //
	minimap_icon = "carrier"

	// *** Carrier Abilities *** //
	huggers_max = 4
	hugger_delay = 2.5 SECONDS

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/activable/plant_weeds,
		/datum/action/xeno_action/activable/throw_hugger,
		/datum/action/xeno_action/activable/call_younger,
		/datum/action/xeno_action/lay_egg,
		/datum/action/xeno_action/place_trap,
		/datum/action/xeno_action/spawn_hugger,
		/datum/action/xeno_action/pheromones,
		/datum/action/xeno_action/pheromones/emit_recovery,
		/datum/action/xeno_action/pheromones/emit_warding,
		/datum/action/xeno_action/pheromones/emit_frenzy,
		/datum/action/xeno_action/carrier_panic,
		/datum/action/xeno_action/choose_hugger_type,
	)

/datum/xeno_caste/carrier/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/carrier/mature
	upgrade_name = "Mature"
	caste_desc = "A portable Love transport. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 25

	// *** Health *** //
	max_health = 275

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 5, FIRE = 20, ACID = 5)

	// *** Pheromones *** //
	aura_strength = 2

	// *** Carrier Abilities *** //
	huggers_max = 5
	hugger_delay = 2.5 SECONDS

/datum/xeno_caste/carrier/elder
	upgrade_name = "Elder"
	caste_desc = "A portable Love transport. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 700
	plasma_gain = 30

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 0, BIO = 7, FIRE = 25, ACID = 7)

	// *** Pheromones *** //
	aura_strength = 2.3

	// *** Carrier Abilities *** //
	huggers_max = 6
	hugger_delay = 2 SECONDS

/datum/xeno_caste/carrier/ancient
	upgrade_name = "Ancient"
	caste_desc = "It's literally crawling with 11 huggers."
	upgrade = XENO_UPGRADE_THREE
	ancient_message = "We are the master of huggers. We shall throw them like baseballs at the marines!"

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 38

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 10, FIRE = 30, ACID = 10)

	// *** Pheromones *** //
	aura_strength = 2.5

	// *** Carrier Abilities *** //
	huggers_max = 7
	hugger_delay = 1.5 SECONDS

/datum/xeno_caste/carrier/primodial
	upgrade_name = "Primordial"
	caste_desc = "It's literally crawling with 11 huggers."
	upgrade = XENO_UPGRADE_FOUR
	primordial_message = ""

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 38

	// *** Health *** //
	max_health = 325

	// *** Defense *** //
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 10, FIRE = 30, ACID = 10)

	// *** Pheromones *** //
	aura_strength = 2.5

	// *** Carrier Abilities *** //
	huggers_max = 7
	hugger_delay = 1.5 SECONDS

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/activable/plant_weeds,
		/datum/action/xeno_action/activable/throw_hugger,
		/datum/action/xeno_action/activable/call_younger,
		/datum/action/xeno_action/lay_egg,
		/datum/action/xeno_action/place_trap,
		/datum/action/xeno_action/spawn_hugger,
		/datum/action/xeno_action/pheromones,
		/datum/action/xeno_action/pheromones/emit_recovery,
		/datum/action/xeno_action/pheromones/emit_warding,
		/datum/action/xeno_action/pheromones/emit_frenzy,
		/datum/action/xeno_action/carrier_panic,
		/datum/action/xeno_action/choose_hugger_type,
		/datum/action/xeno_action/build_hugger_turret,
	)
