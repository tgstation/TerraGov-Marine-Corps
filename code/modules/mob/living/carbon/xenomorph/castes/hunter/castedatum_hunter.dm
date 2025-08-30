/datum/xeno_caste/hunter
	caste_name = "Hunter"
	display_name = "Hunter"
	upgrade_name = ""
	caste_desc = "A fast, powerful front line combatant."
	base_strain_type = /mob/living/carbon/xenomorph/hunter
	caste_type_path = /mob/living/carbon/xenomorph/hunter

	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "hunter" //used to match appropriate wound overlays
	gib_anim = "Hunter Gibs"
	gib_flick = "Hunter Gibbed"

	// *** Melee Attacks *** //
	melee_damage = 25
	melee_ap = 5
	attack_delay = 7

	// *** Speed *** //
	speed = -1.4
	weeds_speed_mod = -0.1

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 20

	// *** Health *** //
	max_health = 310

	// *** Evolution *** //
	evolution_threshold = 225
	upgrade_threshold = TIER_TWO_THRESHOLD

	deevolves_to = /datum/xeno_caste/runner

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_MUTATIONS_ALLOWED
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 55, BULLET = 35, LASER = 35, ENERGY = 35, BOMB = 0, BIO = 20, FIRE = 30, ACID = 20)

	// *** Stealth ***
	stealth_break_threshold = 25

	// *** Minimap Icon *** //
	minimap_icon = "hunter"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/silence,
		/datum/action/ability/activable/xeno/pounce,
		/datum/action/ability/xeno_action/stealth,
		/datum/action/ability/activable/xeno/hunter_mark,
		/datum/action/ability/xeno_action/psychic_trace,
		/datum/action/ability/xeno_action/mirage,
	)

	// *** Vent Crawl Parameters *** //
	vent_enter_speed = HUNTER_VENT_CRAWL_TIME
	vent_exit_speed = HUNTER_VENT_CRAWL_TIME
	silent_vent_crawl = TRUE

	mutations = list(
		/datum/mutation_upgrade/shell/fleeting_mirage,
		/datum/mutation_upgrade/spur/debilitating_strike,
		/datum/mutation_upgrade/veil/one_target
	)

/datum/xeno_caste/hunter/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/hunter/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_PRIMO
	caste_desc = "A silent but deadly killing machine. It looks frighteningly powerful."
	primordial_message = "We are the ultimate predator. Let the hunt begin."

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/silence,
		/datum/action/ability/activable/xeno/pounce,
		/datum/action/ability/xeno_action/stealth,
		/datum/action/ability/xeno_action/stealth/disguise,
		/datum/action/ability/activable/xeno/hunter_mark,
		/datum/action/ability/xeno_action/psychic_trace,
		/datum/action/ability/xeno_action/mirage,
	)


/////

/datum/xeno_caste/hunter/weapon_x
	display_name = "Weapon X"
	upgrade_name = ""
	caste_desc = "A fast, powerful creature. It has some kind of machinery attached to its head."
	caste_type_path = /mob/living/carbon/xenomorph/hunter/weapon_x
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 26

	// *** Speed *** //
	speed = -1.7

	// *** Health *** //
	max_health = 330
	regen_delay = 5 SECONDS
	regen_ramp_amount = 0.03
	sunder_recover = 1

	// *** Flags *** //
	caste_flags = CASTE_INNATE_PLASMA_REGEN|CASTE_HIDE_IN_STATUS|CASTE_EXCLUDE_STRAINS
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_HEAL_WITHOUT_QUEEN
	caste_traits = list(TRAIT_CAN_VENTCRAWL, TRAIT_INNATE_HEALING)

	// *** Defense *** //
	soft_armor = list(MELEE = 65, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 20, BIO = 30, FIRE = 50, ACID = 30)

/datum/xeno_caste/hunter/weapon_x/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/hunter/weapon_x/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_PRIMO
	caste_desc = "A silent but deadly killing machine. It looks frighteningly powerful."
	primordial_message = "We are the ultimate predator. Let the hunt begin."

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/silence,
		/datum/action/ability/activable/xeno/pounce,
		/datum/action/ability/xeno_action/stealth,
		/datum/action/ability/xeno_action/stealth/disguise,
		/datum/action/ability/activable/xeno/hunter_mark,
		/datum/action/ability/xeno_action/psychic_trace,
		/datum/action/ability/xeno_action/mirage,
	)
