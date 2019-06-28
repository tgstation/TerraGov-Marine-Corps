/datum/xeno_caste/shrike
	caste_name = "Shrike"
	display_name = "Shrike"
	upgrade_name = ""
	caste_desc = "A psychically unstable xeno. The Shrike controls the hive when there's no Queen and acts as its successor when there is."
	caste_type_path = /mob/living/carbon/xenomorph/shrike

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "shrike" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage_lower = 18
	melee_damage_upper = 24

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 750
	plasma_gain = 30

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	evolution_threshold = 200
	upgrade_threshold = 200

	evolves_to = list(/mob/living/carbon/xenomorph/queen)
	deevolves_to = /mob/living/carbon/xenomorph/drone

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_IS_INTELLIGENT|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	can_hold_eggs = CAN_HOLD_TWO_HANDS

	// *** Defense *** //
	armor_deflection = 10

	// *** Pheromones *** //
	aura_strength = 2 //The Shrike's aura is decent.
	aura_allowed = list("frenzy", "warding", "recovery")

/datum/xeno_caste/shrike/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/shrike/mature
	upgrade_name = "Mature"
	caste_desc = "The psychic xeno. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage_lower = 22
	melee_damage_upper = 28

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 850
	plasma_gain = 35

	// *** Health *** //
	max_health = 260

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 25

	// *** Pheromones *** //
	aura_strength = 2.5

/datum/xeno_caste/shrike/elder
	upgrade_name = "Elder"
	caste_desc = "The psychic xeno. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage_lower = 26
	melee_damage_upper = 32

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 40

	// *** Health *** //
	max_health = 270

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 35

	// *** Pheromones *** //
	aura_strength = 2.8

/datum/xeno_caste/shrike/ancient
	upgrade_name = "Ancient"
	caste_desc = "A barely contained repository of the hive's psychic power."
	ancient_message = "We are psychic repository of the hive, and we are ready to unleash our fury."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage_lower = 28
	melee_damage_upper = 34

	// *** Tackle *** //
	tackle_damage = 45

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 925
	plasma_gain = 45

	// *** Health *** //
	max_health = 275

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor_deflection = 40

	// *** Pheromones *** //
	aura_strength = 3
