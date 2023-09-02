/datum/xeno_caste/gorger
	caste_name = "Gorger"
	display_name = "Gorger"
	upgrade_name = ""
	caste_desc = "A frightening looking, bulky alien creature that drips with a familiar red fluid."
	caste_type_path = /mob/living/carbon/xenomorph/gorger
	primordial_message = "There is nothing we can't withstand."

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "gorger" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.6
	weeds_speed_mod = 0.2

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 0
	plasma_regen_limit = 0
	plasma_icon_state = "fury"

	// *** Health *** //
	max_health = 500

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD

	deevolves_to = list(/mob/living/carbon/xenomorph/warrior, /mob/living/carbon/xenomorph/hivelord)

	// *** Flags *** //
	caste_flags = CASTE_INNATE_PLASMA_REGEN|CASTE_PLASMADRAIN_IMMUNE|CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_LEADER
	caste_traits = null

	// *** Defense *** //
	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 10, BIO = 15, FIRE = 15, ACID = 15)

	// *** Minimap Icon *** //
	minimap_icon = "gorger"

	// *** Gorger Abilities *** //
	overheal_max = 250
	drain_plasma_gain = 30
	carnage_plasma_gain = 35
	feast_plasma_drain = 20

	actions = list(
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

/datum/xeno_caste/gorger/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/gorger/primordial
	upgrade_name = "Primordial"
	caste_desc = "Being within mere eyeshot of this hulking monstrosity fills you with a deep, unshakeable sense of unease. You are unsure if you can even harm it."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
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
