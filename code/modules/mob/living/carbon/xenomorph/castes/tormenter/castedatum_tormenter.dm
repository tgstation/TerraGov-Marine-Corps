/datum/xeno_caste/tormenter
	caste_name = "Tormenter"
	display_name = "Tormenter"
	upgrade_name = ""
	caste_desc = "A dark, slender creature with scythe-like claws."

	caste_type_path = /mob/living/carbon/xenomorph/tormenter

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "defiler" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Tackle *** //
	tackle_damage = 28

	// *** Speed *** //
	speed = -0.7

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 14

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 250

	deevolves_to = /mob/living/carbon/xenomorph/wraith

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_VENT_CRAWL
	// *** Defense *** //
	soft_armor = list("melee" = 30, "bullet" = 25, "laser" = 15, "energy" = 30, "bomb" = XENO_BOMB_RESIST_0, "bio" = 30, "rad" = 30, "fire" = 25, "acid" = 30)

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/headbite,
		/datum/action/xeno_action/activable/devour,
		/datum/action/xeno_action/activable/nightfall,
		/datum/action/xeno_action/activable/deception,
	)


/datum/xeno_caste/tormenter/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/tormenter/mature
	upgrade_name = "Mature"
	caste_desc = "A dark, slender creature with scythe-like claws. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Tackle *** //
	tackle_damage = 28

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 17

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = 750

	// *** Defense *** //
	soft_armor = list("melee" = 35, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_0, "bio" = 35, "rad" = 35, "fire" = 30, "acid" = 35)


/datum/xeno_caste/tormenter/elder
	upgrade_name = "Elder"
	caste_desc = "A dark, slender creature with scythe-like claws. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 26

	// *** Tackle *** //
	tackle_damage = 32

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 550
	plasma_gain = 19

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = 1750

	// *** Defense *** //
	soft_armor = list("melee" = 38, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = XENO_BOMB_RESIST_0, "bio" = 38, "rad" = 38, "fire" = 35, "acid" = 38)


/datum/xeno_caste/tormenter/ancient
	upgrade_name = "Ancient"
	caste_desc = "Being within mere eyeshot of this hulking, dripping monstrosity fills you with a deep, unshakeable sense of unease."
	ancient_message = "We are the ultimate illusionist."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 26

	// *** Tackle *** //
	tackle_damage = 32

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 575
	plasma_gain = 20

	// *** Health *** //
	max_health = 375

	// *** Evolution *** //
	upgrade_threshold = 2750

	// *** Defense *** //
	soft_armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = XENO_BOMB_RESIST_0, "bio" = 40, "rad" = 40, "fire" = 40, "acid" = 40)
