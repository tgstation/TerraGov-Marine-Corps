/datum/xeno_caste/queen
	caste_name = "Queen"
	display_name = "Queen"
	caste_type_path = /mob/living/carbon/Xenomorph/Queen
	caste_desc = "The biggest and baddest xeno. The Queen controls the hive and plants eggs"

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage_lower = 45
	melee_damage_upper = 55

	// *** Tackle *** //
	tackle_damage = 55

	// *** Speed *** //
	speed = 0.6

	// *** Plasma *** //
	plasma_max = 700
	plasma_gain = 30

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_FIRE_IMMUNE

	can_hold_eggs = CAN_HOLD_TWO_HANDS

	// *** Defense *** //
	armor_deflection = 45

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/sticky, /datum/ammo/xeno/acid/heavy)

	// *** Pheromones *** //
	aura_strength = 3 //The Queen's aura is strong and stays so, and gets devastating late game. Climbs by 1 to 5
	aura_allowed = list("frenzy", "warding", "recovery")

	// *** Queen Abilities *** //
	queen_leader_limit = 1 //Amount of leaders allowed

/datum/xeno_caste/queen/young
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/queen/mature
	caste_desc = "The biggest and baddest xeno. The Queen controls the hive and plants eggs"

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage_lower = 50
	melee_damage_upper = 60

	// *** Tackle *** //
	tackle_damage = 60

	// *** Speed *** //
	speed = 0.5

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 40

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor_deflection = 50

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS

	// *** Pheromones *** //
	aura_strength = 4

	// *** Queen Abilities *** //
	queen_leader_limit = 2

/datum/xeno_caste/queen/elder
	caste_desc = "The biggest and baddest xeno. The Empress controls multiple hives and planets."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage_lower = 55
	melee_damage_upper = 65

	// *** Tackle *** //
	tackle_damage = 65

	// *** Speed *** //
	speed = 0.4

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 50

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = 3200

	// *** Defense *** //
	armor_deflection = 55

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS

	// *** Pheromones *** //
	aura_strength = 4.7

	// *** Queen Abilities *** //
	queen_leader_limit = 3

/datum/xeno_caste/queen/ancient
	caste_desc = "The most perfect Xeno form imaginable."
	ancient_message = "You are the Alpha and the Omega. The beginning and the end."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage_lower = 60
	melee_damage_upper = 70

	// *** Tackle *** //
	tackle_damage = 70

	// *** Speed *** //
	speed = 0.3

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 375

	// *** Evolution *** //
	upgrade_threshold = 3200

	// *** Defense *** //
	armor_deflection = 60

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS

	// *** Pheromones *** //
	aura_strength = 5

	// *** Queen Abilities *** //
	queen_leader_limit = 4
