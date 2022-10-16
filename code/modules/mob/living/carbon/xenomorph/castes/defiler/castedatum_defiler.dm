/datum/xeno_caste/defiler
	caste_name = "Defiler"
	display_name = "Defiler"
	upgrade_name = ""
	caste_desc = "A frightening looking, bulky xeno that drips with suspect green fluids."

	caste_type_path = /mob/living/carbon/xenomorph/defiler

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "defiler" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -0.7

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 20

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/carrier

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_hold_eggs = CAN_HOLD_ONE_HAND
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BECOME_KING

	// *** Defense *** //
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 30, "rad" = 30, FIRE = 25, ACID = 30)

	// *** Minimap Icon *** //
	minimap_icon = "defiler"

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/activable/plant_weeds,
		/datum/action/xeno_action/activable/defile,
		/datum/action/xeno_action/lay_egg,
		/datum/action/xeno_action/activable/inject_egg_neurogas,
		/datum/action/xeno_action/emit_neurogas,
		/datum/action/xeno_action/select_reagent,
		/datum/action/xeno_action/reagent_slash,
		/datum/action/xeno_action/pheromones,
		/datum/action/xeno_action/pheromones/emit_recovery,
		/datum/action/xeno_action/pheromones/emit_warding,
		/datum/action/xeno_action/pheromones/emit_frenzy,
	)

	available_reagents_define = list(
		/datum/reagent/toxin/xeno_hemodile,
		/datum/reagent/toxin/xeno_transvitox,
		/datum/reagent/toxin/xeno_neurotoxin,
		/datum/reagent/toxin/xeno_ozelomelyn,
	)

	// *** Pheromones *** //
	aura_strength = 1.7 //Defilers aura begins at 1.7 and ends at 2.6. It's .1 better than a carrier at ancient.

/datum/xeno_caste/defiler/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/defiler/mature
	upgrade_name = "Mature"
	caste_desc = "A frightening looking, bulky xeno that drips with suspect green fluids. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 25

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 35, BULLET = 35, LASER = 35, ENERGY = 35, BOMB = 0, BIO = 35, "rad" = 35, FIRE = 30, ACID = 35)

	// *** Pheromones *** //
	aura_strength = 2 //Defilers aura begins at 1.7 and ends at 2.6. It's .1 better than a carrier at ancient.

/datum/xeno_caste/defiler/elder
	upgrade_name = "Elder"
	caste_desc = "A frightening looking, bulky xeno that drips with suspect green fluids. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 26

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 550
	plasma_gain = 30

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 0, BIO = 38, "rad" = 38, FIRE = 35, ACID = 38)

		// *** Pheromones *** //
	aura_strength = 2.1 //Defilers aura begins at 1.7 and ends at 2.6. It's .1 better than a carrier at ancient.

/datum/xeno_caste/defiler/ancient
	upgrade_name = "Ancient"
	caste_desc = "Being within mere eyeshot of this hulking, dripping monstrosity fills you with a deep, unshakeable sense of unease."
	ancient_message = "We're a bristling, living alien chemlab. Our body leaks noxious fumes that will slip through even the most powerful protections."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 26

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 575
	plasma_gain = 35

	// *** Health *** //
	max_health = 375

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 45, BULLET = 45, LASER = 45, ENERGY = 45, BOMB = 0, BIO = 40, "rad" = 40, FIRE = 40, ACID = 40)

	// *** Pheromones *** //
	aura_strength = 2.6 //Defilers aura begins at 1.7 and ends at 2.6. It's .1 better than a carrier at ancient.


/datum/xeno_caste/defiler/primordial
	upgrade_name = "Primordial"
	caste_desc = "An unspeakable hulking horror dripping and exuding the most vile of substances."
	primordial_message = "Death follows everywhere we go. We are the plague."
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 26

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 575
	plasma_gain = 35

	// *** Health *** //
	max_health = 375

	// *** Defense *** //
	soft_armor = list(MELEE = 45, BULLET = 45, LASER = 45, ENERGY = 45, BOMB = 0, BIO = 40, "rad" = 40, FIRE = 40, ACID = 40)

	// *** Pheromones *** //
	aura_strength = 2.6 //Defilers aura begins at 1.7 and ends at 2.6. It's .1 better than a carrier at ancient.

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/activable/plant_weeds,
		/datum/action/xeno_action/activable/defile,
		/datum/action/xeno_action/lay_egg,
		/datum/action/xeno_action/activable/inject_egg_neurogas,
		/datum/action/xeno_action/emit_neurogas,
		/datum/action/xeno_action/select_reagent,
		/datum/action/xeno_action/reagent_slash,
		/datum/action/xeno_action/pheromones,
		/datum/action/xeno_action/pheromones/emit_recovery,
		/datum/action/xeno_action/pheromones/emit_warding,
		/datum/action/xeno_action/pheromones/emit_frenzy,
		/datum/action/xeno_action/activable/tentacle,
	)
