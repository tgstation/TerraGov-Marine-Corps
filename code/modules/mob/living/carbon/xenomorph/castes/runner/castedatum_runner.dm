/datum/xeno_caste/runner
	caste_name = "Runner"
	display_name = "Runner"
	upgrade_name = ""
	caste_desc = "A fast, four-legged terror. Weak in sustained combat."
	caste_type_path = /mob/living/carbon/xenomorph/runner
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "runner" //used to match appropriate wound overlays

	gib_anim = "gibbed-a-corpse-runner"
	gib_flick = "gibbed-a-runner"

	// *** Melee Attacks *** //
	melee_damage = 21
	attack_delay = 6

	// *** Speed *** //
	speed = -1.5

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 11

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	evolution_threshold = 100
	upgrade_threshold = TIER_ONE_THRESHOLD

	evolves_to = list(
		/mob/living/carbon/xenomorph/hunter,
		/mob/living/carbon/xenomorph/bull,
		/mob/living/carbon/xenomorph/wraith,
	)

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_RIDE_CRUSHER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 5, FIRE = 19, ACID = 5)

	// *** Minimap Icon *** //
	minimap_icon = "runner"

	// *** Abilities *** ///
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/xenohide,
		/datum/action/ability/xeno_action/evasion,
		/datum/action/ability/activable/xeno/pounce/runner,
	)

/datum/xeno_caste/runner/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/runner/primordial
	upgrade_name = "Primordial"
	caste_desc = "A sprinting terror of the hive. It looks ancient and menacing."
	primordial_message = "Nothing can outrun us. We are the swift death."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/xenohide,
		/datum/action/ability/xeno_action/evasion,
		/datum/action/ability/activable/xeno/pounce/runner,
		/datum/action/ability/activable/xeno/snatch,
	)
