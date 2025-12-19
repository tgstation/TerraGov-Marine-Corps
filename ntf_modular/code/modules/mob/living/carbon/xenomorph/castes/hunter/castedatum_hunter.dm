// Assassin strain
/datum/xeno_caste/hunter/assassin
	caste_type_path = /mob/living/carbon/xenomorph/hunter/assassin
	display_name = "Assassin"
	caste_name = "Assassin Hunter"
	upgrade_name = ""
	gib_anim = "Assassin Hunter Gibs"
	gib_flick = "Assassin Hunter Gibbed"
	upgrade = XENO_UPGRADE_BASETYPE
	caste_desc = "A fast, creeping death, light faintly shimmers on it's strange, light-bending carapace."

	// *** Speed *** //
	speed = -1.6

	// *** Plasma *** //
	plasma_max = 250
	plasma_gain = 23

	// *** Health *** //
	max_health = 300

	stealth_break_threshold = 18

	// *** Defense *** //
	soft_armor = list(MELEE = 40, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 0, BIO = 20, FIRE = 30, ACID = 20)

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/psychic_whisper,
		/datum/action/ability/xeno_action/psychic_influence,
		/datum/action/ability/activable/xeno/impregnate,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/devour,
		/datum/action/ability/activable/xeno/tail_stab,
		/datum/action/ability/activable/xeno/pounce/lunge,
		/datum/action/ability/xeno_action/stealth/phaseout,
		/datum/action/ability/activable/xeno/hunter_mark/assassin,
		/datum/action/ability/xeno_action/mirage,
		/datum/action/ability/xeno_action/displacement,
		/datum/action/ability/xeno_action/create_edible_jelly,
		/datum/action/ability/xeno_action/place_stew_pod,
		/datum/action/ability/xeno_action/xenohide,
	)

/datum/xeno_caste/hunter/assassin/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_PRIMO
	caste_desc = "A fast, creeping death, light faintly shimmers on it's strange, light-bending carapace. Shadows around seem to distort and cling to it."
	primordial_message = "They won't see us coming until it's too late. Let the slaughter begin."

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/psychic_whisper,
		/datum/action/ability/xeno_action/psychic_influence,
		/datum/action/ability/activable/xeno/impregnate,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/devour,
		/datum/action/ability/activable/xeno/tail_stab,
		/datum/action/ability/activable/xeno/pounce/lunge,
		/datum/action/ability/xeno_action/stealth/phaseout,
		/datum/action/ability/xeno_action/stealth/disguise,
		/datum/action/ability/activable/xeno/hunter_mark/assassin,
		/datum/action/ability/xeno_action/mirage,
		/datum/action/ability/xeno_action/displacement,
		/datum/action/ability/xeno_action/create_edible_jelly,
		/datum/action/ability/xeno_action/place_stew_pod,
		/datum/action/ability/xeno_action/xenohide,
	)
