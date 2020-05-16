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
	melee_damage = 35

	// *** Tackle *** //
	tackle_damage = 45

	// *** Speed *** //
	speed = 0.4

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 40

	// *** Health *** //
	max_health = 375

	// *** Evolution *** //
	upgrade_threshold = 480

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_FIRE_IMMUNE|CASTE_HIDE_IN_STATUS

	can_hold_eggs = CAN_HOLD_TWO_HANDS

	// *** Defense *** //
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 40, "energy" = 40, "bomb" = XENO_BOMB_RESIST_3, "bio" = 45, "rad" = 45, "fire" = 100, "acid" = 45)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/sticky, /datum/ammo/xeno/acid/medium)

	// *** Pheromones *** //
	aura_strength = 3.5 //The Queen's aura is strong and stays so, and gets devastating late game. Climbs by 1 to 5
	aura_allowed = list("frenzy", "warding", "recovery")

	// *** Queen Abilities *** //
	queen_leader_limit = 2 //Amount of leaders allowed

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/lay_egg,
		/datum/action/xeno_action/activable/larval_growth_sting,
		/datum/action/xeno_action/call_of_the_burrowed,
		/datum/action/xeno_action/activable/screech,
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/psychic_whisper,
		/datum/action/xeno_action/shift_spits,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/toggle_pheromones,
		/datum/action/xeno_action/toggle_queen_zoom,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/set_xeno_lead,
		/datum/action/xeno_action/activable/queen_give_plasma,
		/datum/action/xeno_action/queen_order,
		/datum/action/xeno_action/deevolve
		)


/datum/xeno_caste/queen/young
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/queen/mature
	caste_desc = "The biggest and baddest xeno. The Queen controls the hive and plants eggs"

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 40

	// *** Tackle *** //
	tackle_damage = 50

	// *** Speed *** //
	speed = 0.4

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 400

	// *** Evolution *** //
	upgrade_threshold = 960

	// *** Defense *** //
	soft_armor = list("melee" = 55, "bullet" = 55, "laser" = 40, "energy" = 40, "bomb" = XENO_BOMB_RESIST_3, "bio" = 50, "rad" = 50, "fire" = 100, "acid" = 50)

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
	melee_damage = 50

	// *** Tackle *** //
	tackle_damage = 55

	// *** Speed *** //
	speed = 0.3

	// *** Plasma *** //
	plasma_max = 1100
	plasma_gain = 60

	// *** Health *** //
	max_health = 425

	// *** Evolution *** //
	upgrade_threshold = 1920

	// *** Defense *** //
	soft_armor = list("melee" = 60, "bullet" = 60, "laser" = 45, "energy" = 45, "bomb" = XENO_BOMB_RESIST_3, "bio" = 55, "rad" = 55, "fire" = 100, "acid" = 55)

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
	melee_damage = 50

	// *** Tackle *** //
	tackle_damage = 60

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 1200
	plasma_gain = 70

	// *** Health *** //
	max_health = 450

	// *** Evolution *** //
	upgrade_threshold = 1920

	// *** Defense *** //
	soft_armor = list("melee" = 65, "bullet" = 65, "laser" = 50, "energy" = 50, "bomb" = XENO_BOMB_RESIST_3, "bio" = 60, "rad" = 60, "fire" = 100, "acid" = 60)

	// *** Ranged Attack *** //
	spit_delay = 1.1 SECONDS

	// *** Pheromones *** //
	aura_strength = 5

	// *** Queen Abilities *** //
	queen_leader_limit = 4
