/datum/xeno_caste/panther
	caste_name = "Panther"
	display_name = "Panther"
	upgrade_name = ""
	caste_desc = "A fast, four-legged terror, adept at capturing prey."
	caste_type_path = /mob/living/carbon/xenomorph/panther
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "runner" //used to match appropriate wound overlays

	gib_anim = "gibbed-a-corpse-runner"
	gib_flick = "gibbed-a-runner"

	// *** Melee Attacks *** //
	melee_damage = 12
	attack_delay = 6


	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 2

	// *** Health *** //
	max_health = 210

	// *** Evolution *** //
	evolution_threshold = 80
	upgrade_threshold = 50

	evolves_to = list(/mob/living/carbon/xenomorph/hunter, /mob/living/carbon/xenomorph/bull, /mob/living/carbon/xenomorph/runner)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 5, "bomb" = XENO_BOMB_RESIST_0, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 0)

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_PANTHER
	pounce_delay = 35.0 SECONDS

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/activable/pounce/panther,
		/datum/action/xeno_action/activable/neurotox_sting/panther,
		)

/datum/xeno_caste/panther/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/panther/mature
	upgrade_name = "Mature"
	caste_desc = "A fast, four-legged terror, adept at capturing prey. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 3

	// *** Health *** //
	max_health = 230

	// *** Evolution *** //
	upgrade_threshold = 100

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 3, "rad" = 3, "fire" = 15, "acid" = 3)

	// *** Ranged Attack *** //
	pounce_delay = 35.0 SECONDS

/datum/xeno_caste/panther/elder
	upgrade_name = "Elder"
	caste_desc = "A fast, four-legged terror, adept at capturing prey. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 16


	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -1.2

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 3

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Defense *** //
	soft_armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = XENO_BOMB_RESIST_0, "bio" = 5, "rad" = 5, "fire" = 20, "acid" = 5)

	// *** Ranged Attack *** //
	pounce_delay = 45.0 SECONDS

/datum/xeno_caste/panther/ancient
	upgrade_name = "Ancient"
	caste_desc = "The colony only falls silent when a predator is on the prowl."
	ancient_message = "We are the apex predator, all will fall by fang or claw."
	upgrade = XENO_UPGRADE_THREE
	wound_type = "runner" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 16


	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -1.4

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 3

	// *** Health *** //
	max_health = 270

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Defense *** //
	soft_armor = list("melee" = 24, "bullet" = 24, "laser" = 24, "energy" = 124, "bomb" = XENO_BOMB_RESIST_0, "bio" = 7, "rad" = 7, "fire" = 24, "acid" = 7)

	// *** Ranged Attack *** //
	pounce_delay = 35.0 SECONDS
