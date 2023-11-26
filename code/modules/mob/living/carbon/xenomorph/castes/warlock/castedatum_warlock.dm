/datum/xeno_caste/warlock
	caste_name = "Warlock"
	display_name = "Warlock"
	upgrade_name = ""
	caste_desc = "A powerful psychic xeno. The Warlock devastates enemies of the hive with its psychic might, but it's physically very frail."
	caste_type_path = /mob/living/carbon/xenomorph/warlock

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "warlock"
	melee_damage = 18
	speed = -0.5
	plasma_max = 1700
	plasma_gain = 60
	max_health = 375
	upgrade_threshold = TIER_THREE_THRESHOLD
	spit_types = list(/datum/ammo/energy/xeno/psy_blast)

	deevolves_to = list(/mob/living/carbon/xenomorph/wraith, /mob/living/carbon/xenomorph/puppeteer)
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	caste_traits = null
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 10, BIO = 35, FIRE = 35, ACID = 35)
	shield_strength = 650
	crush_strength = 50
	blast_strength = 45
	minimap_icon = "warlock"
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/psy_crush,
		/datum/action/ability/activable/xeno/psy_blast,
		/datum/action/ability/activable/xeno/psychic_shield,
		/datum/action/ability/activable/xeno/transfer_plasma/drone,
		/datum/action/ability/xeno_action/psychic_whisper,
	)

/datum/xeno_caste/warlock/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/warlock/primordial
	upgrade_name = "Primordial"
	caste_desc = "An overwhelming psychic beacon. The air around it seems to dance with barely contained power."
	primordial_message = "We see the beauty of the unlimited psychic power of the hive. Enlighten the tallhosts to its majesty."
	upgrade = XENO_UPGRADE_PRIMO

	spit_types = list(/datum/ammo/energy/xeno/psy_blast, /datum/ammo/energy/xeno/psy_blast/psy_lance)

