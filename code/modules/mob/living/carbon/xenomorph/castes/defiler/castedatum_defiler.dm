/datum/xeno_caste/defiler
	caste_name = "Defiler"
	display_name = "Defiler"
	upgrade_name = ""
	caste_desc = "A frightening looking, bulky xeno that drips with suspect green fluids."
	base_strain_type = /mob/living/carbon/xenomorph/defiler
	caste_type_path = /mob/living/carbon/xenomorph/defiler

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "defiler" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 26

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 575
	plasma_gain = 35

	// *** Health *** //
	max_health = 400

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD

	deevolves_to = /datum/xeno_caste/carrier

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_MUTATIONS_ALLOWED
	can_hold_eggs = CAN_HOLD_ONE_HAND
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_RULER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 40, FIRE = 40, ACID = 40)

	// *** Minimap Icon *** //
	minimap_icon = "defiler"

	// *** Ruler Abilities *** ///
	queen_leader_limit = 4

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/activable/xeno/defile,
		/datum/action/ability/xeno_action/lay_egg,
		/datum/action/ability/activable/xeno/inject_egg_neurogas,
		/datum/action/ability/xeno_action/emit_neurogas,
		/datum/action/ability/xeno_action/select_reagent,
		/datum/action/ability/xeno_action/reagent_slash,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
	)

	available_reagents_define = list(
		/datum/reagent/toxin/xeno_hemodile,
		/datum/reagent/toxin/xeno_transvitox,
		/datum/reagent/toxin/xeno_neurotoxin,
		/datum/reagent/toxin/xeno_ozelomelyn,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/panic_gas,
		/datum/mutation_upgrade/spur/envenomed,
		/datum/mutation_upgrade/veil/wide_gas
	)

	// *** Pheromones *** //
	aura_strength = 2.6 //It's .1 better than a carrier.

/datum/xeno_caste/defiler/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/defiler/primordial
	upgrade_name = "Primordial"
	caste_desc = "An unspeakable hulking horror dripping and exuding the most vile of substances."
	primordial_message = "Death follows everywhere we go. We are the plague."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/activable/xeno/defile,
		/datum/action/ability/xeno_action/lay_egg,
		/datum/action/ability/activable/xeno/inject_egg_neurogas,
		/datum/action/ability/xeno_action/emit_neurogas,
		/datum/action/ability/xeno_action/select_reagent,
		/datum/action/ability/xeno_action/reagent_slash,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/activable/xeno/tentacle,
	)
