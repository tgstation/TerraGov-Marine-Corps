/datum/xeno_caste/dragon
	caste_name = "Dragon"
	display_name = "Dragon"
	upgrade_name = ""
	base_strain_type = /mob/living/carbon/xenomorph/dragon
	caste_type_path = /mob/living/carbon/xenomorph/dragon
	caste_desc = "A large monster with prominent wings and a distinctive silhouette."

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "dragon"

	// *** Melee Attacks *** //
	melee_damage = 30

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 0
	plasma_regen_limit = 0
	plasma_icon_state = "armor"

	// *** Health *** //
	max_health = 900

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD
	maximum_active_caste = 1
	evolve_min_xenos = 13
	death_evolution_delay = 7 MINUTES

	// *** Flags *** //
	caste_flags = CASTE_FIRE_IMMUNE|CASTE_IS_INTELLIGENT|CASTE_INSTANT_EVOLUTION|CASTE_LEADER_TYPE
	can_flags = CASTE_CAN_BE_LEADER|CASTE_CAN_CORRUPT_GENERATOR
	caste_traits = list(TRAIT_STAGGERIMMUNE, TRAIT_SLOWDOWNIMMUNE, TRAIT_STUNIMMUNE)

	// *** Defense *** //
	soft_armor = list(MELEE = 75, BULLET = 75, LASER = 75, ENERGY = 75, BOMB = 60, BIO = 75, FIRE = 200, ACID = 75)

	// *** Sunder *** //
	sunder_recover = 1
	sunder_multiplier = 0.8

	minimap_icon = "xenodragon"

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain/free,
		/datum/action/ability/xeno_action/call_of_the_burrowed/free,
		/datum/action/ability/activable/xeno/backhand,
		/datum/action/ability/activable/xeno/backhand/dragon_breath,
		/datum/action/ability/activable/xeno/wind_current,
		/datum/action/ability/activable/xeno/grab,
		/datum/action/ability/activable/xeno/fly,
		/datum/action/ability/xeno_action/hive_message/free,
		/datum/action/ability/xeno_action/rally_hive,
		/datum/action/ability/xeno_action/rally_minion,
		/datum/action/ability/xeno_action/blessing_menu,
	)

/datum/xeno_caste/dragon/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/dragon/primordial
	upgrade_name = "Primordial"
	caste_desc = "Ancient terror. Your end has come, and it bears my wings."
	primordial_message = "Destruction is my creed; none shall withstand my fury."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain/free,
		/datum/action/ability/xeno_action/call_of_the_burrowed/free,
		/datum/action/ability/activable/xeno/backhand,
		/datum/action/ability/activable/xeno/backhand/dragon_breath,
		/datum/action/ability/activable/xeno/wind_current,
		/datum/action/ability/activable/xeno/grab,
		/datum/action/ability/activable/xeno/fly,
		/datum/action/ability/activable/xeno/scorched_land,
		/datum/action/ability/xeno_action/hive_message/free,
		/datum/action/ability/xeno_action/rally_hive,
		/datum/action/ability/xeno_action/rally_minion,
		/datum/action/ability/xeno_action/blessing_menu,
	)
