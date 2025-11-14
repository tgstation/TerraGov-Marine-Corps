/datum/xeno_caste/carrier
	caste_name = "Carrier"
	display_name = "Carrier"
	upgrade_name = ""
	caste_desc = "A carrier of huggies."
	base_strain_type = /mob/living/carbon/xenomorph/carrier
	caste_type_path = /mob/living/carbon/xenomorph/carrier

	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "carrier" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 22

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 425

	// *** Evolution *** //
	evolution_threshold = 225
	upgrade_threshold = TIER_TWO_THRESHOLD

	deevolves_to = /datum/xeno_caste/drone

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_MUTATIONS_ALLOWED
	can_hold_eggs = CAN_HOLD_ONE_HAND
	can_flags = parent_type::can_flags|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 5, FIRE = 25, ACID = 5)

	// *** Pheromones *** //
	aura_strength = 2.5

	// *** Minimap Icon *** //
	minimap_icon = "carrier"

	// *** Carrier Abilities *** //
	huggers_max = 8
	hugger_delay = 1.25 SECONDS

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/activable/xeno/throw_hugger,
		/datum/action/ability/activable/xeno/call_younger,
		/datum/action/ability/xeno_action/lay_egg,
		/datum/action/ability/xeno_action/place_trap,
		/datum/action/ability/xeno_action/spawn_hugger,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/xeno_action/carrier_panic,
		/datum/action/ability/xeno_action/choose_hugger_type,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/shared_jelly,
		/datum/mutation_upgrade/shell/hugger_overflow,
		/datum/mutation_upgrade/shell/recurring_panic,
		/datum/mutation_upgrade/spur/leapfrog,
		/datum/mutation_upgrade/spur/claw_delivered,
		/datum/mutation_upgrade/spur/fake_huggers,
		/datum/mutation_upgrade/veil/oviposition,
		/datum/mutation_upgrade/veil/life_for_life,
		/datum/mutation_upgrade/veil/swarm_trap
	)

/datum/xeno_caste/carrier/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/carrier/primodial
	upgrade_name = "Primordial"
	caste_desc = "It's literally crawling with 11 huggers."
	upgrade = XENO_UPGRADE_PRIMO
	primordial_message = "Not one tall will be left uninfected."

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/activable/xeno/throw_hugger,
		/datum/action/ability/activable/xeno/call_younger,
		/datum/action/ability/xeno_action/lay_egg,
		/datum/action/ability/xeno_action/place_trap,
		/datum/action/ability/xeno_action/spawn_hugger,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/xeno_action/carrier_panic,
		/datum/action/ability/xeno_action/choose_hugger_type,
		/datum/action/ability/xeno_action/build_hugger_turret,
	)
