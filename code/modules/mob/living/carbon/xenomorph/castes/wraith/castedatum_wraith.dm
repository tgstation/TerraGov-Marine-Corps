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
		/mob/living/carbon/xenomorph/defiler,
		/mob/living/carbon/xenomorph/ravager,
	)
	deevolves_to = /mob/living/carbon/xenomorph/runner

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING

	// *** Defense *** //
	soft_armor = list(MELEE = 25, BULLET = 25, LASER = 5, ENERGY = 5, BOMB = 0, BIO = 10, FIRE = 15, ACID = 10)

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
		/datum/action/xeno_action/activable/rewind,
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
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 15, FIRE = 20, ACID = 15)


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
	soft_armor = list(MELEE = 35, BULLET = 35, LASER = 15, ENERGY = 15, BOMB = 0, BIO = 18, FIRE = 25, ACID = 18)


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
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 18, FIRE = 30, ACID = 18)

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
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 18, FIRE = 30, ACID = 18)

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/blink,
		/datum/action/xeno_action/activable/banish,
		/datum/action/xeno_action/recall,
		/datum/action/xeno_action/portal,
		/datum/action/xeno_action/activable/rewind,
		/datum/action/xeno_action/timestop,
	)

