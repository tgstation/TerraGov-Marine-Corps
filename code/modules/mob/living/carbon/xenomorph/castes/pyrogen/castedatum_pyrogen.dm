/datum/xeno_caste/pyrogen
	caste_name = "Pyrogen"
	display_name = "Pyrogen"
	upgrade_name = ""
	caste_desc = "A xenomorph constantly engulfed by plasma flames."
	base_strain_type = /mob/living/carbon/xenomorph/pyrogen
	caste_type_path = /mob/living/carbon/xenomorph/pyrogen
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "pyrogen" //used to match appropriate wound overlays
	evolution_threshold = 225

	// *** Melee Attacks *** //
	melee_damage = 22
	melee_damage_type = BURN
	melee_damage_armor = FIRE
	attack_delay = 7

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 30

	// *** Health *** //
	max_health = 380

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/runner

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_FIRE_IMMUNE|CASTE_MUTATIONS_ALLOWED
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 0, BIO = 30, FIRE = 200, ACID = 30)
	hard_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 100, ACID = 0)

	// *** Minimap Icon *** //
	minimap_icon = "pyrogen"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/charge/fire_charge,
		/datum/action/ability/activable/xeno/fireball,
		/datum/action/ability/activable/xeno/firestorm,
		/datum/action/ability/activable/xeno/inferno,
	)
	///multiplier on plasma amount vs damage that is recieved on attack
	var/plasma_damage_dealt_mult = 2.5

	mutations = list(
		/datum/mutation_upgrade/shell/flame_cloak,
		/datum/mutation_upgrade/spur/only_fire,
		/datum/mutation_upgrade/veil/burnt_wounds
	)

/datum/xeno_caste/pyrogen/on_caste_applied(mob/xenomorph)
	. = ..()
	xenomorph.AddElement(/datum/element/plasma_on_attack, plasma_damage_dealt_mult)

/datum/xeno_caste/pyrogen/on_caste_removed(mob/xenomorph)
	. = ..()
	xenomorph.RemoveElement(/datum/element/plasma_on_attack, plasma_damage_dealt_mult)

/datum/xeno_caste/pyrogen/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/pyrogen/primordial
	upgrade_name = "Primordial"
	caste_desc = "The fire within this one shimmers brighter than the ones before."
	primordial_message = "Everything shall experience the cold of the void."
	upgrade = XENO_UPGRADE_PRIMO

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/charge/fire_charge,
		/datum/action/ability/activable/xeno/fireball,
		/datum/action/ability/activable/xeno/firestorm,
		/datum/action/ability/activable/xeno/inferno,
		/datum/action/ability/activable/xeno/infernal_trigger,
	)
