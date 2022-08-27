/datum/xeno_caste/widow
	caste_name = "Widow"
	display_name = "Widow"
	upgrade_name = ""
	caste_desc = " A spider xenomoroph, horrible"
	caste_type_path = /mob/living/carbon/xenomorph/widow

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "widow"


	// *** Melee Attacks *** //
	melee_damage = 7
	attack_delay = 3

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 40

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	deevolves_to = list(/mob/living/carbon/xenomorph/hunter, /mob/living/carbon/xenomorph/carrier)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 0, "bio" = 5, "rad" = 5, "fire" = 0, "acid" = 5)

	// *** Ranged Attack *** //

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/activable/plant_weeds,
		/datum/action/xeno_action/activable/web_spit,
		/datum/action/xeno_action/burrow,
		/datum/action/xeno_action/activable/leash_ball,
		/datum/action/xeno_action/create_spiderling,
		/datum/action/xeno_action/lay_egg,
	)

/datum/xeno_caste/widow/on_caste_applied(mob/xenomorph)
	. = ..()
	xenomorph.AddElement(/datum/element/wall_speedup, WIDOW_SPEED_BONUS)

/datum/xeno_caste/widow/on_caste_removed(mob/xenomorph)
	. = ..()
	xenomorph.RemoveElement(/datum/element/wall_speedup, WIDOW_SPEED_BONUS)

/datum/xeno_caste/widow/young
	upgrade_name = "Young"
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/widow/mature
	upgrade_name = "Mature"
	caste_desc = " More threatening spider xeno"

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 550
	plasma_gain = 45

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 0, "bio" = 5, "rad" = 5, "fire" = 5, "acid" = 5)

	// *** Ranged Attack *** //

/datum/xeno_caste/widow/elder
	upgrade_name = "Elder"
	caste_desc = " Starting to look very scary now "
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 10

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 575
	plasma_gain = 50

	// *** Health *** //
	max_health = 400

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = 0, "bio" = 7, "rad" = 7, "fire" = 10, "acid" = 7)

	// *** Ranged Attack *** //

/datum/xeno_caste/widow/ancient
	upgrade_name = "Ancient"
	caste_desc = " A fully grown xenomorph spider "
	ancient_message = "We feel faster and stronger"
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 12

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 55

	// *** Health *** //
	max_health = 450

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 0, "bio" = 10, "rad" = 10, "fire" = 15, "acid" = 10)

	// *** Ranged Attack *** //

/datum/xeno_caste/widow/primordial
	upgrade_name = "Primordial"
	caste_desc = " A fully grown and evolved spider xenomorph, menacing "
	primordial_message = "We are the swarm that is approaching"
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 15

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 625
	plasma_gain = 60

	// *** Health *** //
	max_health = 500

	// *** Defense *** //
	soft_armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 0, "bio" = 10, "rad" = 10, "fire" = 20, "acid" = 10)

	// *** Ranged Attack *** //

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/activable/web_spit,
		/datum/action/xeno_action/burrow,
		/datum/action/xeno_action/activable/leash_ball,
		/datum/action/xeno_action/create_spiderling,
		/datum/action/xeno_action/lay_egg,
		/datum/action/xeno_action/spider_swarm,
	)
