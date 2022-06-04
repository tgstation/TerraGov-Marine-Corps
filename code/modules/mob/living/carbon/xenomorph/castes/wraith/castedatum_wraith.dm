/datum/xeno_caste/wraith
	caste_name = "Wraith"
	display_name = "Wraith"
	upgrade_name = ""
	caste_desc = "A strange xeno that utilizes its psychic powers to move out of phase with reality."
	caste_type_path = /mob/living/carbon/xenomorph/wraith
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "wraith" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 17

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 15

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	evolution_threshold = 180
	upgrade_threshold = TIER_TWO_YOUNG_THRESHOLD

	evolves_to = list(
		/mob/living/carbon/xenomorph/Defiler,
		/mob/living/carbon/xenomorph/ravager,
	)
	deevolves_to = /mob/living/carbon/xenomorph/runner

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING

	// *** Defense *** //
	soft_armor = list("melee" = 25, "bullet" = 25, "laser" = 5, "energy" = 5, "bomb" = 0, "bio" = 10, "rad" = 15, "fire" = 15, "acid" = 10)

	// *** Minimap Icon *** //
	minimap_icon = "wraith"

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/blink,
		/datum/action/xeno_action/activable/banish,
		/datum/action/xeno_action/recall,
		/datum/action/xeno_action/portal,
	)

/datum/xeno_caste/wraith/young
	upgrade_name = "Young"
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/wraith/mature
	upgrade_name = "Mature"
	caste_desc = "A manipulator of space and time. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -1.1

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 20

	// *** Health *** //
	max_health = 230

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 30, "bullet" = 30, "laser" = 10, "energy" = 10, "bomb" = 0, "bio" = 15, "rad" = 20, "fire" = 20, "acid" = 15)


/datum/xeno_caste/wraith/elder
	upgrade_name = "Elder"
	caste_desc = "A manipulator of space and time. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -1.2

	// *** Plasma *** //
	plasma_max = 350
	plasma_gain = 23

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 35, "bullet" = 35, "laser" = 15, "energy" = 15, "bomb" = 0, "bio" = 18, "rad" = 25, "fire" = 25, "acid" = 18)


/datum/xeno_caste/wraith/ancient
	upgrade_name = "Ancient"
	caste_desc = "A master manipulator of space and time."
	ancient_message = "We are the master of space and time. Reality bends to our will."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -1.25

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 25

	// *** Health *** //
	max_health = 260

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 40, "bullet" = 40, "laser" = 20, "energy" = 20, "bomb" = 0, "bio" = 18, "rad" = 25, "fire" = 30, "acid" = 18)

/datum/xeno_caste/wraith/primordial
	upgrade_name = "Primordial"
	caste_desc = "A xenomorph that has perfected the manipulation of space and time. Its movements appear quick and distorted."
	primordial_message = "Mastery is achieved when \'telling time\' becomes \'telling time what to do\'."
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -1.25

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 25

	// *** Health *** //
	max_health = 260

	// *** Defense *** //
	soft_armor = list("melee" = 40, "bullet" = 40, "laser" = 20, "energy" = 20, "bomb" = 0, "bio" = 18, "rad" = 25, "fire" = 30, "acid" = 18)

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/blink,
		/datum/action/xeno_action/activable/banish,
		/datum/action/xeno_action/recall,
		/datum/action/xeno_action/portal,
		/datum/action/xeno_action/timestop,
	)

