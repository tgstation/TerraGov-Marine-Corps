/datum/xeno_caste/drone
	caste_name = "Drone"
	display_name = "Drone"
	upgrade_name = ""
	caste_desc = "A builder of hives. Only drones may evolve into Shrikes."
	caste_type_path = /mob/living/carbon/xenomorph/drone

	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 16

	// *** Speed *** //
	speed = -0.8
	weeds_speed_mod = -0.4

	// *** Plasma *** //
	plasma_max = 750
	plasma_gain = 25

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	evolution_threshold = 80
	upgrade_threshold = TIER_ONE_YOUNG_THRESHOLD

	evolves_to = list(
		/mob/living/carbon/xenomorph/shrike,
		/mob/living/carbon/xenomorph/queen,
		/mob/living/carbon/xenomorph/carrier,
		/mob/living/carbon/xenomorph/hivelord,
		/mob/living/carbon/xenomorph/hivemind,
	)

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_IS_BUILDER
	can_hold_eggs = CAN_HOLD_TWO_HANDS
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_HOLD_JELLY|CASTE_CAN_BECOME_KING|CASTE_CAN_RIDE_CRUSHER

	// *** Defense *** //
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 0)

	// *** Pheromones *** //
	aura_strength = 1 //Drone's aura is the weakest. At the top of their evolution, it's equivalent to a Young Queen Climbs by 0.5 to 2

	// *** Minimap Icon *** //
	minimap_icon = "drone"

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/activable/plant_weeds,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/activable/psychic_cure/acidic_salve,
		/datum/action/xeno_action/activable/transfer_plasma/drone,
		/datum/action/xeno_action/activable/corrosive_acid/drone,
		/datum/action/xeno_action/activable/neurotox_sting/ozelomelyn,
		/datum/action/xeno_action/create_jelly/slow,
		/datum/action/xeno_action/pheromones,
		/datum/action/xeno_action/pheromones/emit_recovery,
		/datum/action/xeno_action/pheromones/emit_warding,
		/datum/action/xeno_action/pheromones/emit_frenzy,
	)

/datum/xeno_caste/drone/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/drone/mature
	upgrade_name = "Mature"
	caste_desc = "The workhorse of the hive. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 30

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 17, "bullet" = 17, "laser" = 17, "energy" = 17, "bomb" = 0, "bio" = 5, "rad" = 5, "fire" = 17, "acid" = 5)

	// *** Pheromones *** //
	aura_strength = 1.5

/datum/xeno_caste/drone/elder
	upgrade_name = "Elder"
	caste_desc = "The workhorse of the hive. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 18

	// *** Speed *** //
	speed = -1.0

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 35

	// *** Health *** //
	max_health = 275

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 24, "bullet" = 24, "laser" = 24, "energy" = 24, "bomb" = 0, "bio" = 10, "rad" = 10, "fire" = 24, "acid" = 10)

	// *** Pheromones *** //
	aura_strength = 1.8

/datum/xeno_caste/drone/ancient
	upgrade_name = "Ancient"
	caste_desc = "A very mean architect."
	ancient_message = "We are the ultimate worker of the Hive. Time to clock in, and clock the tallhosts out."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 18

	// *** Speed *** //
	speed = -1.2

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 40

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 31, "bullet" = 31, "laser" = 31, "energy" = 31, "bomb" = 0, "bio" = 15, "rad" = 15, "fire" = 31, "acid" = 15)

	// *** Pheromones *** //
	aura_strength = 2

/datum/xeno_caste/drone/primordial
	upgrade_name = "Primordial"
	caste_desc = "The perfect worker."
	primordial_message = "We shall build wonders with our claws. Glory to the hive."
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 18

	// *** Speed *** //
	speed = -1.2

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 40

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 660

	// *** Defense *** //
	soft_armor = list("melee" = 31, "bullet" = 31, "laser" = 31, "energy" = 31, "bomb" = 0, "bio" = 15, "rad" = 15, "fire" = 31, "acid" = 15)

	// *** Pheromones *** //
	aura_strength = 2

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/activable/plant_weeds,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/sow,
		/datum/action/xeno_action/activable/psychic_cure/acidic_salve,
		/datum/action/xeno_action/activable/transfer_plasma/drone,
		/datum/action/xeno_action/activable/corrosive_acid/drone,
		/datum/action/xeno_action/activable/neurotox_sting/ozelomelyn,
		/datum/action/xeno_action/create_jelly/slow,
		/datum/action/xeno_action/pheromones,
		/datum/action/xeno_action/pheromones/emit_recovery,
		/datum/action/xeno_action/pheromones/emit_warding,
		/datum/action/xeno_action/pheromones/emit_frenzy,
	)
