/datum/xeno_caste/hivelord
	caste_name = "Hivelord"
	display_name = "Hivelord"
	upgrade_name = ""
	caste_desc = "A builder of REALLY BIG hives."
	base_strain_type = /mob/living/carbon/xenomorph/hivelord
	caste_type_path = /mob/living/carbon/xenomorph/hivelord
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "hivelord" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 2400
	plasma_gain = 80
	plasma_regen_limit = 0.5
	plasma_icon_state = "hivelord_plasma"

	// *** Health *** //
	max_health = 410


	// *** Evolution *** //
	evolution_threshold = 225
	upgrade_threshold = TIER_TWO_THRESHOLD

	deevolves_to = /datum/xeno_caste/drone

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_IS_BUILDER|CASTE_MUTATIONS_ALLOWED
	can_hold_eggs = CAN_HOLD_TWO_HANDS
	can_flags = parent_type::can_flags|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_BE_GIVEN_PLASMA
	caste_traits = list(TRAIT_CAN_TEAR_HOLE, TRAIT_CAN_DISABLE_MINER)

	// *** Defense *** //
	soft_armor = list(MELEE = 35, BULLET = 35, LASER = 35, ENERGY = 35, BOMB = 0, BIO = 20, FIRE = 30, ACID = 20)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/sticky)

	// *** Pheromones *** //
	aura_strength = 3 //Hivelord's aura is not extremely strong, but better than Drones.

	// *** Minimap Icon *** //
	minimap_icon = "hivelord"

	// *** Abilities *** //

	resin_max_range = 1 //Hivelord can place resin structures from 1 tile away

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/activable/xeno/healing_infusion,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/activable/xeno/secrete_resin/hivelord,
		/datum/action/ability/xeno_action/blessing_menu,
		/datum/action/ability/activable/xeno/transfer_plasma/improved,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/xeno_action/build_tunnel,
		/datum/action/ability/xeno_action/toggle_speed,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/activable/xeno/xeno_spit,
		/datum/action/ability/xeno_action/create_jelly,
		/datum/action/ability/xeno_action/place_jelly_pod,
		/datum/action/ability/xeno_action/place_recovery_pylon,
		/datum/action/ability/activable/xeno/recycle,
		/datum/action/ability/activable/xeno/place_pattern,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/hardened_travel,
		/datum/mutation_upgrade/shell/costly_travel,
		/datum/mutation_upgrade/shell/rejuvenating_build,
		/datum/mutation_upgrade/spur/combustive_jelly,
		/datum/mutation_upgrade/spur/resin_splash,
		/datum/mutation_upgrade/spur/hostile_pylon,
		/datum/mutation_upgrade/veil/protective_light,
		/datum/mutation_upgrade/veil/forward_light,
		/datum/mutation_upgrade/veil/weed_specialist
	)

/datum/xeno_caste/hivelord/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/hivelord/primordial
	upgrade_name = "Primordial"
	caste_desc = "Ultimate builder of the hive. It seems twitchy and is constantly building something"
	primordial_message = "We are the master architect of the hive. Let the world be covered in resin."
	upgrade = XENO_UPGRADE_PRIMO

	spit_types = list(/datum/ammo/xeno/sticky, /datum/ammo/xeno/sticky/globe)

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/activable/xeno/healing_infusion,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/activable/xeno/secrete_resin/hivelord,
		/datum/action/ability/xeno_action/blessing_menu,
		/datum/action/ability/activable/xeno/transfer_plasma/improved,
		/datum/action/ability/activable/xeno/corrosive_acid/strong,
		/datum/action/ability/xeno_action/sow,
		/datum/action/ability/xeno_action/build_tunnel,
		/datum/action/ability/xeno_action/toggle_speed,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/activable/xeno/xeno_spit,
		/datum/action/ability/xeno_action/create_jelly,
		/datum/action/ability/xeno_action/place_jelly_pod,
		/datum/action/ability/xeno_action/place_recovery_pylon,
		/datum/action/ability/activable/xeno/recycle,
		/datum/action/ability/activable/xeno/place_pattern,
	)
