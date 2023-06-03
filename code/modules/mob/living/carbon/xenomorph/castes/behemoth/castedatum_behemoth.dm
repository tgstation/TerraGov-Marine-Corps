/datum/xeno_caste/behemoth
	caste_name = "Behemoth"
	display_name = "Behemoth"
	upgrade_name = ""
	caste_type_path = /mob/living/carbon/xenomorph/behemoth
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "behemoth" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 25

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 175
	plasma_gain = 17

	// *** Health *** //
	max_health = 425

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/warrior

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_IS_STRONG|CASTE_STAGGER_RESISTANT
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	caste_traits = null

	// *** Defense *** //
	sunder_max = 50
	sunder_recover = 1.0
	soft_armor = list(MELEE = 45, BULLET = 45, LASER = 45, ENERGY = 45, BOMB = 100, BIO = 45, FIRE = 45, ACID = 45)
	hard_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	// *** Minimap Icon *** //
	minimap_icon = "crusher"

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/ready_charge/behemoth_roll,
		/datum/action/xeno_action/activable/behemoth/landslide,
		/datum/action/xeno_action/activable/behemoth/earth_riser,
		/datum/action/xeno_action/activable/behemoth/seismic_fracture,
	)

/datum/xeno_caste/behemoth/on_caste_applied(mob/xenomorph)
	. = ..()
	xenomorph.AddElement(/datum/element/ridable, /datum/component/riding/creature/behemoth)
	xenomorph.RegisterSignal(xenomorph, COMSIG_GRAB_SELF_ATTACK, TYPE_PROC_REF(/mob/living/carbon/xenomorph, grabbed_self_attack))

/datum/xeno_caste/behemoth/on_caste_removed(mob/xenomorph)
	. = ..()
	xenomorph.RemoveElement(/datum/element/ridable, /datum/component/riding/creature/behemoth)
	xenomorph.UnregisterSignal(xenomorph, COMSIG_GRAB_SELF_ATTACK)


/datum/xeno_caste/behemoth/young
	upgrade_name = "Young"
	upgrade = XENO_UPGRADE_ZERO


/datum/xeno_caste/behemoth/mature
	upgrade_name = "Mature"
	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 26

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 20

	// *** Health *** //
	max_health = 450

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 110, BIO = 50, FIRE = 50, ACID = 50)
	hard_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)


/datum/xeno_caste/behemoth/elder
	upgrade_name = "Elder"
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 27

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 225
	plasma_gain = 22

	// *** Health *** //
	max_health = 375

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 55, BULLET = 55, LASER = 55, ENERGY = 55, BOMB = 120, BIO = 55, FIRE = 55, ACID = 55)
	hard_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)


/datum/xeno_caste/behemoth/ancient
	upgrade_name = "Ancient"
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 28

	// *** Plasma *** //
	plasma_max = 250
	plasma_gain = 25

	// *** Health *** //
	max_health = 475

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 130, BIO = 60, FIRE = 60, ACID = 60)
	hard_armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)


/datum/xeno_caste/behemoth/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 30

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 250
	plasma_gain = 25

	// *** Health *** //
	max_health = 500

	// *** Defense *** //
	sunder_max = 50
	sunder_recover = 1.0
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 130, BIO = 60, FIRE = 60, ACID = 60)
	hard_armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/ready_charge/behemoth_roll,
		/datum/action/xeno_action/activable/behemoth/landslide,
		/datum/action/xeno_action/activable/behemoth/earth_riser,
		/datum/action/xeno_action/activable/behemoth/seismic_fracture,
		/datum/action/xeno_action/primal_wrath,
	)
