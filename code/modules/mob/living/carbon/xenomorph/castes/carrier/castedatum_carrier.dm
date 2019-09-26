/datum/xeno_caste/carrier
	caste_name = "Carrier"
	display_name = "Carrier"
	upgrade_name = ""
	caste_desc = "A carrier of huggies."

	caste_type_path = /mob/living/carbon/xenomorph/carrier

	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "carrier" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 25

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

	deevolves_to = /mob/living/carbon/xenomorph/drone

	evolves_to = list(/mob/living/carbon/xenomorph/Defiler)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	can_hold_eggs = CAN_HOLD_ONE_HAND

	// *** Defense *** //
	armor = list("melee" = 5, "bullet" = 0, "laser" = 0, "energy" = 5, "bomb" = XENO_BOMB_RESIST_0, "bio" = 5, "rad" = 5, "fire" = 5, "acid" = 5)

	// *** Pheromones *** //
	aura_strength = 1.5
	aura_allowed = list("frenzy", "warding", "recovery")

	// *** Carrier Abilities *** //
	huggers_max = 8
	hugger_delay = 2.5 SECONDS
	eggs_max = 3

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/activable/throw_hugger,
		/datum/action/xeno_action/activable/retrieve_egg,
		/datum/action/xeno_action/place_trap,
		/datum/action/xeno_action/spawn_hugger,
		/datum/action/xeno_action/toggle_pheromones
		)

/datum/xeno_caste/carrier/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/carrier/mature
	upgrade_name = "Mature"
	caste_desc = "A portable Love transport. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 30

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
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = XENO_BOMB_RESIST_0, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)

	// *** Pheromones *** //
	aura_strength = 2

	// *** Carrier Abilities *** //
	huggers_max = 9
	hugger_delay = 2.0 SECONDS
	eggs_max = 4

/datum/xeno_caste/carrier/elder
	upgrade_name = "Elder"
	caste_desc = "A portable Love transport. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 35

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
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = XENO_BOMB_RESIST_0, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)

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
	ancient_message = "We are the master of huggers. We shall throw them like baseballs at the marines!"

	// *** Melee Attacks *** //
	melee_damage = 40

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
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)

	// *** Pheromones *** //
	aura_strength = 2.5

	// *** Carrier Abilities *** //
	huggers_max = 11
	hugger_delay = 1.0 SECONDS
	eggs_max = 6
	
