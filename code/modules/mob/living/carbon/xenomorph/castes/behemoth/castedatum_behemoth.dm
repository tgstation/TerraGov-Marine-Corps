/datum/xeno_caste/behemoth
	caste_name = "Behemoth"
	display_name = "Behemoth"
	upgrade_name = ""
	caste_desc = "Behemoths are known to like rocks. Perhaps we should give them one!"
	caste_type_path = /mob/living/carbon/xenomorph/behemoth
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "behemoth"

	// *** Melee Attacks *** //
	melee_damage = 26

	// *** Speed *** //
	speed = -0.2
	weeds_speed_mod = -0.1

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 20

	// *** Health *** //
	max_health = 750

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/bull

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_IS_STRONG|CASTE_STAGGER_RESISTANT
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	caste_traits = null

	// *** Defense *** //
	soft_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 50, BIO = 50, FIRE = 50, ACID = 50)
	hard_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	// *** Minimap Icon *** //
	minimap_icon = "behemoth"

	// *** Abilities *** ///
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/ready_charge/behemoth_roll,
		/datum/action/ability/activable/xeno/landslide,
		/datum/action/ability/activable/xeno/earth_riser,
		/datum/action/ability/activable/xeno/seismic_fracture,
	)

/datum/xeno_caste/behemoth/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/behemoth/primordial
	upgrade_name = "Primordial"
	primordial_message = "In the ancient embrace of the earth, we have honed our art to perfection. Our might will crush the feeble pleas of our enemies before they can escape their lips."
	upgrade = XENO_UPGRADE_PRIMO

	// *** Wrath *** //
	wrath_max = 750

	// *** Abilities *** ///
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/ready_charge/behemoth_roll,
		/datum/action/ability/activable/xeno/landslide,
		/datum/action/ability/activable/xeno/earth_riser,
		/datum/action/ability/activable/xeno/seismic_fracture,
		/datum/action/ability/xeno_action/primal_wrath,
	)
