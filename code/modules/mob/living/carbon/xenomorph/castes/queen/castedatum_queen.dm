/datum/xeno_caste/queen
	caste_name = "Queen"
	display_name = "Queen"
	upgrade_name = ""
	caste_type_path = /mob/living/carbon/xenomorph/queen
	caste_desc = "The biggest and baddest xeno. The Queen controls the hive."
	job_type = /datum/job/xenomorph/queen

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "queen" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 1200
	plasma_gain = 70

	// *** Health *** //
	max_health = 500

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD
	evolve_min_xenos = 8
	maximum_active_caste = 1
	death_evolution_delay = 5 MINUTES

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_IS_BUILDER|CASTE_STAGGER_RESISTANT|CASTE_LEADER_TYPE|CASTE_INSTANT_EVOLUTION
	can_hold_eggs = CAN_HOLD_TWO_HANDS
	can_flags = CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_HOLD_JELLY|CASTE_CAN_CORRUPT_GENERATOR|CASTE_CAN_BE_GIVEN_PLASMA
	caste_traits = null

	// *** Defense *** //
	soft_armor = list(MELEE = 65, BULLET = 65, LASER = 65, ENERGY = 65, BOMB = 30, BIO = 60, FIRE = 60, ACID = 60)

	// *** Ranged Attack *** //
	spit_delay = 1.1 SECONDS
	spit_types = list(/datum/ammo/xeno/sticky, /datum/ammo/xeno/acid/medium)

	// *** Pheromones *** //
	aura_strength = 5 //The Queen's aura is strong and stays so, and gets devastating late game. Climbs by 1 to 5

	// *** Queen Abilities *** //
	queen_leader_limit = 4 //Amount of leaders allowed

	minimap_icon = "xenoqueen"

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/activable/plant_weeds,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/blessing_menu,
		/datum/action/xeno_action/place_acidwell,
		/datum/action/xeno_action/call_of_the_burrowed,
		/datum/action/xeno_action/activable/screech,
		/datum/action/xeno_action/bulwark,
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/psychic_cure/queen_give_heal,
		/datum/action/xeno_action/activable/neurotox_sting/ozelomelyn,
		/datum/action/xeno_action/pheromones,
		/datum/action/xeno_action/pheromones/emit_recovery,
		/datum/action/xeno_action/pheromones/emit_warding,
		/datum/action/xeno_action/pheromones/emit_frenzy,
		/datum/action/xeno_action/toggle_queen_zoom,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/set_xeno_lead,
		/datum/action/xeno_action/activable/queen_give_plasma,
		/datum/action/xeno_action/hive_message,
		/datum/action/xeno_action/rally_hive,
		/datum/action/xeno_action/activable/command_minions,
	)


/datum/xeno_caste/queen/young
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/queen/primordial
	upgrade_name = "Primordial"
	caste_desc = "A fearsome Xeno hulk of titanic proportions. Nothing can stand in it's way."
	primordial_message = "Destiny bows to our will as the universe trembles before us."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/activable/plant_weeds,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/blessing_menu,
		/datum/action/xeno_action/place_acidwell,
		/datum/action/xeno_action/call_of_the_burrowed,
		/datum/action/xeno_action/activable/screech,
		/datum/action/xeno_action/bulwark,
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/psychic_cure/queen_give_heal,
		/datum/action/xeno_action/activable/neurotox_sting/ozelomelyn,
		/datum/action/xeno_action/pheromones,
		/datum/action/xeno_action/pheromones/emit_recovery,
		/datum/action/xeno_action/pheromones/emit_warding,
		/datum/action/xeno_action/pheromones/emit_frenzy,
		/datum/action/xeno_action/toggle_queen_zoom,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/set_xeno_lead,
		/datum/action/xeno_action/activable/queen_give_plasma,
		/datum/action/xeno_action/hive_message,
		/datum/action/xeno_action/rally_hive,
		/datum/action/xeno_action/activable/command_minions,
		/datum/action/xeno_action/ready_charge/queen_charge,
	)
