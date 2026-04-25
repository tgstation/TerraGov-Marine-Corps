/datum/xeno_caste/bull
	caste_name = "Bull"
	display_name = "Bull"
	upgrade_name = ""
	caste_desc = "A well defended hit-and-runner."
	base_strain_type = /mob/living/carbon/xenomorph/bull
	caste_type_path = /mob/living/carbon/xenomorph/bull
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "bull" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 24

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 340 //High plasma is need for charging
	plasma_gain = 24

	// *** Health *** //
	max_health = 450

	// *** Sunder *** //
	sunder_multiplier = 0.9

	// *** Evolution *** //
	evolution_threshold = 225
	upgrade_threshold = TIER_TWO_THRESHOLD

	deevolves_to = /datum/xeno_caste/runner

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_MUTATIONS_ALLOWED
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA
	caste_traits = list(TRAIT_STUNIMMUNE)

	// *** Defense *** //
	soft_armor = list(MELEE = 50, BULLET = 55, LASER = 55, ENERGY = 55, BOMB = 20, BIO = 35, FIRE = 50, ACID = 35)

	// *** Minimap Icon *** //
	minimap_icon = "bull"

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/ready_charge/bull_charge,
		/datum/action/ability/activable/xeno/bull_charge,
		/datum/action/ability/activable/xeno/bull_charge/headbutt,
		/datum/action/ability/activable/xeno/bull_charge/gore,
		/datum/action/ability/xeno_action/toggle_long_range/bull,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/unstoppable,
		/datum/mutation_upgrade/spur/speed_demon,
		/datum/mutation_upgrade/veil/railgun
	)

/datum/xeno_caste/bull/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/bull/primordial
	upgrade_name = "Primordial"
	caste_desc = "Bloodthirsty horned devil of the hive. Stay away from its path."
	primordial_message = "We are the spearhead of the hive. Run them all down."
	upgrade = XENO_UPGRADE_PRIMO
