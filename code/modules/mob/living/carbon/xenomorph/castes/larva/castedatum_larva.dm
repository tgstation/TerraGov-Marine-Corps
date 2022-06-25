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
	)

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_INNATE_HEALING
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_VENT_CRAWL

	// *** Defense *** //
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	// *** Minimap Icon *** //
	minimap_icon = "larva"

	// *** Abilities *** //
	actions = list\(
		/datum/action/xeno_action/show_hivestatus,
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/xenohide,
	)

	// *** Vent Crawl Parameters *** //
	vent_enter_speed = LARVA_VENT_CRAWL_TIME
	vent_exit_speed = LARVA_VENT_CRAWL_TIME
	silent_vent_crawl = TRUE

/datum/xeno_caste/larva/young
	upgrade = XENO_UPGRADE_INVALID

