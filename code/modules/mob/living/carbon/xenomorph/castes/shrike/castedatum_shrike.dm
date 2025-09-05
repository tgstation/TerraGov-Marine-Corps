/datum/xeno_caste/shrike
	caste_name = "Shrike"
	display_name = "Shrike"
	upgrade_name = ""
	caste_desc = "A psychically unstable xeno. The Shrike controls the hive when there's no Queen and acts as its successor when there is."
	job_type = /datum/job/xenomorph/queen
	base_strain_type = /mob/living/carbon/xenomorph/shrike
	caste_type_path = /mob/living/carbon/xenomorph/shrike

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "shrike" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 25

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 925
	plasma_gain = 60

	// *** Health *** //
	max_health = 400

	// *** Evolution *** //
	// The only evolution path does not require threshold
	// evolution_threshold = 225
	maximum_active_caste = 1
	upgrade_threshold = TIER_TWO_THRESHOLD

	deevolves_to = /datum/xeno_caste/drone

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_IS_BUILDER|CASTE_INSTANT_EVOLUTION|CASTE_EVOLUTION_ALLOWED|CASTE_LEADER_TYPE|CASTE_MUTATIONS_ALLOWED
	can_hold_eggs = CAN_HOLD_TWO_HANDS
	can_flags = parent_type::can_flags|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_CORRUPT_GENERATOR|CASTE_CAN_BE_RULER
	caste_traits = list(TRAIT_CAN_TEAR_HOLE, TRAIT_CAN_DISABLE_MINER)

	// *** Defense *** //
	soft_armor = list(MELEE = 45, BULLET = 45, LASER = 45, ENERGY = 45, BOMB = 20, BIO = 25, FIRE = 45, ACID = 20)

	// *** Pheromones *** //
	aura_strength = 3 //The Shrike's aura is decent.

	// *** Queen Abilities *** //
	queen_leader_limit = 4

	// *** Minimap Icon *** //
	minimap_icon = "xenoshrike"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/xeno_action/lay_egg,
		/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn,
		/datum/action/ability/xeno_action/call_of_the_burrowed,
		/datum/action/ability/activable/xeno/secrete_resin,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/activable/xeno/psychic_cure,
		/datum/action/ability/activable/xeno/transfer_plasma/drone,
		/datum/action/ability/xeno_action/psychic_whisper,
		/datum/action/ability/activable/xeno/psychic_fling,
		/datum/action/ability/activable/xeno/unrelenting_force,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/xeno_action/hive_message,
		/datum/action/ability/xeno_action/rally_hive,
		/datum/action/ability/xeno_action/rally_minion,
		/datum/action/ability/xeno_action/blessing_menu,
		/datum/action/ability/activable/xeno/place_pattern,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/lone_healer,
		/datum/mutation_upgrade/shell/shared_cure,
		/datum/mutation_upgrade/shell/resistant_cure,
		/datum/mutation_upgrade/spur/smashing_fling,
		/datum/mutation_upgrade/spur/body_fling,
		/datum/mutation_upgrade/spur/gravity_tide,
		/datum/mutation_upgrade/veil/delayed_condition,
		/datum/mutation_upgrade/veil/deflective_force,
		/datum/mutation_upgrade/veil/psychic_choke
	)

/datum/xeno_caste/shrike/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/shrike/primordial
	upgrade_name = "Primordial"
	caste_desc = "The unleashed repository of the hive's psychic power."
	primordial_message = "We are the unbridled psychic power of the hive. Throw our enemies to their doom."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/xeno_action/lay_egg,
		/datum/action/ability/activable/xeno/neurotox_sting/ozelomelyn,
		/datum/action/ability/xeno_action/call_of_the_burrowed,
		/datum/action/ability/activable/xeno/secrete_resin,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/activable/xeno/psychic_cure,
		/datum/action/ability/activable/xeno/transfer_plasma/drone,
		/datum/action/ability/xeno_action/sow,
		/datum/action/ability/xeno_action/psychic_whisper,
		/datum/action/ability/activable/xeno/psychic_fling,
		/datum/action/ability/activable/xeno/unrelenting_force,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/xeno_action/hive_message,
		/datum/action/ability/xeno_action/rally_hive,
		/datum/action/ability/xeno_action/rally_minion,
		/datum/action/ability/xeno_action/blessing_menu,
		/datum/action/ability/activable/xeno/psychic_vortex,
		/datum/action/ability/activable/xeno/place_pattern,
	)
