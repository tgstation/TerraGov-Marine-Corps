/datum/xeno_caste/behemoth
	caste_name = "Behemoth"
	display_name = "Behemoth"
	upgrade_name = ""
	caste_desc = "Behemoths are known to like rocks. Perhaps we should give them one!"
	base_strain_type = /mob/living/carbon/xenomorph/behemoth
	caste_type_path = /mob/living/carbon/xenomorph/behemoth
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "behemoth"

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -0.5
	weeds_speed_mod = -0.2

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 30

	// *** Health *** //
	max_health = 700

	// *** Sunder *** //
	sunder_multiplier = 0.8

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD

	deevolves_to = /datum/xeno_caste/bull

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_STAGGER_RESISTANT|CASTE_MUTATIONS_ALLOWED
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA
	caste_traits = list(TRAIT_CAN_TEAR_HOLE, TRAIT_CAN_DISABLE_MINER)

	// *** Defense *** //
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 60, BIO = 50, FIRE = 50, ACID = 50)
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
		/datum/action/ability/xeno_action/seismic_fracture,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/rocky_layers,
		/datum/mutation_upgrade/spur/refined_palate,
		/datum/mutation_upgrade/veil/avalanche
	)

/datum/xeno_caste/behemoth/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/behemoth/primordial
	upgrade_name = "Primordial"
	primordial_message = "In the ancient embrace of the earth, we have honed our art to perfection. Our might will crush the feeble pleas of our enemies before they can escape their lips."
	upgrade = XENO_UPGRADE_PRIMO

	// *** Wrath *** //
	wrath_max = 650

	// *** Abilities *** ///
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/ready_charge/behemoth_roll,
		/datum/action/ability/activable/xeno/landslide,
		/datum/action/ability/activable/xeno/earth_riser,
		/datum/action/ability/xeno_action/seismic_fracture,
		/datum/action/ability/xeno_action/primal_wrath,
	)

/datum/xeno_caste/behemoth/on_caste_applied(mob/xenomorph)
	. = ..()
	xenomorph.AddElement(/datum/element/ridable, /datum/component/riding/creature/crusher) // we use the same riding element as crusher
	xenomorph.RegisterSignal(xenomorph, COMSIG_GRAB_SELF_ATTACK, TYPE_PROC_REF(/mob/living/carbon/xenomorph, grabbed_self_attack))

/datum/xeno_caste/behemoth/on_caste_removed(mob/xenomorph)
	. = ..()
	xenomorph.RemoveElement(/datum/element/ridable, /datum/component/riding/creature/crusher)
	xenomorph.UnregisterSignal(xenomorph, COMSIG_GRAB_SELF_ATTACK)
