/datum/xeno_caste/nymph
	caste_name = "Nymph"
	display_name = "Nymph"
	upgrade_name = ""
	caste_desc = ""
	wound_type = ""

	caste_type_path = /mob/living/carbon/xenomorph/nymph

	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 16

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 750
	plasma_gain = 25

	// *** Health *** //
	max_health = 200

	// *** Flags *** //
	caste_flags = CASTE_DO_NOT_ALERT_LOW_LIFE|CASTE_IS_A_MINION
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 10, FIRE = 0, ACID = 10)

	minimap_icon = "xenominion"

	aura_strength = 1

	// *** Abilities *** //

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/activable/xeno/transfer_plasma/drone,
		/datum/action/ability/activable/xeno/psychic_cure/acidic_salve/nymph,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
	)
