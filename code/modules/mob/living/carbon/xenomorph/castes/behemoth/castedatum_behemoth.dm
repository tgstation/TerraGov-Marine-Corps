/datum/xeno_caste/behemoth
	caste_name = "Behemoth"
	display_name = "Behemoth"
	upgrade_name = ""
	caste_desc = "Behemoths are known to like rocks. Perhaps we should give them one!"
	caste_type_path = /mob/living/carbon/xenomorph/behemoth
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_icon = 'icons/Xeno/wound_overlays_3x3.dmi'
	wound_type = "behemoth"

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = 0.4
	weeds_speed_mod = -0.1

	// *** Plasma *** //
	plasma_max = 175
	plasma_gain = 17

	// *** Health *** //
	max_health = 625

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/warrior

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_IS_STRONG|CASTE_STAGGER_RESISTANT
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	sunder_recover = 1.0
	soft_armor = list(MELEE = 35, BULLET = 35, LASER = 35, ENERGY = 35, BOMB = 100, BIO = 100, FIRE = 35, ACID = 35)
	hard_armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	// *** Minimap Icon *** //
	minimap_icon = "crusher"

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		//datum/action/xeno_action/behemoth_roll,
		/datum/action/xeno_action/activable/landslide,
		/datum/action/xeno_action/activable/earth_riser,
		/datum/action/xeno_action/activable/seismic_fracture,
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

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 20

	// *** Health *** //
	max_health = 650

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 110, BIO = 110, FIRE = 40, ACID = 40)
	hard_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)


/datum/xeno_caste/behemoth/elder
	upgrade_name = "Elder"
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 21

	// *** Speed *** //
	speed = 0.3

	// *** Plasma *** //
	plasma_max = 225
	plasma_gain = 22

	// *** Health *** //
	max_health = 675

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 45, BULLET = 45, LASER = 45, ENERGY = 45, BOMB = 120, BIO = 120, FIRE = 45, ACID = 45)
	hard_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)


/datum/xeno_caste/behemoth/ancient
	upgrade_name = "Ancient"
	upgrade = XENO_UPGRADE_THREE
	ancient_message = "Let the land quake in fear as it is torn asunder."

	// *** Plasma *** //
	plasma_max = 250
	plasma_gain = 25

	// *** Health *** //
	max_health = 700

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 130, BIO = 130, FIRE = 50, ACID = 50)
	hard_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)


/datum/xeno_caste/behemoth/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_FOUR
	primordial_message = "We are nature's wrath made manifest."
	wrath_max = 700

	// *** Melee Attacks *** //
	melee_damage = 21

	// *** Speed *** //
	speed = 0.3
	weeds_speed_mod = -0.1

	// *** Plasma *** //
	plasma_max = 250
	plasma_gain = 25

	// *** Health *** //
	max_health = 700

	// *** Defense *** //
	sunder_recover = 1.0
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 130, BIO = 130, FIRE = 50, ACID = 50)
	hard_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		//datum/action/xeno_action/behemoth_roll,
		/datum/action/xeno_action/activable/landslide,
		/datum/action/xeno_action/activable/earth_riser,
		/datum/action/xeno_action/activable/seismic_fracture,
		/datum/action/xeno_action/primal_wrath,
	)
