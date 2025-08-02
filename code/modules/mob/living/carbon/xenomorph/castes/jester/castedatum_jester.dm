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
	melee_damage = 20

	// *** Speed *** //
	speed = -0.8

	// *** Health & Plasma *** //
	plasma_max = 450
	plasma_gain = 40
	max_health = 400
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 30, BIO = 50, FIRE = 55, ACID = 50)

	// *** Evolution *** //
	evolution_threshold = 225
	upgrade_threshold = TIER_TWO_THRESHOLD
	deevolves_to = /datum/xeno_caste/runner

	// *** Carrier Abilities *** //
	huggers_max = 8
	hugger_delay = 1.25 SECONDS

	// *** Ranged Attack *** //
	spit_delay = 0.5 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/medium)

	acid_spray_duration = 10 SECONDS
	acid_spray_damage_on_hit = 45
	acid_spray_damage = 20
	acid_spray_structure_damage = 45
	acid_spray_range = 5

	// *** Other Misc Stuff *** //
	feast_plasma_drain = 20


	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/xeno_action/chips,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/patron_of_the_stars,
		/datum/action/ability/activable/xeno/deck_of_disaster,
		/datum/action/ability/xeno_action/draw,
		/datum/action/ability/xeno_action/tarot_deck,
	)

/datum/xeno_caste/jester/on_caste_applied(mob/xenomorph)
	. = ..()
	var/mob/living/carbon/xenomorph/jester/xeno = xenomorph
	//Delayed for the dual purpose of a small grace period & because abilites havent been granted at this point
	addtimer(CALLBACK(xeno, TYPE_PROC_REF(/mob/living/carbon/xenomorph/jester, hud_set_gamble_bar)), 15 SECONDS)

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
		/datum/action/ability/xeno_action/chips,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/patron_of_the_stars,
		/datum/action/ability/activable/xeno/deck_of_disaster,
		/datum/action/ability/xeno_action/draw,
		/datum/action/ability/xeno_action/tarot_deck,
		/datum/action/ability/xeno_action/doppelganger,
	)
