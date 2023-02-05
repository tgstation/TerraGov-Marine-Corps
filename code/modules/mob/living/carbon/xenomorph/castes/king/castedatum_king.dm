/datum/xeno_caste/king
	caste_name = "King"
	display_name = "King"
	caste_type_path = /mob/living/carbon/xenomorph/king
	caste_desc = "A primordial creature, evolved to smash the hardiest of defences and hunt the hardiest of prey."

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "king" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 40

	// *** Health *** //
	max_health = 575

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_STAGGER_RESISTANT
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_CORRUPT_GENERATOR

	// *** Defense *** //
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 30, BIO = 45, FIRE = 100, ACID = 45)

	// *** Pheromones *** //
	aura_strength = 4

	minimap_icon = "xenoking"

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/activable/plant_weeds,
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/activable/nightfall,
		/datum/action/xeno_action/petrify,
		/datum/action/xeno_action/activable/off_guard,
		/datum/action/xeno_action/activable/shattering_roar,
		/datum/action/xeno_action/psychic_summon,
		/datum/action/xeno_action/pheromones,
		/datum/action/xeno_action/pheromones/emit_recovery,
		/datum/action/xeno_action/pheromones/emit_warding,
		/datum/action/xeno_action/pheromones/emit_frenzy,
		/datum/action/xeno_action/rally_hive,
		/datum/action/xeno_action/rally_minion,
		/datum/action/xeno_action/set_agressivity,
		/datum/action/xeno_action/blessing_menu,
	)


/datum/xeno_caste/king/young
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/king/mature
	caste_desc = "The biggest and baddest xeno, crackling with psychic energy."

	upgrade = XENO_UPGRADE_ONE

	melee_damage = 23

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 600

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 55, BULLET = 55, LASER = 55, ENERGY = 55, BOMB = 30, BIO = 50, FIRE = 100, ACID = 50)


/datum/xeno_caste/king/elder
	caste_desc = "An unstoppable being only whispered about in legends."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 26

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 1100
	plasma_gain = 60

	// *** Health *** //
	max_health = 625

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 30, BIO = 55, FIRE = 100, ACID = 55)

	// *** Pheromones *** //
	aura_strength = 5

/datum/xeno_caste/king/ancient
	caste_desc = "Harbinger of doom."
	ancient_message = "We are the end."
	upgrade = XENO_UPGRADE_THREE

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
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 65, BULLET = 65, LASER = 65, ENERGY = 65, BOMB = 100, BIO = 60, FIRE = 100, ACID = 60)

	// *** Pheromones *** //
	aura_strength = 6

/datum/xeno_caste/king/primordial
	caste_desc = "An avatar of death. Running won't help you now."
	primordial_message = "Death cannot create, but you definitely know how to destroy."
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 30

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 1200
	plasma_gain = 70

	// *** Health *** //
	max_health = 650

	// *** Defense *** //
	soft_armor = list(MELEE = 65, BULLET = 65, LASER = 65, ENERGY = 65, BOMB = 100, BIO = 60, FIRE = 100, ACID = 60)

	// *** Pheromones *** //
	aura_strength = 6

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/activable/plant_weeds,
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/activable/nightfall,
		/datum/action/xeno_action/petrify,
		/datum/action/xeno_action/activable/off_guard,
		/datum/action/xeno_action/activable/shattering_roar,
		/datum/action/xeno_action/zero_form_beam,
		/datum/action/xeno_action/psychic_summon,
		/datum/action/xeno_action/pheromones,
		/datum/action/xeno_action/pheromones/emit_recovery,
		/datum/action/xeno_action/pheromones/emit_warding,
		/datum/action/xeno_action/pheromones/emit_frenzy,
		/datum/action/xeno_action/rally_hive,
		/datum/action/xeno_action/rally_minion,
		/datum/action/xeno_action/set_agressivity,
		/datum/action/xeno_action/blessing_menu,
	)
