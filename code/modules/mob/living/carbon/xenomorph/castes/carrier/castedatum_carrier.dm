/datum/xeno_caste/carrier
	caste_name = "Carrier"
	display_name = "Carrier"
	upgrade_name = ""
	caste_desc = "A carrier of huggies."

	caste_type_path = /mob/living/carbon/Xenomorph/Carrier

	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 30

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 250
	plasma_gain = 8

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	evolution_threshold = 200
	upgrade_threshold = 200

	deevolves_to = /mob/living/carbon/Xenomorph/Drone

	evolves_to = list(/mob/living/carbon/Xenomorph/Defiler)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	can_hold_eggs = CAN_HOLD_ONE_HAND

	// *** Defense *** //
	armor_deflection = 5

	// *** Pheromones *** //
	aura_strength = 1.5
	aura_allowed = list("frenzy", "warding", "recovery")

	// *** Carrier Abilities *** //
	huggers_max = 8
	hugger_delay = 2.5 SECONDS
	eggs_max = 3

/datum/xeno_caste/carrier/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/carrier/mature
	upgrade_name = "Mature"
	caste_desc = "A portable Love transport. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage_lower = 25
	melee_damage_upper = 35

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 10

	// *** Health *** //
	max_health = 220

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 10

	// *** Pheromones *** //
	aura_strength = 2

	// *** Carrier Abilities *** //
	huggers_max = 9
	hugger_delay = 2.0 SECONDS
	eggs_max = 4

/datum/xeno_caste/carrier/elite
	upgrade_name = "Elite"
	caste_desc = "A portable Love transport. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage_lower = 30
	melee_damage_upper = 40

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 350
	plasma_gain = 12

	// *** Health *** //
	max_health = 220

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 10

	// *** Pheromones *** //
	aura_strength = 2.3

	// *** Carrier Abilities *** //
	huggers_max = 10
	hugger_delay = 1.5 SECONDS
	eggs_max = 5

/datum/xeno_caste/carrier/ancient
	upgrade_name = "Ancient"
	caste_desc = "It's literally crawling with 11 huggers."
	upgrade = XENO_UPGRADE_THREE
	ancient_message = "You are the master of huggers. Throw them like baseballs at the marines!"

	// *** Melee Attacks *** //
	melee_damage_lower = 35
	melee_damage_upper = 45

	// *** Tackle *** //
	tackle_damage = 45

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 15

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 15

	// *** Pheromones *** //
	aura_strength = 2.5

	// *** Carrier Abilities *** //
	huggers_max = 11
	hugger_delay = 1.0 SECONDS
	eggs_max = 6
	