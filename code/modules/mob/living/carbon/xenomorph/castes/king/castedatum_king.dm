/datum/xeno_caste/king
	caste_name = "King"
	display_name = "King"
	upgrade_name = ""
	caste_type_path = /mob/living/carbon/xenomorph/king
	caste_desc = "A primordial creature, evolved to smash the hardiest of defences and hunt the hardiest of prey."

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "king" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 30

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 1200
	plasma_gain = 70

	// *** Health *** //
	max_health = 650

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD
	maximum_active_caste = 1
	evolve_min_xenos = 12
	death_evolution_delay = 7 MINUTES

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_STAGGER_RESISTANT|CASTE_LEADER_TYPE|CASTE_INSTANT_EVOLUTION
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_CORRUPT_GENERATOR
	caste_traits = null

	// *** Defense *** //
	soft_armor = list(MELEE = 65, BULLET = 65, LASER = 65, ENERGY = 65, BOMB = 100, BIO = 60, FIRE = 100, ACID = 60)

	// *** Pheromones *** //
	aura_strength = 6

	minimap_icon = "xenoking"

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/psychic_whisper,
		/datum/action/ability/xeno_action/psychic_influence,
		/datum/action/ability/xeno_action/activable/impregnate,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/xeno_action/activable/psydrain,
		/datum/action/ability/xeno_action/activable/devour,
		/datum/action/ability/xeno_action/activable/cocoon,
		/datum/action/ability/xeno_action/activable/plant_weeds,
		/datum/action/ability/xeno_action/call_of_the_burrowed,
		/datum/action/ability/xeno_action/activable/corrosive_acid/strong,
		/datum/action/ability/xeno_action/activable/nightfall,
		/datum/action/ability/xeno_action/petrify,
		/datum/action/ability/xeno_action/activable/off_guard,
		/datum/action/ability/xeno_action/activable/shattering_roar,
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
		/datum/action/ability/xeno_action/psychic_whisper,
		/datum/action/ability/xeno_action/psychic_influence,
		/datum/action/ability/xeno_action/activable/impregnate,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/xeno_action/activable/psydrain,
		/datum/action/ability/xeno_action/activable/devour,
		/datum/action/ability/xeno_action/activable/cocoon,
		/datum/action/ability/xeno_action/activable/plant_weeds,
		/datum/action/ability/xeno_action/call_of_the_burrowed,
		/datum/action/ability/xeno_action/activable/corrosive_acid/strong,
		/datum/action/ability/xeno_action/activable/nightfall,
		/datum/action/ability/xeno_action/petrify,
		/datum/action/ability/xeno_action/activable/off_guard,
		/datum/action/ability/xeno_action/activable/shattering_roar,
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
