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
	melee_damage = 20

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 38

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	evolution_threshold = 225
	upgrade_threshold = TIER_TWO_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/drone

	evolves_to = list(/mob/living/carbon/xenomorph/defiler, /mob/living/carbon/xenomorph/widow)

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_hold_eggs = CAN_HOLD_ONE_HAND
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	caste_traits = null

	// *** Defense *** //
	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 0, BIO = 5, FIRE = 15, ACID = 5)

	// *** Pheromones *** //
	aura_strength = 2.5

	// *** Minimap Icon *** //
	minimap_icon = "carrier"

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
	)

/datum/xeno_caste/carrier/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/carrier/primodial
	upgrade_name = "Primordial"
	caste_desc = "It's literally crawling with 11 huggers."
	upgrade = XENO_UPGRADE_PRIMO
	primordial_message = "Not one tall will be left uninfected."

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
