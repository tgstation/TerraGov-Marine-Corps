/datum/xeno_caste/drone
	caste_name = "Drone"
	display_name = "Drone"
	upgrade_name = ""
	caste_desc = "A builder of hives. Only drones may evolve into Shrikes."
	caste_type_path = /mob/living/carbon/xenomorph/drone

	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE

	gib_anim = "gibbed-a-small-corpse"
	gib_flick = "gibbed-a-small"

	// *** Melee Attacks *** //
	melee_damage = 18

	// *** Speed *** //
	speed = -1.2
	weeds_speed_mod = -0.4

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 40

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	evolution_threshold = 100
	upgrade_threshold = TIER_ONE_THRESHOLD

	evolves_to = list(
		/mob/living/carbon/xenomorph/shrike,
		/mob/living/carbon/xenomorph/queen,
		/mob/living/carbon/xenomorph/king,
		/mob/living/carbon/xenomorph/carrier,
		/mob/living/carbon/xenomorph/hivelord,
		/mob/living/carbon/xenomorph/hivemind,
	)

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_IS_BUILDER
	can_hold_eggs = CAN_HOLD_TWO_HANDS
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_HOLD_JELLY|CASTE_CAN_RIDE_CRUSHER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 15, FIRE = 30, ACID = 15)

	// *** Pheromones *** //
	aura_strength = 2 //Drone's aura is the weakest.

	// *** Minimap Icon *** //
	minimap_icon = "drone"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/activable/xeno/secrete_resin,
		/datum/action/ability/activable/xeno/essence_link,
		/datum/action/ability/activable/xeno/psychic_cure/acidic_salve,
		/datum/action/ability/activable/xeno/transfer_plasma/drone,
		/datum/action/ability/activable/xeno/corrosive_acid/drone,
		/datum/action/ability/xeno_action/create_jelly/slow,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/activable/xeno/recycle,
	)

/datum/xeno_caste/drone/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/drone/primordial
	upgrade_name = "Primordial"
	caste_desc = "The perfect worker."
	primordial_message = "We shall build wonders with our claws. Glory to the hive."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/activable/xeno/secrete_resin,
		/datum/action/ability/activable/xeno/essence_link,
		/datum/action/ability/activable/xeno/psychic_cure/acidic_salve,
		/datum/action/ability/activable/xeno/transfer_plasma/drone,
		/datum/action/ability/xeno_action/sow,
		/datum/action/ability/xeno_action/enhancement,
		/datum/action/ability/activable/xeno/corrosive_acid/drone,
		/datum/action/ability/xeno_action/create_jelly/slow,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/ability/activable/xeno/recycle,
	)
