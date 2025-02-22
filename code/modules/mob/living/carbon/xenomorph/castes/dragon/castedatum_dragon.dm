/datum/xeno_caste/dragon
	caste_name = "Dragon"
	display_name = "Dragon"
	upgrade_name = ""
	base_strain_type = /mob/living/carbon/xenomorph/dragon
	caste_type_path = /mob/living/carbon/xenomorph/dragon
	caste_desc = "A big scary monster with wings!"

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "" // TODO: No wound sprites for this yet. Get some.

	// *** Melee Attacks *** //
	melee_damage = 30

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 0
	plasma_regen_limit = 0
	plasma_icon_state = "armor"

	// *** Health *** //
	max_health = 850

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD
	maximum_active_caste = 1
	evolve_min_xenos = 13
	death_evolution_delay = 7 MINUTES

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_STAGGER_IMMUNE|CASTE_KNOCKBACK_IMMUNE|CASTE_SLOW_IMMUNE|CASTE_STUN_IMMUNE|CASTE_EXCLUDED_FROM_PSYCHIC_SUMMON|CASTE_INSTANT_EVOLUTION|CASTE_LEADER_TYPE
	can_flags = CASTE_CAN_BE_LEADER|CASTE_CAN_CORRUPT_GENERATOR
	caste_traits = null

	// *** Defense *** //
	soft_armor = list(MELEE = 75, BULLET = 75, LASER = 75, ENERGY = 75, BOMB = 60, BIO = 75, FIRE = 90, ACID = 75)

	minimap_icon = "xenoking" // TODO: Replace this with a better minimap icon.

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/xeno_action/call_of_the_burrowed,
		/datum/action/ability/activable/xeno/backhand,
		/datum/action/ability/activable/xeno/fly,
		/datum/action/ability/activable/xeno/tailswipe,
		/datum/action/ability/activable/xeno/dragon_breath,
		/datum/action/ability/activable/xeno/wind_current,
		/datum/action/ability/activable/xeno/grab,
		/datum/action/ability/xeno_action/hive_message,
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
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/xeno_action/call_of_the_burrowed,
		/datum/action/ability/activable/xeno/backhand,
		/datum/action/ability/activable/xeno/fly,
		/datum/action/ability/activable/xeno/tailswipe,
		/datum/action/ability/activable/xeno/dragon_breath,
		/datum/action/ability/activable/xeno/wind_current,
		/datum/action/ability/activable/xeno/grab,
		/datum/action/ability/activable/xeno/miasma,
		/datum/action/ability/activable/xeno/lightning_strike,
		/datum/action/ability/activable/xeno/fire_storm,
		/datum/action/ability/activable/xeno/ice_spike,
		/datum/action/ability/xeno_action/hive_message,
		/datum/action/ability/xeno_action/rally_hive,
		/datum/action/ability/xeno_action/rally_minion,
		/datum/action/ability/xeno_action/blessing_menu,
	)
