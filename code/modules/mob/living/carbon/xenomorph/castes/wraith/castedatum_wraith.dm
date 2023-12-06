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
	melee_damage = 20

	// *** Speed *** //
	speed = -1.25

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 25

	// *** Health *** //
	max_health = 260

	// *** Evolution *** //
	evolution_threshold = 225
	upgrade_threshold = TIER_TWO_THRESHOLD

	evolves_to = list(
		/mob/living/carbon/xenomorph/defiler,
		/mob/living/carbon/xenomorph/ravager,
		/mob/living/carbon/xenomorph/warlock,
	)
	deevolves_to = /mob/living/carbon/xenomorph/runner

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 20, FIRE = 30, ACID = 20)

	// *** Minimap Icon *** //
	minimap_icon = "wraith"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/blink,
		/datum/action/ability/activable/xeno/banish,
		/datum/action/ability/xeno_action/recall,
		/datum/action/ability/activable/xeno/rewind,
		/datum/action/ability/xeno_action/portal,
	)

/datum/xeno_caste/wraith/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/wraith/primordial
	upgrade_name = "Primordial"
	caste_desc = "A xenomorph that has perfected the manipulation of space and time. Its movements appear quick and distorted."
	primordial_message = "Mastery is achieved when \'telling time\' becomes \'telling time what to do\'."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/blink,
		/datum/action/ability/activable/xeno/banish,
		/datum/action/ability/xeno_action/recall,
		/datum/action/ability/xeno_action/portal,
		/datum/action/ability/activable/xeno/rewind,
		/datum/action/ability/xeno_action/timestop,
	)

