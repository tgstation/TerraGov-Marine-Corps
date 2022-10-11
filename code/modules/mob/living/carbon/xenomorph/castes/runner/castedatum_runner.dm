/datum/xeno_caste/runner
	caste_name = "Runner"
	display_name = "Runner"
	upgrade_name = ""
	caste_desc = "A fast, four-legged terror, but weak in sustained combat."
	caste_type_path = /mob/living/carbon/xenomorph/runner
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "runner" //used to match appropriate wound overlays

	gib_anim = "gibbed-a-corpse-runner"
	gib_flick = "gibbed-a-runner"

	// *** Melee Attacks *** //
	melee_damage = 17
	attack_delay = 6

	savage_cooldown = 30 SECONDS

	// *** Speed *** //
	speed = -1.3

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 5

	// *** Health *** //
	max_health = 175

	// *** Evolution *** //
	evolution_threshold = 80
	upgrade_threshold = TIER_ONE_YOUNG_THRESHOLD

	evolves_to = list(
		/mob/living/carbon/xenomorph/hunter,
		/mob/living/carbon/xenomorph/bull,
		/mob/living/carbon/xenomorph/wraith,
	)

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING|CASTE_CAN_RIDE_CRUSHER

	// *** Defense *** //
	soft_armor = list(MELEE = 14, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, "rad" = 0, FIRE = 5, ACID = 0)

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_SMALL
	pounce_delay = 13 SECONDS

	// *** Minimap Icon *** //
	minimap_icon = "runner"

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/activable/pounce,
		/datum/action/xeno_action/toggle_savage,
		/datum/action/xeno_action/evasion,
	)

/datum/xeno_caste/runner/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/runner/mature
	upgrade_name = "Mature"
	caste_desc = "A fast, four-legged terror, but weak in sustained combat. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	savage_cooldown = 30 SECONDS

	// *** Speed *** //
	speed = -1.3

	// *** Plasma *** //
	plasma_max = 175
	plasma_gain = 7

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 16, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 3, "rad" = 3, FIRE = 10, ACID = 3)

	// *** Ranged Attack *** //
	pounce_delay = 13 SECONDS

/datum/xeno_caste/runner/elder
	upgrade_name = "Elder"
	caste_desc = "A fast, four-legged terror, but weak in sustained combat. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 21

	savage_cooldown = 30 SECONDS

	// *** Speed *** //
	speed = -1.4

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 9

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 18, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 0, BIO = 5, "rad" = 5, FIRE = 15, ACID = 5)

	// *** Ranged Attack *** //
	pounce_delay = 13 SECONDS

/datum/xeno_caste/runner/ancient
	upgrade_name = "Ancient"
	caste_desc = "Not what you want to run into in a dark alley. It looks extremely deadly."
	ancient_message = "We are the fastest assassin of all time. Our speed is unmatched."
	upgrade = XENO_UPGRADE_THREE

	savage_cooldown = 30 SECONDS

	// *** Melee Attacks *** //
	melee_damage = 21

	// *** Speed *** //
	speed = -1.5

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 11

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 20, BULLET = 19, LASER = 19, ENERGY = 19, BOMB = 0, BIO = 7, "rad" = 7, FIRE = 19, ACID = 7)

	// *** Ranged Attack *** //
	pounce_delay = 13 SECONDS

/datum/xeno_caste/runner/primordial
	upgrade_name = "Primordial"
	caste_desc = "A sprinting terror of the hive. It looks ancient and menacing."
	primordial_message = "Nothing can outrun us. We are the swift death."
	upgrade = XENO_UPGRADE_FOUR

	savage_cooldown = 30 SECONDS

	// *** Melee Attacks *** //
	melee_damage = 21

	// *** Speed *** //
	speed = -1.5

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 11

	// *** Health *** //
	max_health = 240

	// *** Defense *** //
	soft_armor = list(MELEE = 20, BULLET = 19, LASER = 19, ENERGY = 19, BOMB = 0, BIO = 7, "rad" = 7, FIRE = 19, ACID = 7)

	// *** Ranged Attack *** //
	pounce_delay = 13 SECONDS

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/activable/pounce,
		/datum/action/xeno_action/toggle_savage,
		/datum/action/xeno_action/evasion,
		/datum/action/xeno_action/activable/snatch,
	)
