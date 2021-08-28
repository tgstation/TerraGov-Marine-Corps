/datum/xeno_caste/shrike
	caste_name = "Shrike"
	display_name = "Shrike"
	upgrade_name = ""
	caste_desc = "A psychically unstable xeno. The Shrike controls the hive when there's no Queen and acts as its successor when there is."
	job_type = /datum/job/xenomorph/queen
	caste_type_path = /mob/living/carbon/xenomorph/shrike

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "shrike" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 750
	plasma_gain = 30

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	evolution_threshold = 180
	upgrade_threshold = 120

	evolves_to = list(/mob/living/carbon/xenomorph/queen)
	deevolves_to = /mob/living/carbon/xenomorph/drone

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_IS_INTELLIGENT|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_CORRUPT_GENERATOR|CASTE_IS_STRONG

	can_hold_eggs = CAN_HOLD_TWO_HANDS

	// *** Defense *** //
	soft_armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_2, "bio" = 10, "rad" = 10, "fire" = 30, "acid" = 10)

	// *** Pheromones *** //
	aura_strength = 2 //The Shrike's aura is decent.
	aura_allowed = list("frenzy", "warding", "recovery")

	minimap_icon = "xenoshrike"

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/headbite,
		/datum/action/xeno_action/activable/devour,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/lay_egg,
		/datum/action/xeno_action/activable/larval_growth_sting,
		/datum/action/xeno_action/call_of_the_burrowed,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/activable/build_silo,
		/datum/action/xeno_action/activable/build_hunt_den,
		/datum/action/xeno_action/activable/build_turret,
		/datum/action/xeno_action/place_acidwell,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/activable/psychic_cure,
		/datum/action/xeno_action/psychic_whisper,
		/datum/action/xeno_action/activable/psychic_fling,
		/datum/action/xeno_action/activable/unrelenting_force,
		/datum/action/xeno_action/toggle_pheromones,
		/datum/action/xeno_action/activable/rally_hive,
	)

/datum/xeno_caste/shrike/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/shrike/mature
	upgrade_name = "Mature"
	caste_desc = "The psychic xeno. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 850
	plasma_gain = 35

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = 360

	// *** Defense *** //
	soft_armor = list("melee" = 35, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = XENO_BOMB_RESIST_2, "bio" = 15, "rad" = 15, "fire" = 35, "acid" = 15)

	// *** Pheromones *** //
	aura_strength = 2.5

/datum/xeno_caste/shrike/elder
	upgrade_name = "Elder"
	caste_desc = "The psychic xeno. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 40

	// *** Health *** //
	max_health = 375

	// *** Evolution *** //
	upgrade_threshold = 840

	// *** Defense *** //
	soft_armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = XENO_BOMB_RESIST_2, "bio" = 18, "rad" = 18, "fire" = 40, "acid" = 18)

	// *** Pheromones *** //
	aura_strength = 2.8

/datum/xeno_caste/shrike/ancient
	upgrade_name = "Ancient"
	caste_desc = "A barely contained repository of the hive's psychic power."
	ancient_message = "We are psychic repository of the hive, and we are ready to unleash our fury."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 925
	plasma_gain = 45

	// *** Health *** //
	max_health = 400

	// *** Evolution *** //
	upgrade_threshold = 1320

	// *** Defense *** //
	soft_armor = list("melee" = 45, "bullet" = 45, "laser" = 45, "energy" = 45, "bomb" = XENO_BOMB_RESIST_2, "bio" = 23, "rad" = 23, "fire" = 45, "acid" = 20)

	// *** Pheromones *** //
	aura_strength = 3
