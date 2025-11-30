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
	melee_damage = 30
	melee_ap = 10

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 30

	// *** Health *** //
	max_health = 450

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD

	deevolves_to = /datum/xeno_caste/bull

	// *** Flags *** //
	caste_flags = CASTE_STAGGER_RESISTANT|CASTE_EVOLUTION_ALLOWED|CASTE_MUTATIONS_ALLOWED
	caste_traits = list(TRAIT_CAN_DISABLE_MINER, TRAIT_CAN_TEAR_HOLE)

	// *** Defense *** //
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 50, BOMB = 40, BIO = 0, FIRE = 60, ACID = 0)

	// *** Minimap Icon *** //
	minimap_icon = "behemoth"

	// *** Abilities *** ///
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/earth_riser,
		/datum/action/ability/activable/xeno/behemoth_seize,
		/datum/action/ability/activable/xeno/landslide,
		/datum/action/ability/activable/xeno/geocrush
	)

	// *** Mutations *** ///
	mutations = list(
		/datum/mutation_upgrade/shell/foundations,
		/datum/mutation_upgrade/spur/earth_might,
		/datum/mutation_upgrade/veil/guided_claim
	)

/datum/xeno_caste/behemoth/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/behemoth/primordial
	upgrade_name = "Primordial"
	primordial_message = "In the ancient embrace of the earth, we have honed our art to perfection. Our might will crush the feeble pleas of our enemies before they can escape their lips."
	upgrade = XENO_UPGRADE_PRIMO

	// *** Abilities *** ///
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/earth_riser,
		/datum/action/ability/activable/xeno/behemoth_seize,
		/datum/action/ability/activable/xeno/landslide,
		/datum/action/ability/activable/xeno/geocrush,
		/datum/action/ability/xeno_action/primal_wrath
	)
