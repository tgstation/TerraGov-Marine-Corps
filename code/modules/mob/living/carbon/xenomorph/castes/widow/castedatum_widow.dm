/datum/xeno_caste/widow
	caste_name = "Widow"
	display_name = "Widow"
	upgrade_name = ""
	caste_desc = "Test"
	caste_type_path = /mob/living/carbon/xenomorph/widow
	ancient_message = "Test"
	primordial_message = "Test"

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE

	gib_anim = "gibbed-a-corpse-runner"
	gib_flick = "gibbed-a-runner"

	// *** Melee Attacks *** //
	melee_damage = 7
	attack_delay = 3

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 5

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	evolution_threshold = 80
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/warrior

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING

	// *** Defense *** //
	soft_armor = list("melee" = 14, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 5, "acid" = 0)

	// *** Ranged Attack *** //

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/xenohide, // might remove later idk, depends on balance
		/datum/action/xeno_action/tight,
		/datum/action/xeno_action/activable/web_spit,
		/datum/action/xeno_action/activable/burrow,
		/datum/action/xeno_action/activable/snare_ball,
	)

/datum/xeno_caste/widow/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/widow/mature
	upgrade_name = "Mature"
	caste_desc = "uhh more spidey"

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 175
	plasma_gain = 7

	// *** Health *** //
	max_health = 275

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 16, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 0, "bio" = 3, "rad" = 3, "fire" = 10, "acid" = 3)

	// *** Ranged Attack *** //

/datum/xeno_caste/widow/elder
	upgrade_name = "Elder"
	caste_desc = " tarantula time "

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 10

	// *** Speed *** //
	speed = -0.7

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 9

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 18, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 0, "bio" = 5, "rad" = 5, "fire" = 15, "acid" = 5)

	// *** Ranged Attack *** //

/datum/xeno_caste/widow/ancient
	upgrade_name = "Ancient"
	caste_desc = "skittering menace"
	ancient_message = "ye"
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 12

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 11

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 20, "bullet" = 19, "laser" = 19, "energy" = 19, "bomb" = 0, "bio" = 7, "rad" = 7, "fire" = 19, "acid" = 7)

	// *** Ranged Attack *** //

/datum/xeno_caste/widow/primordial
	upgrade_name = "Primordial"
	caste_desc = "A skittering menace"
	primordial_message = "Nothing can escape our web"
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 15

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 11

	// *** Health *** //
	max_health = 350

	// *** Defense *** //
	soft_armor = list("melee" = 20, "bullet" = 19, "laser" = 19, "energy" = 19, "bomb" = 0, "bio" = 7, "rad" = 7, "fire" = 19, "acid" = 7)

	// *** Ranged Attack *** //

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/xenohide,
		//primo ability goes here
	)
