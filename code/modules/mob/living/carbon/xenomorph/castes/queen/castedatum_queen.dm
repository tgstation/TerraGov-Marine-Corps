/datum/xeno_caste/queen
	caste_name = "Queen"
	display_name = "Queen"
	caste_type_path = /mob/living/carbon/xenomorph/queen
	caste_desc = "The biggest and baddest xeno. The Queen controls the hive and plants eggs"
	job_type = /datum/job/xenomorph/queen

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "queen" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 40

	// *** Health *** //
	max_health = 425

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_IS_BUILDER
	can_hold_eggs = CAN_HOLD_TWO_HANDS
	can_flags = CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_HOLD_JELLY|CASTE_CAN_CORRUPT_GENERATOR|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 30, BIO = 45, "rad" = 45, FIRE = 45, ACID = 45)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/sticky, /datum/ammo/xeno/acid/medium)

	// *** Pheromones *** //
	aura_strength = 3.5 //The Queen's aura is strong and stays so, and gets devastating late game. Climbs by 1 to 5

	// *** Queen Abilities *** //
	queen_leader_limit = 2 //Amount of leaders allowed

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
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/psychic_cure/acidic_salve/queen,
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
		/datum/action/xeno_action/deevolve,
		/datum/action/xeno_action/rally_hive,
		/datum/action/xeno_action/rally_minion,
		/datum/action/xeno_action/activable/command_minions,
		/datum/action/xeno_action/set_agressivity,
	)


/datum/xeno_caste/queen/young
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/queen/mature
	caste_desc = "The biggest and baddest xeno. The Queen controls the hive and plants eggs."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 450

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 55, BULLET = 55, LASER = 55, ENERGY = 55, BOMB = 30, BIO = 50, "rad" = 50, FIRE = 50, ACID = 50)

	// *** Ranged Attack *** //
	spit_delay = 1.2 SECONDS

	// *** Pheromones *** //
	aura_strength = 4

	// *** Queen Abilities *** //
	queen_leader_limit = 3

/datum/xeno_caste/queen/elder
	caste_desc = "The biggest and baddest xeno. The Empress controls multiple hives and planets."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 1100
	plasma_gain = 60

	// *** Health *** //
	max_health = 475

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 30, BIO = 55, "rad" = 55, FIRE = 55, ACID = 55)

	// *** Ranged Attack *** //
	spit_delay = 1.2 SECONDS

	// *** Pheromones *** //
	aura_strength = 4.5

	// *** Queen Abilities *** //
	queen_leader_limit = 3

/datum/xeno_caste/queen/ancient
	caste_desc = "The most perfect Xeno form imaginable."
	ancient_message = "We are the Alpha and the Omega. The beginning and the end."
	upgrade = XENO_UPGRADE_THREE

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
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 65, BULLET = 65, LASER = 65, ENERGY = 65, BOMB = 30, BIO = 60, "rad" = 60, FIRE = 60, ACID = 60)

	// *** Ranged Attack *** //
	spit_delay = 1.1 SECONDS

	// *** Pheromones *** //
	aura_strength = 5

	// *** Queen Abilities *** //
	queen_leader_limit = 4

//same stats as ancient
/datum/xeno_caste/queen/primordial
	caste_desc = "A fearsome Xeno hulk of titanic proportions. Nothing can stand in it's way."
	primordial_message = "Destiny bows to our will as the universe trembles before us."
	upgrade = XENO_UPGRADE_FOUR
	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 1200
	plasma_gain = 70

	// *** Health *** //
	max_health = 500

	// *** Defense *** //
	soft_armor = list(MELEE = 65, BULLET = 65, LASER = 65, ENERGY = 65, BOMB = 30, BIO = 60, "rad" = 60, FIRE = 60, ACID = 60)

	// *** Ranged Attack *** //
	spit_delay = 1.1 SECONDS

	// *** Pheromones *** //
	aura_strength = 5

	// *** Queen Abilities *** //
	queen_leader_limit = 4

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
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/psychic_cure/acidic_salve/queen,
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
		/datum/action/xeno_action/deevolve,
		/datum/action/xeno_action/rally_hive,
		/datum/action/xeno_action/rally_minion,
		/datum/action/xeno_action/activable/command_minions,
		/datum/action/xeno_action/set_agressivity,
		/datum/action/xeno_action/ready_charge/queen_charge,
	)
