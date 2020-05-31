/datum/xeno_caste/drone
	caste_name = "Drone"
	display_name = "Drone"
	upgrade_name = ""
	caste_desc = "A builder of hives. Only drones may evolve into Shrikes."
	caste_type_path = /mob/living/carbon/xenomorph/drone

	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 750
	plasma_gain = 25

	// *** Health *** //
	max_health = 175

	// *** Evolution *** //
	evolution_threshold = 80
	upgrade_threshold = 60

	evolves_to = list(/mob/living/carbon/xenomorph/shrike, /mob/living/carbon/xenomorph/carrier, /mob/living/carbon/xenomorph/hivelord, /mob/living/carbon/xenomorph/hivemind)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	can_hold_eggs = CAN_HOLD_TWO_HANDS

	// *** Defense *** //
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = XENO_BOMB_RESIST_0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	// *** Pheromones *** //
	aura_strength = 1 //Drone's aura is the weakest. At the top of their evolution, it's equivalent to a Young Queen Climbs by 0.5 to 2
	aura_allowed = list("frenzy", "warding", "recovery")

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/activable/psychic_cure/drone,
		/datum/action/xeno_action/activable/transfer_plasma,
		/datum/action/xeno_action/activable/salvage_plasma,
		/datum/action/xeno_action/activable/corrosive_acid/drone,
		/datum/action/xeno_action/activable/larval_growth_sting,
		/datum/action/xeno_action/toggle_pheromones
		)

/datum/xeno_caste/drone/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/drone/mature
	upgrade_name = "Mature"
	caste_desc = "The workhorse of the hive. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 24

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 30

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	upgrade_threshold = 120

	// *** Defense *** //
	soft_armor = list("melee" = 17, "bullet" = 17, "laser" = 17, "energy" = 17, "bomb" = XENO_BOMB_RESIST_0, "bio" = 5, "rad" = 5, "fire" = 5, "acid" = 5)

	// *** Pheromones *** //
	aura_strength = 1.5

/datum/xeno_caste/drone/elder
	upgrade_name = "Elder"
	caste_desc = "The workhorse of the hive. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 28

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -1.1

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 35

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	upgrade_threshold = 240

	// *** Defense *** //
	soft_armor = list("melee" = 24, "bullet" = 24, "laser" = 24, "energy" = 24, "bomb" = XENO_BOMB_RESIST_0, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)

	// *** Pheromones *** //
	aura_strength = 1.8

/datum/xeno_caste/drone/ancient
	upgrade_name = "Ancient"
	caste_desc = "A very mean architect."
	ancient_message = "We are the ultimate worker of the Hive. Time to clock in, and clock the tallhosts out."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 32

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -1.3

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 40

	// *** Health *** //
	max_health = 250

	// *** Defense *** //
	soft_armor = list("melee" = 31, "bullet" = 31, "laser" = 31, "energy" = 31, "bomb" = XENO_BOMB_RESIST_0, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)

	// *** Pheromones *** //
	aura_strength = 2
