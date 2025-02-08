/datum/xeno_caste/runner
	caste_name = "Runner"
	display_name = "Runner"
	upgrade_name = ""
	caste_desc = "A fast, four-legged terror. Weak in sustained combat."
	base_strain_type = /mob/living/carbon/xenomorph/runner
	caste_type_path = /mob/living/carbon/xenomorph/runner
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "runner" //used to match appropriate wound overlays

	gib_anim = "gibbed-a-corpse-runner"
	gib_flick = "gibbed-a-runner"

	// *** Melee Attacks *** //
	melee_damage = 23
	attack_delay = 6

	// *** Speed *** //
	speed = -1.4

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 11

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	evolution_threshold = 100
	upgrade_threshold = TIER_ONE_THRESHOLD

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_RIDE_CRUSHER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 5, FIRE = 20, ACID = 5)

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


/datum/xeno_caste/runner/acid
	caste_type_path = /mob/living/carbon/xenomorph/runner/acid
	upgrade_name = ""
	caste_name = "Acid Runner"
	display_name = "Acidder"
	upgrade = XENO_UPGRADE_BASETYPE
	caste_desc = "A fast, four-legged terror. It got acid covered all over it."

	// -11 melee damage. Attacking does a second instance of melee damage as burn damage.
	melee_damage = 12

	// Gain armor (+10) for less speed (0.2).
	speed = -1.2
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 10, BIO = 15, FIRE = 30, ACID = 15)

	// Gets acid blood.
	caste_flags = CASTE_ACID_BLOOD|CASTE_EVOLUTION_ALLOWED

	// Loses pounce and evasion for acid-themed abilities.
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid/acid_runner,
		/datum/action/ability/xeno_action/xenohide,
	)

/datum/xeno_caste/runner/acid/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/runner/acid/primordial
	upgrade_name = "Primordial"
	caste_desc = "An agile acid-wielding predator. Its speed and corrosive touch spell doom for any who stand in its way."
	primordial_message = "With our nimble movements and acidic touch, we close in and dissolve all resistance."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid/acid_runner,
		/datum/action/ability/activable/xeno/acidic_missile,
		/datum/action/ability/xeno_action/xenohide,
	)
