
/datum/xeno_caste/behemoth/sieger
	caste_name = "Behemoth Sieger"
	display_name = "Sieger"
	upgrade_name = ""
	caste_desc = "Behemoths are known to like rocks. This one liked them too much it is now harmonized, one with rocks, tough armor."
	base_strain_type = /mob/living/carbon/xenomorph/behemoth
	caste_type_path = /mob/living/carbon/xenomorph/behemoth/sieger
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "behemoth"

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Defense *** //
	soft_armor = list(MELEE = 50, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 70, BIO = 60, FIRE = 60, ACID = 60)

	// *** Minimap Icon *** //
	minimap_icon = "crusher"

	// *** Abilities *** ///
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/psychic_whisper,
		/datum/action/ability/xeno_action/psychic_influence,
		/datum/action/ability/activable/xeno/impregnate,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/devour,
		/datum/action/ability/activable/xeno/tail_stab/battering_ram,
		/datum/action/ability/xeno_action/ready_charge/sieger,
		/datum/action/ability/activable/xeno/shard_burst/cone,
		/datum/action/ability/activable/xeno/earth_riser/siege,
		/datum/action/ability/xeno_action/create_edible_jelly,
		/datum/action/ability/xeno_action/place_stew_pod,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/rocky_layers,
		/datum/mutation_upgrade/spur/refined_palate,
		/datum/mutation_upgrade/veil/avalanche
	)

/datum/xeno_caste/behemoth/sieger/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/behemoth/sieger/primordial
	upgrade_name = "Primordial"
	primordial_message = "In the ancient embrace of the earth, we have honed our art to perfection. We will tear down their metal hive and they won't even have time to react."
	upgrade = XENO_UPGRADE_PRIMO

	// *** Wrath *** //
	wrath_max = 650

	// *** Abilities *** ///
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/psychic_whisper,
		/datum/action/ability/xeno_action/psychic_influence,
		/datum/action/ability/activable/xeno/impregnate,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/devour,
		/datum/action/ability/activable/xeno/tail_stab/battering_ram,
		/datum/action/ability/xeno_action/ready_charge/sieger,
		/datum/action/ability/activable/xeno/shard_burst/cone/circle,
		/datum/action/ability/activable/xeno/earth_riser/siege,
		/datum/action/ability/xeno_action/primal_wrath,
		/datum/action/ability/xeno_action/create_edible_jelly,
		/datum/action/ability/xeno_action/place_stew_pod,
	)
