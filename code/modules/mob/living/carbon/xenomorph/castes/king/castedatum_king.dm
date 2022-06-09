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
	speed = 0

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 40

	// *** Health *** //
	max_health = 450

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	// *** Flags *** //
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 30, "bio" = 45, "rad" = 45, "fire" = 100, "acid" = 45)

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
		/datum/action/xeno_action/activable/gravity_crush,
		/datum/action/xeno_action/psychic_summon,
		/datum/action/xeno_action/pheromones,
		/datum/action/xeno_action/pheromones/emit_recovery,
		/datum/action/xeno_action/pheromones/emit_warding,
		/datum/action/xeno_action/pheromones/emit_frenzy,
		/datum/action/xeno_action/rally_hive,
		/datum/action/xeno_action/rally_minion,
		/datum/action/xeno_action/set_agressivity,
	)


/datum/xeno_caste/king/young
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/king/mature
	caste_desc = "The biggest and baddest xeno, crackling with psychic energy."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 500

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 55, "bullet" = 55, "laser" = 55, "energy" = 55, "bomb" = 30, "bio" = 50, "rad" = 50, "fire" = 100, "acid" = 50)


/datum/xeno_caste/king/elder
	caste_desc = "An unstoppable being only whispered about in legends."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 25

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 1100
	plasma_gain = 60

	// *** Health *** //
	max_health = 600

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 60, "bomb" = 30, "bio" = 55, "rad" = 55, "fire" = 100, "acid" = 55)

	// *** Pheromones *** //
	aura_strength = 5

/datum/xeno_caste/king/ancient
	caste_desc = "Harbinger of doom."
	ancient_message = "We are the end."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 30

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 1200
	plasma_gain = 70

	// *** Health *** //
	max_health = 700

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 65, "bullet" = 65, "laser" = 65, "energy" = 65, "bomb" = 100, "bio" = 60, "rad" = 60, "fire" = 100, "acid" = 60)

	// *** Ranged Attack *** //
	spit_delay = 1.1 SECONDS

	// *** Pheromones *** //
	aura_strength = 6
