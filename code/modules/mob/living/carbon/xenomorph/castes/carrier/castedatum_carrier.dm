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
	melee_damage = 17

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 20

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	evolution_threshold = 180
	upgrade_threshold = 120

	deevolves_to = /mob/living/carbon/xenomorph/drone

	evolves_to = list(/mob/living/carbon/xenomorph/Defiler)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CAN_BECOME_KING
	can_hold_eggs = CAN_HOLD_ONE_HAND

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 5, "rad" = 5, "fire" = 15, "acid" = 5)

	// *** Pheromones *** //
	aura_strength = 1.5
	aura_allowed = list("frenzy", "warding", "recovery")

	// *** Carrier Abilities *** //
	huggers_max = 4
	hugger_delay = 2.5 SECONDS
	eggs_max = 3

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/headbite,
		/datum/action/xeno_action/activable/devour,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/activable/throw_hugger,
		/datum/action/xeno_action/lay_egg,
		/datum/action/xeno_action/activable/retrieve_egg,
		/datum/action/xeno_action/place_trap,
		/datum/action/xeno_action/spawn_hugger,
		/datum/action/xeno_action/toggle_pheromones,
		/datum/action/xeno_action/choose_hugger_type,
	)

/datum/xeno_caste/carrier/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/carrier/mature
	upgrade_name = "Mature"
	caste_desc = "A portable Love transport. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 25

	// *** Health *** //
	max_health = 275

	// *** Evolution *** //
	upgrade_threshold = 360

	// *** Defense *** //
	soft_armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = XENO_BOMB_RESIST_0, "bio" = 5, "rad" = 5, "fire" = 20, "acid" = 5)

	// *** Pheromones *** //
	aura_strength = 2

	// *** Carrier Abilities *** //
	huggers_max = 5
	hugger_delay = 2.5 SECONDS
	eggs_max = 4

/datum/xeno_caste/carrier/elder
	upgrade_name = "Elder"
	caste_desc = "A portable Love transport. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 700
	plasma_gain = 30

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 840

	// *** Defense *** //
	soft_armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = XENO_BOMB_RESIST_0, "bio" = 7, "rad" = 7, "fire" = 25, "acid" = 7)

	// *** Pheromones *** //
	aura_strength = 2.3

	// *** Carrier Abilities *** //
	huggers_max = 6
	hugger_delay = 2 SECONDS
	eggs_max = 5

/datum/xeno_caste/carrier/ancient
	upgrade_name = "Ancient"
	caste_desc = "It's literally crawling with 11 huggers."
	upgrade = XENO_UPGRADE_THREE
	ancient_message = "We are the master of huggers. We shall throw them like baseballs at the marines!"

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 38

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = 1320

	// *** Defense *** //
	soft_armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_0, "bio" = 10, "rad" = 10, "fire" = 30, "acid" = 10)

	// *** Pheromones *** //
	aura_strength = 2.5

	// *** Carrier Abilities *** //
	huggers_max = 7
	hugger_delay = 1.5 SECONDS
	eggs_max = 6

