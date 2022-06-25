/datum/xeno_caste/gorger
	caste_name = "Gorger"
	display_name = "Gorger"
	upgrade_name = ""
	caste_desc = "A frightening looking, bulky alien creature that drips with a familiar red fluid."
	caste_type_path = /mob/living/carbon/xenomorph/gorger
	ancient_message = "We are eternal. We will persevere where others will dry and wither."
	primordial_message = "There is nothing we can't withstand."

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "gorger" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 15

	// *** Speed *** //
	speed = -0.6
	weeds_speed_mod = 0.2

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 0
	plasma_regen_limit = 0
	plasma_icon_state = "fury"

	// *** Health *** //
	max_health = 400

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	deevolves_to = list(/mob/living/carbon/xenomorph/warrior, /mob/living/carbon/xenomorph/hivelord)

	// *** Flags *** //
	caste_flags = CASTE_INNATE_PLASMA_REGEN|CASTE_PLASMADRAIN_IMMUNE
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING

	// *** Defense *** //
	soft_armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 10, "bio" = 5, "rad" = 5, "fire" = 5, "acid" = 5)

	// *** Minimap Icon *** //
	minimap_icon = "gorger"

	// *** Gorger Abilities *** //
	overheal_max = 200
	drain_plasma_gain = 20
	carnage_plasma_gain = 25
	feast_plasma_drain = 20

	actions = list(
		/datum/action/xeno_action/show_hivestatus,
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain/free,
		/datum/action/xeno_action/activable/psychic_link,
		/datum/action/xeno_action/activable/drain,
		/datum/action/xeno_action/activable/transfusion,
		/datum/action/xeno_action/activable/carnage,
		/datum/action/xeno_action/activable/feast,
		/datum/action/xeno_action/activable/devour,
	)

/datum/xeno_caste/gorger/young
	upgrade_name = "Young"
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/gorger/mature
	upgrade_name = "Mature"
	caste_desc = "A frightening looking, bulky alien creature that drips with a familiar red fluid. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 250

	// *** Health *** //
	max_health = 450

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)

	// *** Gorger Abilities *** //
	overheal_max = 225
	drain_plasma_gain = 20
	carnage_plasma_gain = 30

/datum/xeno_caste/gorger/elder
	upgrade_name = "Elder"
	caste_desc = "A frightening looking, bulky alien creature that drips with a familiar red fluid. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Plasma *** //
	plasma_max = 300

	// *** Health *** //
	max_health = 500

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 10, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)

	// *** Gorger Abilities *** //
	overheal_max = 250
	drain_plasma_gain = 30
	carnage_plasma_gain = 35

/datum/xeno_caste/gorger/ancient
	upgrade_name = "Ancient"
	caste_desc = "Being within mere eyeshot of this hulking monstrosity fills you with a deep, unshakeable sense of unease."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Plasma *** //
	plasma_max = 400

	// *** Health *** //
	max_health = 600

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 10, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 20)

	// *** Gorger Abilities *** //
	overheal_max = 275
	drain_plasma_gain = 40
	carnage_plasma_gain = 40

/datum/xeno_caste/gorger/primordial
	upgrade_name = "Primordial"
	caste_desc = "Being within mere eyeshot of this hulking monstrosity fills you with a deep, unshakeable sense of unease. You are unsure if you can even harm it."
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Plasma *** //
	plasma_max = 400

	// *** Health *** //
	max_health = 600

	// *** Defense *** //
	soft_armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 10, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 20)

	// *** Gorger Abilities *** //
	overheal_max = 275
	drain_plasma_gain = 40
	carnage_plasma_gain = 40

	actions = list(
		/datum/action/xeno_action/show_hivestatus,
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain/free,
		/datum/action/xeno_action/activable/psychic_link,
		/datum/action/xeno_action/activable/drain,
		/datum/action/xeno_action/activable/transfusion,
		/datum/action/xeno_action/activable/rejuvenate,
		/datum/action/xeno_action/activable/carnage,
		/datum/action/xeno_action/activable/feast,
		/datum/action/xeno_action/activable/devour,
	)
