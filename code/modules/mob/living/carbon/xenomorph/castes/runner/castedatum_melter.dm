/datum/xeno_caste/runner/melter
	caste_type_path = /mob/living/carbon/xenomorph/runner/melter
	upgrade_name = ""
	caste_name = "Melter"
	display_name = "Melter"
	upgrade = XENO_UPGRADE_BASETYPE
	caste_desc = "A fast, four-legged terror. It got acid covered all over it."

	acid_spray_damage = 16

	// -12 melee damage. Attacking does a second instance of melee damage as brute damage + status effect.
	melee_damage = 11
	melee_damage_type = BURN
	melee_damage_armor = ACID

	// Gain acid blood for less speed (0.2).
	speed = -1.2
	caste_flags = CASTE_ACID_BLOOD|CASTE_EVOLUTION_ALLOWED

	// +50 health
	max_health = 350

	// +5 armor across the board
	soft_armor = list(MELEE = 35, BULLET = 35, LASER = 35, ENERGY = 35, BOMB = 5, BIO = 10, FIRE = 25, ACID = 10)

	// Loses pounce and evasion for acid-themed abilities.
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid/melter,
		/datum/action/ability/activable/xeno/charge/acid_dash/melter,
		/datum/action/ability/activable/xeno/melter_shroud,
		/datum/action/ability/xeno_action/xenohide,
	)

	buyable_mutations = list(
		/datum/mutation_upgrade/shell/acid_release,
		/datum/mutation_upgrade/spur/fully_acid,
		/datum/mutation_upgrade/veil/acid_reserves
	)

/datum/xeno_caste/runner/melter/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/runner/melter/primordial
	upgrade_name = "Primordial"
	caste_desc = "An agile acid-wielding predator. Its speed and corrosive touch spell doom for any who stand in its way."
	primordial_message = "With our nimble movements and acidic touch, we close in and dissolve all resistance."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid/melter,
		/datum/action/ability/activable/xeno/charge/acid_dash/melter,
		/datum/action/ability/activable/xeno/melter_shroud,
		/datum/action/ability/activable/xeno/acidic_missile,
		/datum/action/ability/xeno_action/xenohide,
	)
