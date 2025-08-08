/datum/xeno_caste/warlock
	caste_name = "Warlock"
	display_name = "Warlock"
	upgrade_name = ""
	caste_desc = "A powerful psychic xeno. The Warlock devastates enemies of the hive with its psychic might, but it's physically very frail."
	base_strain_type = /mob/living/carbon/xenomorph/warlock
	caste_type_path = /mob/living/carbon/xenomorph/warlock

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "warlock"
	melee_damage = 18
	speed = -0.5
	plasma_max = 1700
	plasma_gain = 60
	max_health = 325
	upgrade_threshold = TIER_THREE_THRESHOLD

	deevolves_to = /datum/xeno_caste/warrior
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_MUTATIONS_ALLOWED
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA

	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 10, BIO = 35, FIRE = 35, ACID = 35)
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

	mutations = list(
		/datum/mutation_upgrade/shell/cautious_mind,
		/datum/mutation_upgrade/spur/draining_blast,
		/datum/mutation_upgrade/veil/mobile_mind
	)

/datum/xeno_caste/warlock/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/warlock/primordial
	upgrade_name = "Primordial"
	caste_desc = "An overwhelming psychic beacon. The air around it seems to dance with barely contained power."
	primordial_message = "We see the beauty of the unlimited psychic power of the hive. Enlighten the tallhosts to its majesty."
	upgrade = XENO_UPGRADE_PRIMO

	// Psychic Blast automatically upgrades with the power to use [/datum/ammo/energy/xeno/psy_blast/psy_lance].
