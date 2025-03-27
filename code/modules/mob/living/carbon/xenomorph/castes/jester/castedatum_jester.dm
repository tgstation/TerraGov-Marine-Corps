/datum/xeno_caste/jester
	caste_name = "Jester"
	display_name = "Jester"
	upgrade_name = ""
	caste_desc = "A temporally unstable xenomorph, capable of manipulating timelines."
	base_strain_type = /mob/living/carbon/xenomorph/jester
	caste_type_path = /mob/living/carbon/xenomorph/jester

	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "jester" //used to match appropriate wound overlays
	gib_anim = "Jester Gibs"
	gib_flick = "Jester Gibbed"

	// *** Melee Attacks *** //
	melee_damage = 25

	// *** Speed *** //
	speed = -0.8

	// *** Health & Plasma *** //
	plasma_max = 350
	plasma_gain = 35
	max_health = 330

	// *** Evolution *** //
	evolution_threshold = 225
	upgrade_threshold = TIER_TWO_THRESHOLD
	deevolves_to = /datum/xeno_caste/runner

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
	)

/datum/xeno_caste/jester/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/jester/primordial
	upgrade_name = "Primordial"
	caste_desc = "A unfathonably strange xeno that appears to be in seperate timelines at the same time."
	primordial_message = "The house always wins."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
	)