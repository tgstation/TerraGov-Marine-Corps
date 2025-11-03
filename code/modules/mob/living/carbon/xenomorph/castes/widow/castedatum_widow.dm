/datum/xeno_caste/widow
	caste_name = "Widow"
	display_name = "Widow"
	upgrade_name = ""
	caste_desc = "You don't think you've seen a tarantula this giant before."
	base_strain_type = /mob/living/carbon/xenomorph/widow
	caste_type_path = /mob/living/carbon/xenomorph/widow

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "widow"

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 55

	// *** Health *** //
	max_health = 450

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD

	deevolves_to = /datum/xeno_caste/puppeteer

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_IS_BUILDER|CASTE_MUTATIONS_ALLOWED
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_RULER

	// *** Defense *** //
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 15, BIO = 10, FIRE = 15, ACID = 10)

	// *** Pheromones *** //
	aura_strength = 2 //Widows aura is the same as drones.

	// *** Minimap Icon *** //
	minimap_icon = "widow"

	// *** Ruler Abilities *** ///
	queen_leader_limit = 4

	// *** Widow Abilities *** //
	max_spiderlings = 5

	// *** Abilities *** ///
	resin_max_range = 1 // Widow can place resin structures from 1 tile away

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/activable/xeno/secrete_resin/widow,
		/datum/action/ability/activable/xeno/web_spit,
		/datum/action/ability/xeno_action/burrow,
		/datum/action/ability/activable/xeno/leash_ball,
		/datum/action/ability/xeno_action/create_spiderling,
		/datum/action/ability/xeno_action/lay_egg,
		/datum/action/ability/xeno_action/attach_spiderlings,
		/datum/action/ability/activable/xeno/cannibalise,
		/datum/action/ability/activable/xeno/spiderling_mark,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/activable/xeno/place_pattern,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/hive_toughness,
		/datum/mutation_upgrade/spur/web_yank,
		/datum/mutation_upgrade/veil/incubator
	)

/datum/xeno_caste/widow/on_caste_applied(mob/xenomorph)
	. = ..()
	xenomorph.AddElement(/datum/element/wall_speedup, WIDOW_SPEED_BONUS)
	xenomorph.AddElement(/datum/element/ridable, /datum/component/riding/creature/widow)

/datum/xeno_caste/widow/on_caste_removed(mob/xenomorph)
	. = ..()
	xenomorph.RemoveElement(/datum/element/wall_speedup, WIDOW_SPEED_BONUS)
	xenomorph.RemoveElement(/datum/element/ridable, /datum/component/riding/creature/widow)

/datum/xeno_caste/widow/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/widow/primordial
	upgrade_name = "Primordial"
	caste_desc = "At times, life is just like a web. You fall, and a spider called accident, at the center, takes you to hell."
	primordial_message = "We weave the threads of fate that our victims life hangs from."
	upgrade = XENO_UPGRADE_PRIMO

	// *** Abilities *** ///
	resin_max_range = 1 //Widow can place resin structures from 1 tile away

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/activable/xeno/secrete_resin/widow,
		/datum/action/ability/activable/xeno/web_spit,
		/datum/action/ability/xeno_action/burrow,
		/datum/action/ability/activable/xeno/leash_ball,
		/datum/action/ability/xeno_action/create_spiderling,
		/datum/action/ability/xeno_action/lay_egg,
		/datum/action/ability/xeno_action/attach_spiderlings,
		/datum/action/ability/activable/xeno/cannibalise,
		/datum/action/ability/activable/xeno/spiderling_mark,
		/datum/action/ability/xeno_action/sow,
		/datum/action/ability/activable/xeno/web_hook,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/activable/xeno/place_pattern,
	)
