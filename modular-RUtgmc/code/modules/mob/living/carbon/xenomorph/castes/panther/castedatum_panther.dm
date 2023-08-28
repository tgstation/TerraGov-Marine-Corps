/datum/xeno_caste/panther
	caste_name = "Panther"
	display_name = "Panther"
	upgrade_name = ""
	caste_desc = "Run fast, hit hard, die young."
	caste_type_path = /mob/living/carbon/xenomorph/panther
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "panther" //used to match appropriate wound overlays

	gib_anim = "gibbed-a-corpse-runner"
	gib_flick = "gibbed-a-runner"

	// *** Melee Attacks *** //
	melee_damage = 20
	attack_delay = 6

	// *** Speed *** //
	speed = -1.3

	// *** Plasma *** //
	plasma_max = 105
	plasma_gain = 0
	plasma_regen_limit = 0.2
	plasma_icon_state = "panther"

	// *** Health *** //
	max_health = 220

	// *** Evolution *** //
	evolution_threshold = 180
	upgrade_threshold = TIER_TWO_YOUNG_THRESHOLD

	evolves_to = list(/mob/living/carbon/xenomorph/ravager)
	deevolves_to = /mob/living/carbon/xenomorph/runner

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_LEADER|CASTE_CAN_RIDE_CRUSHER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 14, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 5, ACID = 0)

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_SMALL
	pounce_delay = 13 SECONDS

	// *** Minimap Icon *** //
	minimap_icon = "panther"

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain/panther,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/activable/pounce/panther,
		/datum/action/xeno_action/activable/adrenalinejump,
		/datum/action/xeno_action/evasive_maneuvers,
		/datum/action/xeno_action/tearingtail,
		/datum/action/xeno_action/select_reagent/panther,
	)

/datum/xeno_caste/panther/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/panther/mature
	upgrade_name = "Mature"
	caste_desc = "Run fast, hit hard, die young. I just need adrenaline."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -1.3

	// *** Plasma *** //
	plasma_max = 120

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 16, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 3, FIRE = 10, ACID = 3)

	// *** Ranged Attack *** //
	pounce_delay = 13 SECONDS

/datum/xeno_caste/panther/elder
	upgrade_name = "Elder"
	caste_desc = "Run fast, hit hard, die young. All I need, adrenaline."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -1.4

	// *** Plasma *** //
	plasma_max = 135

	// *** Health *** //
	max_health = 260

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 18, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 0, BIO = 5, FIRE = 15, ACID = 5)

	// *** Ranged Attack *** //
	pounce_delay = 13 SECONDS

/datum/xeno_caste/panther/ancient
	upgrade_name = "Ancient"
	caste_desc = "Run fast, hit hard, it's time to do or die."
	ancient_message = "We are faster than the fastest assassin of all time. Now we can't die young."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -1.5

	// *** Plasma *** //
	plasma_max = 150

	// *** Health *** //
	max_health = 280

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 20, BULLET = 19, LASER = 19, ENERGY = 19, BOMB = 0, BIO = 7, FIRE = 19, ACID = 7)

	// *** Ranged Attack *** //
	pounce_delay = 13 SECONDS

/datum/xeno_caste/panther/primordial
	upgrade_name = "Primordial"
	caste_desc = "Run fast, hit hard, die never."
	primordial_message = "We will never die."
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -1.5

	// *** Plasma *** //
	plasma_max = 150

	// *** Health *** //
	max_health = 280

	// *** Defense *** //
	soft_armor = list(MELEE = 20, BULLET = 19, LASER = 19, ENERGY = 19, BOMB = 0, BIO = 7, FIRE = 19, ACID = 7)

	// *** Ranged Attack *** //
	pounce_delay = 13 SECONDS

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain/panther,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/activable/pounce/panther,
		/datum/action/xeno_action/activable/adrenalinejump,
		/datum/action/xeno_action/evasive_maneuvers,
		/datum/action/xeno_action/tearingtail,
		/datum/action/xeno_action/select_reagent/panther,
		/datum/action/xeno_action/adrenaline_rush,
	)
