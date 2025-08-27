/datum/xeno_caste/praetorian
	caste_name = "Praetorian"
	display_name = "Praetorian"
	upgrade_name = ""
	caste_desc = "A giant ranged monster. It looks pretty strong."
	base_strain_type = /mob/living/carbon/xenomorph/praetorian
	caste_type_path = /mob/living/carbon/xenomorph/praetorian
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "praetorian" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 100

	// *** Health *** //
	max_health = 390

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD

	deevolves_to = /datum/xeno_caste/spitter

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_MUTATIONS_ALLOWED
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_RULER
	caste_traits = list(TRAIT_CAN_TEAR_HOLE, TRAIT_CAN_DISABLE_MINER)

	// *** Defense *** //
	soft_armor = list(MELEE = 45, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 40, FIRE = 50, ACID = 40)

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/heavy, /datum/ammo/xeno/acid/heavy)

	acid_spray_duration = 10 SECONDS
	acid_spray_damage = 25
	acid_spray_damage_on_hit = 55
	acid_spray_structure_damage = 69

	// *** Pheromones *** //
	aura_strength = 4.5 //Praetorian's aura starts strong. They are the Queen's right hand.

	// *** Minimap Icon *** //
	minimap_icon = "praetorian"

	// *** Ruler Abilities *** ///
	queen_leader_limit = 4

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/activable/xeno/xeno_spit,
		/datum/action/ability/activable/xeno/spray_acid/cone,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/adaptive_armor,
		/datum/mutation_upgrade/spur/circular_acid,
		/datum/mutation_upgrade/veil/wide_pheromones
	)

/datum/xeno_caste/praetorian/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/praetorian/primordial
	upgrade_name = "Primordial"
	caste_desc = "An aberrant creature extremely proficient with acid, keep your distance if you don't wish to be burned."
	upgrade = XENO_UPGRADE_PRIMO
	primordial_message = "The strongest of acids flows through our veins, let's reduce them to dust."

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/activable/xeno/xeno_spit,
		/datum/action/ability/activable/xeno/spray_acid/cone,
		/datum/action/ability/xeno_action/sticky_grenade,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
	)

/datum/xeno_caste/praetorian/dancer
	caste_type_path = /mob/living/carbon/xenomorph/praetorian/dancer
	upgrade_name = ""
	caste_name = "Dancer Praetorian"
	display_name = "Dancer"
	upgrade = XENO_UPGRADE_BASETYPE
	caste_desc = "A giant melee monster. It looks pretty strong."

	// +2 melee damage
	melee_damage = 25

	// +30 hp
	max_health = 420

	// Gains more speed (-0.2).
	speed = -0.7

	// +10 melee armor
	soft_armor = list(MELEE = 55, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 40, FIRE = 50, ACID = 40)

	// Loses ranged spit abilities for close combat combo abilities.
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/dodge,
		/datum/action/ability/activable/xeno/tail_hook,
		/datum/action/ability/activable/xeno/tail_trip,
		/datum/action/ability/activable/xeno/impale,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/flame_dance,
		/datum/mutation_upgrade/spur/bob_and_weave,
		/datum/mutation_upgrade/veil/eb_and_flow
	)

/datum/xeno_caste/praetorian/dancer/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/praetorian/dancer/primordial
	upgrade_name = "Primordial"
	caste_desc = "An aberrant creature extremely proficient with its body and tail. Keep your distance if you don't wish to be finessed."
	upgrade = XENO_UPGRADE_PRIMO
	primordial_message = "With a flick of our tail, we dance through the shadows, striking with lethal precision."

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/dodge,
		/datum/action/ability/activable/xeno/tail_hook,
		/datum/action/ability/activable/xeno/tail_trip,
		/datum/action/ability/activable/xeno/impale,
		/datum/action/ability/activable/xeno/baton_pass,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
	)

/datum/xeno_caste/praetorian/oppressor
	caste_type_path = /mob/living/carbon/xenomorph/praetorian/oppressor
	upgrade_name = ""
	caste_name = "Oppressor Praetorian"
	display_name = "Oppressor"
	upgrade = XENO_UPGRADE_BASETYPE
	caste_desc = "A giant melee monster with a weird tail! It looks pretty strong."

	// +2 melee damage
	melee_damage = 25

	// +10 armor
	soft_armor = list(MELEE = 55, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 20, BIO = 50, FIRE = 60, ACID = 50)

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/activable/xeno/oppressor/abduct,
		/datum/action/ability/activable/xeno/oppressor/dislocate,
		/datum/action/ability/activable/xeno/oppressor/advance,
		/datum/action/ability/activable/xeno/oppressor/tail_lash,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/advance_away,
		/datum/mutation_upgrade/spur/wall_bang,
		/datum/mutation_upgrade/veil/low_charge
	)

/datum/xeno_caste/praetorian/oppressor/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/praetorian/oppressor/primordial
	upgrade_name = "Primordial"
	caste_desc = "A fearsome entity adept at using its brute strength to immobilize and relocate its foes. Approach with extreme caution or risk being torn from your comrades."
	upgrade = XENO_UPGRADE_PRIMO
	primordial_message = "With relentless power, we shatter their formations, seizing them in our grasp and rendering them helpless."

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/activable/xeno/oppressor/abduct,
		/datum/action/ability/activable/xeno/oppressor/dislocate,
		/datum/action/ability/activable/xeno/oppressor/advance,
		/datum/action/ability/activable/xeno/oppressor/tail_lash,
		/datum/action/ability/activable/xeno/item_throw,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
	)
