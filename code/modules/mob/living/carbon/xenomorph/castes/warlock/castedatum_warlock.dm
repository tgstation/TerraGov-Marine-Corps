/datum/xeno_caste/warlock
	caste_name = "Warlock"
	display_name = "Warlock"
	upgrade_name = ""
	caste_desc = "A powerful psychic xeno. The Warlock devastates enemies of the hive with its psychic might, but it's physically very frail."
	caste_type_path = /mob/living/carbon/xenomorph/warlock

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "warlock"
	melee_damage = 16
	speed = -0.2
	plasma_max = 1400
	plasma_gain = 40
	max_health = 320
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD
	spit_types = list(/datum/ammo/energy/xeno/psy_blast)

	deevolves_to = /mob/living/carbon/xenomorph/wraith
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	caste_traits = null
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 25, FIRE = 25, ACID = 25)
	minimap_icon = "warlock"
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/psy_crush,
		/datum/action/xeno_action/activable/psy_blast,
		/datum/action/xeno_action/activable/psychic_shield,
		/datum/action/xeno_action/activable/transfer_plasma/drone,
		/datum/action/xeno_action/psychic_whisper,
	)

/datum/xeno_caste/warlock/young
	upgrade_name = "Young"
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/warlock/mature
	upgrade_name = "Mature"
	caste_desc = "A powerful psychic xeno. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	speed = -0.3
	plasma_max = 1500
	plasma_gain = 40
	max_health = 335
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD
	soft_armor = list(MELEE = 35, BULLET = 35, LASER = 35, ENERGY = 35, BOMB = 0, BIO = 29, FIRE = 29, ACID = 29)
	shield_strength = 450
	crush_strength = 40
	blast_strength = 35

/datum/xeno_caste/warlock/elder
	upgrade_name = "Elder"
	caste_desc = "A powerful psychic xeno. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	melee_damage = 17
	speed = -0.4
	plasma_max = 1600
	plasma_gain = 50
	max_health = 350
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD
	soft_armor = list(MELEE = 39, BULLET = 39, LASER = 39, ENERGY = 37, BOMB = 5, BIO = 32, FIRE = 32, ACID = 32)
	shield_strength = 550
	crush_strength = 45
	blast_strength = 40

/datum/xeno_caste/warlock/ancient
	upgrade_name = "Ancient"
	caste_desc = "An unstoppable psychic manifestion of the hive's fury."
	ancient_message = "Our full powers are unleashed, the physical world is our plaything."
	upgrade = XENO_UPGRADE_THREE

	melee_damage = 18
	speed = -0.5
	plasma_max = 1700
	plasma_gain = 60
	max_health = 375
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD
	soft_armor = list(MELEE = 42, BULLET = 42, LASER = 42, ENERGY = 40, BOMB = 10, BIO = 35, FIRE = 35, ACID = 35)
	shield_strength = 650
	crush_strength = 50
	blast_strength = 45

/datum/xeno_caste/warlock/primordial
	upgrade_name = "Primordial"
	caste_desc = "An overwhelming psychic beacon. The air around it seems to dance with barely contained power."
	primordial_message = "We see the beauty of the unlimited psychic power of the hive. Enlighten the tallhosts to its majesty."
	upgrade = XENO_UPGRADE_FOUR

	melee_damage = 18
	speed = -0.5
	plasma_max = 1700
	plasma_gain = 60
	max_health = 375
	spit_types = list(/datum/ammo/energy/xeno/psy_blast, /datum/ammo/energy/xeno/psy_blast/psy_lance)
	soft_armor = list(MELEE = 42, BULLET = 42, LASER = 42, ENERGY = 40, BOMB = 10, BIO = 35, FIRE = 35, ACID = 35)
	shield_strength = 650
	crush_strength = 50
	blast_strength = 45
