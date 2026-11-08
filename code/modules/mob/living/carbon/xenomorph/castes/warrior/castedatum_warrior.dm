/datum/xeno_caste/warrior
	caste_name = "Warrior"
	display_name = "Warrior"
	upgrade_name = ""
	caste_desc = "A powerful front line combatant."
	base_strain_type = /mob/living/carbon/xenomorph/warrior
	caste_type_path = /mob/living/carbon/xenomorph/warrior
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "warrior" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 25

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 15

	// *** Health *** //
	max_health = 400

	// *** Sunder *** //
	sunder_multiplier = 0.9

	// *** Evolution *** //
	evolution_threshold = 225
	upgrade_threshold = TIER_TWO_THRESHOLD

	deevolves_to = /datum/xeno_caste/defender

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_MUTATIONS_ALLOWED
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA
	caste_traits = list(TRAIT_CAN_TEAR_HOLE, TRAIT_CAN_DISABLE_MINER)

	// *** Defense *** //
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 30, BIO = 50, FIRE = 55, ACID = 50)

	// *** Minimap Icon *** //
	minimap_icon = "warrior"

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/toggle_agility,
		/datum/action/ability/activable/xeno/warrior/lunge,
		/datum/action/ability/activable/xeno/warrior/fling,
		/datum/action/ability/activable/xeno/warrior/grapple_toss,
		/datum/action/ability/activable/xeno/warrior/punch,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/zoomies,
		/datum/mutation_upgrade/spur/enhanced_strength,
		/datum/mutation_upgrade/veil/friendly_toss
	)

/datum/xeno_caste/warrior/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/warrior/primordial
	upgrade_name = "Primordial"
	caste_desc = "A champion of the hive, methodically shatters its opponents with punches rather than slashes."
	primordial_message = "Our rhythm is unmatched and our strikes lethal, no single foe can stand against us."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/empower,
		/datum/action/ability/xeno_action/toggle_agility,
		/datum/action/ability/activable/xeno/warrior/lunge,
		/datum/action/ability/activable/xeno/warrior/fling,
		/datum/action/ability/activable/xeno/warrior/grapple_toss,
		/datum/action/ability/activable/xeno/warrior/punch,
		/datum/action/ability/activable/xeno/warrior/punch/flurry,
	)
