/datum/xeno_caste/drone
	caste_name = "Drone"
	display_name = "Drone"
	upgrade_name = ""
	caste_desc = "A builder of hives. Only drones may evolve into Shrikes."
	caste_type_path = /mob/living/carbon/xenomorph/drone

	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage_lower = 12
	melee_damage_upper = 16

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 750
	plasma_gain = 25

	// *** Health *** //
	max_health = 120

	// *** Evolution *** //
	evolution_threshold = 100
	upgrade_threshold = 100

	evolves_to = list(/mob/living/carbon/xenomorph/shrike, /mob/living/carbon/xenomorph/carrier, /mob/living/carbon/xenomorph/hivelord)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	can_hold_eggs = CAN_HOLD_TWO_HANDS

	// *** Defense *** //
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = XENO_BOMB_RESIST_0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	// *** Pheromones *** //
	aura_strength = 1 //Drone's aura is the weakest. At the top of their evolution, it's equivalent to a Young Queen Climbs by 0.5 to 2
	aura_allowed = list("frenzy", "warding", "recovery")

/datum/xeno_caste/drone/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/drone/mature
	upgrade_name = "Mature"
	caste_desc = "The workhorse of the hive. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage_lower = 15
	melee_damage_upper = 20

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 30

	// *** Health *** //
	max_health = 150

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Defense *** //
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = XENO_BOMB_RESIST_0, "bio" = 5, "rad" = 5, "fire" = 5, "acid" = 5)

	// *** Pheromones *** //
	aura_strength = 1.5

/datum/xeno_caste/drone/elder
	upgrade_name = "Elder"
	caste_desc = "The workhorse of the hive. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage_lower = 15
	melee_damage_upper = 20

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -1.0

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 35

	// *** Health *** //
	max_health = 170

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = XENO_BOMB_RESIST_0, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)

	// *** Pheromones *** //
	aura_strength = 1.8

/datum/xeno_caste/drone/ancient
	upgrade_name = "Ancient"
	caste_desc = "A very mean architect."
	ancient_message = "We are the ultimate worker of the Hive. Time to clock in, and clock the tallhosts out."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 25

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -1.1

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 40

	// *** Health *** //
	max_health = 180

	// *** Defense *** //
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)

	// *** Pheromones *** //
	aura_strength = 2
	
/datum/xeno_caste/drone/fun
	caste_name = "Fun Drone"
	display_name = "Drone"
	upgrade_name = ""
	caste_desc = "A builder of hives. Only drones may evolve into Shrikes."
	caste_type_path = /mob/living/carbon/xenomorph/drone/fun

	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	melee_damage_lower = 12
	melee_damage_upper = 16
	tackle_damage = 25
	speed = -0.8
	plasma_max = 750
	plasma_gain = 25
	max_health = 120
	evolution_threshold = 100
	upgrade_threshold = 100
	evolves_to = list(/mob/living/carbon/xenomorph/shrike, /mob/living/carbon/xenomorph/carrier, /mob/living/carbon/xenomorph/hivelord)
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	can_hold_eggs = CAN_HOLD_TWO_HANDS
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = XENO_BOMB_RESIST_0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	aura_strength = 1 //Drone's aura is the weakest. At the top of their evolution, it's equivalent to a Young Queen Climbs by 0.5 to 2
	aura_allowed = list("frenzy", "warding", "recovery")

/datum/xeno_caste/drone/young
	upgrade_name = "Young"
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/drone/fun/mature
	upgrade_name = "Mature"
	caste_desc = "The workhorse of the hive. It looks a little more dangerous."
	upgrade = XENO_UPGRADE_ONE
	melee_damage_lower = 15
	melee_damage_upper = 20
	tackle_damage = 30
	speed = -0.9
	plasma_max = 800
	plasma_gain = 30
	max_health = 150
	upgrade_threshold = 200
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = XENO_BOMB_RESIST_0, "bio" = 5, "rad" = 5, "fire" = 5, "acid" = 5)
	aura_strength = 1.5

/datum/xeno_caste/drone/fun/elder
	upgrade_name = "Elder"
	caste_desc = "The workhorse of the hive. It looks a little more dangerous."
	upgrade = XENO_UPGRADE_TWO
	melee_damage_lower = 15
	melee_damage_upper = 20
	tackle_damage = 35
	speed = -1.0
	plasma_max = 900
	plasma_gain = 35
	max_health = 170
	upgrade_threshold = 400
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = XENO_BOMB_RESIST_0, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	aura_strength = 1.8

/datum/xeno_caste/drone/fun/ancient
	upgrade_name = "Ancient"
	caste_desc = "A very mean architect."
	ancient_message = "We are the ultimate worker of the Hive. Time to clock in, and clock the tallhosts out."
	upgrade = XENO_UPGRADE_THREE
	melee_damage_lower = 20
	melee_damage_upper = 25
	tackle_damage = 40
	speed = -1.1
	plasma_max = 1000
	plasma_gain = 40
	max_health = 180
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)
	aura_strength = 2