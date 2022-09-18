/datum/xeno_caste/widow
	caste_name = "Widow"
	display_name = "Widow"
	upgrade_name = ""
	caste_desc = "You don't think you've seen a tarantula this big before"
	caste_type_path = /mob/living/carbon/xenomorph/widow

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "widow"

	// *** Melee Attacks *** //
	melee_damage = 16

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
	caste_flags = CASTE_ACID_BLOOD|CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING|CASTE_CAN_VENT_CRAWL

	// *** Defense *** //
	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 5, BIO = 5, FIRE = 0, ACID = 5)

	// *** Minimap Icon *** //
	minimap_icon = "widow"

	// *** Widow Abilities *** //
	max_spiderlings = 2

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
	caste_desc = "So this is what the fly in a spider's web feels like"

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
	soft_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 10, BIO = 5, "rad" = 5, FIRE = 5, ACID = 5)

	// *** Widow Abilities *** //
	max_spiderlings = 3

/datum/xeno_caste/widow/elder
	upgrade_name = "Elder"
	caste_desc = "And they said Arachnophobia was irrational"
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 16

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
	soft_armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 13, BIO = 7, "rad" = 7, FIRE = 10, ACID = 7)

	// *** Widow Abilities *** //
	max_spiderlings = 4

/datum/xeno_caste/widow/ancient
	upgrade_name = "Ancient"
	caste_desc = "Like a spider web that you walk into, it won't be easy to get rid of it's owner."
	ancient_message = "By our hand is the fabric of life weaved and by our hand shall it be undone."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 18

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
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 15, BIO = 10, "rad" = 10, FIRE = 15, ACID = 10)

	// *** Widow Abilities *** //
	max_spiderlings = 5

/datum/xeno_caste/widow/primordial
	upgrade_name = "Primordial"
	caste_desc = "At times, life is just like a web. You fall, and a spider called accident, at the center, takes you to hell."
	primordial_message = "We weave the threads of fate that our victims life hangs from"
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 18

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 55

	// *** Health *** //
	max_health = 450

	// *** Defense *** //
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 15, BIO = 10, "rad" = 10, FIRE = 15, ACID = 10)

	// *** Widow Abilities *** //
	max_spiderlings = 5

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
