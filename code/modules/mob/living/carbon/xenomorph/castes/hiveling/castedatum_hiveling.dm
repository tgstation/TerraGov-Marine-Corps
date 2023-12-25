/datum/xeno_caste/hiveling
	caste_name = "Hiveling"
	display_name = "Hiveling"
	upgrade_name = ""
	caste_desc = ""

	caste_type_path = /mob/living/carbon/xenomorph/hiveling

	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 0

	// *** Speed *** //
	speed = 0.5
	weeds_speed_mod = 0

	// *** Plasma *** //
	plasma_max = 350 // 25 per tile weed + 75 per weed sac, 100 per resin structure
	plasma_gain = 35

	// *** Health *** //
	max_health = 150

	// *** Flags *** //
	caste_flags = CASTE_DO_NOT_ALERT_LOW_LIFE|CASTE_IS_A_MINION|CASTE_IS_BUILDER
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA
	caste_traits = null

	// *** Defense *** //
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	minimap_icon = "xenominion"

	// *** Abilities *** //
	resin_max_range = 1 //Hiveling can place resin structures from 1 tile away

	actions = list(
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/activable/xeno/secrete_resin/hiveling, //creates structures that start at 75 health on adjacent tiles
		/datum/action/ability/activable/xeno/weedwalker //plant weeds while moving ala auto
	)
