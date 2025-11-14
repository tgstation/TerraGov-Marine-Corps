/datum/xeno_caste/defender
	caste_name = "Defender"
	display_name = "Defender"
	upgrade_name = ""
	caste_desc = "An alien with an armored crest. It looks very tough."
	base_strain_type = /mob/living/carbon/xenomorph/defender
	caste_type_path = /mob/living/carbon/xenomorph/defender

	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "defender" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 22

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 20

	// *** Health *** //
	max_health = 420

	// *** Evolution *** //
	evolution_threshold = 100
	upgrade_threshold = TIER_ONE_THRESHOLD

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_MUTATIONS_ALLOWED
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	soft_armor = list(MELEE = 45, BULLET = 45, LASER = 45, ENERGY = 45, BOMB = 30, BIO = 30, FIRE = 40, ACID = 30)

	// *** Minimap Icon *** //
	minimap_icon = "defender"

	// *** Defender Abilities *** //
	crest_defense_armor = 30
	crest_defense_slowdown = 0.8
	fortify_armor = 50

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/toggle_crest_defense,
		/datum/action/ability/xeno_action/fortify,
		/datum/action/ability/activable/xeno/charge/forward_charge,
		/datum/action/ability/xeno_action/tail_sweep,
		/datum/action/ability/xeno_action/regenerate_skin,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/brittle_upclose,
		/datum/mutation_upgrade/shell/carapace_waxing,
		/datum/mutation_upgrade/shell/carapace_regrowth,
		/datum/mutation_upgrade/spur/breathtaking_spin,
		/datum/mutation_upgrade/spur/sharpening_claws,
		/datum/mutation_upgrade/spur/power_spin,
		/datum/mutation_upgrade/veil/carapace_sweat,
		/datum/mutation_upgrade/veil/carapace_sharing,
		/datum/mutation_upgrade/veil/slow_and_steady
	)

/datum/xeno_caste/defender/ancient
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/defender/primordial
	upgrade_name = "Primordial"
	caste_desc = "Alien with an incredibly tough and armored head crest able to endure even the strongest hits."
	upgrade = XENO_UPGRADE_PRIMO
	primordial_message = "We are the aegis of the hive. Let nothing pierce our guard."

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/toggle_crest_defense,
		/datum/action/ability/xeno_action/fortify,
		/datum/action/ability/activable/xeno/charge/forward_charge,
		/datum/action/ability/xeno_action/tail_sweep,
		/datum/action/ability/xeno_action/regenerate_skin,
		/datum/action/ability/xeno_action/centrifugal_force,
	)
