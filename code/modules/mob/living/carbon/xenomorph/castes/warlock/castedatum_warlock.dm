/datum/xeno_caste/shrike
	caste_name = "Warlock"
	display_name = "Warlock"
	upgrade_name = ""
	caste_desc = "A powerfully psychic xeno. The Warlock devestates the enemies of the hive with it's psychic might, but is physically very frail."
	caste_type_path = /mob/living/carbon/xenomorph/warlock

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "overmind"
	melee_damage = 20
	speed = -0.3
	plasma_max = 750
	plasma_gain = 30
	max_health = 325
	evolution_threshold = 180
	upgrade_threshold = TIER_TWO_YOUNG_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/wraith
	caste_flags = CASTE_IS_INTELLIGENT
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 20, BIO = 10, FIRE = 30, ACID = 10)
	minimap_icon = "xenoshrike"
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/plant_weeds, //just while testing
		/datum/action/xeno_action/activable/psy_crush,
		/datum/action/xeno_action/activable/psy_blast,
	)

/datum/xeno_caste/shrike/young
	upgrade_name = "Young"
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/shrike/mature
	upgrade_name = "Mature"
	caste_desc = "A powerful psychic xeno. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	speed = -0.4
	plasma_max = 850
	plasma_gain = 35
	max_health = 350
	upgrade_threshold = TIER_TWO_MATURE_THRESHOLD
	soft_armor = list(MELEE = 35, BULLET = 35, LASER = 35, ENERGY = 35, BOMB = 20, BIO = 15, FIRE = 35, ACID = 15)
	aura_strength = 2.5

/datum/xeno_caste/shrike/elder
	upgrade_name = "Elder"
	caste_desc = "A powerful psychic xeno. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	melee_damage = 23
	speed = -0.5
	plasma_max = 900
	plasma_gain = 40
	max_health = 375
	upgrade_threshold = TIER_TWO_ELDER_THRESHOLD
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 20, BIO = 18, FIRE = 40, ACID = 18)
	aura_strength = 2.8

/datum/xeno_caste/shrike/ancient
	upgrade_name = "Ancient"
	caste_desc = "An unstoppable psychic manifestion of the hive's fury."
	ancient_message = "Our full powers are unleashed, the physical world is our plaything."
	upgrade = XENO_UPGRADE_THREE

	melee_damage = 23
	speed = -0.6
	plasma_max = 925
	plasma_gain = 45
	max_health = 400
	upgrade_threshold = TIER_TWO_ANCIENT_THRESHOLD
	soft_armor = list(MELEE = 45, BULLET = 45, LASER = 45, ENERGY = 45, BOMB = 20, BIO = 23, FIRE = 45, ACID = 20)

/datum/xeno_caste/shrike/primordial
	upgrade_name = "Primordial"
	caste_desc = "An overwhelming psychic beacon. The air around it seems to dance with barely contained power."
	primordial_message = "We are the unbridled psychic power of the hive. Our strength is umatched."
	upgrade = XENO_UPGRADE_FOUR

	melee_damage = 23
	speed = -0.6
	plasma_max = 925
	plasma_gain = 45
	max_health = 400
	soft_armor = list(MELEE = 45, BULLET = 45, LASER = 45, ENERGY = 45, BOMB = 20, BIO = 23, FIRE = 45, ACID = 20)

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/plant_weeds, //just while testing
		/datum/action/xeno_action/activable/psy_crush,
		/datum/action/xeno_action/activable/psy_blast,
	)
