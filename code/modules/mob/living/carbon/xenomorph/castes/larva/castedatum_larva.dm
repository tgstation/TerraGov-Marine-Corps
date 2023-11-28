/datum/xeno_caste/larva
	caste_name = "Larva"
	display_name = "Bloody Larva"
	upgrade_name = ""
	caste_desc = "D'awwwww, so cute!"
	caste_type_path = /mob/living/carbon/xenomorph/larva
	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "larva" //used to match appropriate wound overlays

	gib_anim = "larva_gib_corpse"
	gib_flick = "larva_gib"

	// *** Melee Attacks *** //
	melee_damage = 0

	// *** Speed *** //
	speed = -1.6

	// *** Plasma *** //
	plasma_gain = 1

	// *** Health *** //
	max_health = 50
	crit_health = -25

	// *** Evolution *** //
	evolution_threshold = 50
	evolves_to = list(
		/mob/living/carbon/xenomorph/drone,
		/mob/living/carbon/xenomorph/runner,
		/mob/living/carbon/xenomorph/sentinel,
		/mob/living/carbon/xenomorph/defender,
		/mob/living/carbon/xenomorph/baneling,
	)

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_INNATE_HEALING
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_RIDE_CRUSHER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	// *** Minimap Icon *** //
	minimap_icon = "larva"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/xeno_action/xenohide,
	)

	// *** Vent Crawl Parameters *** //
	vent_enter_speed = LARVA_VENT_CRAWL_TIME
	vent_exit_speed = LARVA_VENT_CRAWL_TIME
	silent_vent_crawl = TRUE

/datum/xeno_caste/larva/young
	upgrade = XENO_UPGRADE_INVALID

