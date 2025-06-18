/datum/xeno_caste/king
	caste_name = "King"
	display_name = "King"
	upgrade_name = ""
	base_strain_type = /mob/living/carbon/xenomorph/king
	caste_type_path = /mob/living/carbon/xenomorph/king
	caste_desc = "A primordial creature, evolved to smash the hardiest of defences and hunt the hardiest of prey."

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "king" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 33

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 1200
	plasma_gain = 90

	// *** Health *** //
	max_health = 700

	// *** Sunder *** //
	sunder_multiplier = 0.8

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD
	maximum_active_caste = 1
	evolve_min_xenos = 12
	death_evolution_delay = 7 MINUTES

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_STAGGER_RESISTANT|CASTE_LEADER_TYPE|CASTE_INSTANT_EVOLUTION|CASTE_HAS_WOUND_MASK
	caste_traits = list(TRAIT_STOPS_TANK_COLLISION, TRAIT_CAN_TEAR_HOLE, TRAIT_CAN_DISABLE_MINER)
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_CORRUPT_GENERATOR|CASTE_CAN_BE_RULER

	// *** Defense *** //
	soft_armor = list(MELEE = 65, BULLET = 65, LASER = 65, ENERGY = 65, BOMB = 100, BIO = 60, FIRE = 100, ACID = 60)

	// *** Pheromones *** //
	aura_strength = 4.5

	// *** Queen Abilities *** //
	queen_leader_limit = 4

	minimap_icon = "xenoking"

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/xeno_action/call_of_the_burrowed,
		/datum/action/ability/activable/xeno/corrosive_acid/strong,
		/datum/action/ability/activable/xeno/nightfall,
		/datum/action/ability/xeno_action/petrify,
		/datum/action/ability/activable/xeno/off_guard,
		/datum/action/ability/activable/xeno/shattering_roar,
		/datum/action/ability/xeno_action/psychic_summon,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/xeno_action/hive_message,
		/datum/action/ability/xeno_action/rally_hive,
		/datum/action/ability/xeno_action/rally_minion,
		/datum/action/ability/xeno_action/blessing_menu,
	)


/datum/xeno_caste/king/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/king/primordial
	upgrade_name = "Primordial"
	caste_desc = "An avatar of death. Running won't help you now."
	primordial_message = "Death cannot create, but you definitely know how to destroy."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/xeno_action/call_of_the_burrowed,
		/datum/action/ability/activable/xeno/corrosive_acid/strong,
		/datum/action/ability/activable/xeno/nightfall,
		/datum/action/ability/xeno_action/petrify,
		/datum/action/ability/activable/xeno/off_guard,
		/datum/action/ability/activable/xeno/shattering_roar,
		/datum/action/ability/xeno_action/zero_form_beam,
		/datum/action/ability/xeno_action/psychic_summon,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/xeno_action/hive_message,
		/datum/action/ability/xeno_action/rally_hive,
		/datum/action/ability/xeno_action/rally_minion,
		/datum/action/ability/xeno_action/blessing_menu,
	)


// ***************************************
// *********** Conqueror
// ***************************************
/datum/xeno_caste/king/conqueror
	caste_name = "Conqueror"
	display_name = "Conqueror"
	caste_type_path = /mob/living/carbon/xenomorph/king/conqueror
	wound_type = "conqueror"
	caste_desc = "A primordial beast, sculpted by countless fights, intent on conquering the battlefield."

	// *** Melee Attacks *** //
	melee_damage = 25
	melee_ap = 15
	attack_delay = 7

	// *** Speed *** //
	speed = -0.7
	weeds_speed_mod = -0.1

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 60

	// *** Health *** //
	max_health = 800

	// *** Sunder *** //
	sunder_multiplier = 1.0

	// *** Evolution *** //
	evolve_min_xenos = 0

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_LEADER_TYPE|CASTE_INSTANT_EVOLUTION
	caste_traits = list(TRAIT_STAGGERIMMUNE, TRAIT_STOPS_TANK_COLLISION, TRAIT_CAN_TEAR_HOLE, TRAIT_CAN_DISABLE_MINER)

	// *** Defense *** //
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 60, BIO = 60, FIRE = 60, ACID = 60)

	// *** Pheromones *** //
	aura_strength = 3.0

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/activable/xeno/corrosive_acid/strong,
		/datum/action/ability/xeno_action/hive_message,
		/datum/action/ability/xeno_action/rally_hive,
		/datum/action/ability/xeno_action/rally_minion,
		/datum/action/ability/xeno_action/blessing_menu,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/xeno_action/conqueror_dash,
		/datum/action/ability/activable/xeno/conqueror_will,
		/datum/action/ability/xeno_action/conqueror_endurance,
		/datum/action/ability/activable/xeno/conqueror_domination,
	)

/datum/xeno_caste/king/conqueror/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/king/conqueror/primordial
	upgrade_name = "Primordial"
	primordial_message = "We will conquer all that dares stand in our path."
	upgrade = XENO_UPGRADE_PRIMO

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/activable/xeno/corrosive_acid/strong,
		/datum/action/ability/xeno_action/hive_message,
		/datum/action/ability/xeno_action/rally_hive,
		/datum/action/ability/xeno_action/rally_minion,
		/datum/action/ability/xeno_action/blessing_menu,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/xeno_action/conqueror_dash,
		/datum/action/ability/activable/xeno/conqueror_will,
		/datum/action/ability/xeno_action/conqueror_endurance,
		/datum/action/ability/activable/xeno/conqueror_domination,
		/datum/action/ability/xeno_action/conqueror_obliteration,
	)
