/datum/xeno_caste/sentinel
	caste_name = "Sentinel"
	display_name = "Sentinel"
	upgrade_name = ""
	caste_desc = "A weak ranged combat alien."
	base_strain_type = /mob/living/carbon/xenomorph/sentinel
	caste_type_path = /mob/living/carbon/xenomorph/sentinel
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE

	gib_anim = "gibbed-a-small-corpse"
	gib_flick = "gibbed-a-small"

	// *** Melee Attacks *** //
	melee_damage = 18

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 20

	// *** Health *** //
	max_health = 370

	// *** Evolution *** //
	evolution_threshold = 100
	upgrade_threshold = TIER_ONE_THRESHOLD

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_MUTATIONS_ALLOWED
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_RIDE_CRUSHER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 10, BIO = 30, FIRE = 30, ACID = 30)

	// *** Ranged Attack *** //
	spit_delay = 1.0 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/toxic_spit)

	// *** Sentinel Abilities ***
	additional_stacks = 3

	// *** Minimap Icon *** //
	minimap_icon = "sentinel"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid/drone,
		/datum/action/ability/activable/xeno/xeno_spit/toxic_spit,
		/datum/action/ability/xeno_action/toxic_slash,
		/datum/action/ability/activable/xeno/drain_sting,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/comforting_acid,
		/datum/mutation_upgrade/shell/healing_sting,
		/datum/mutation_upgrade/shell/constant_surge,
		/datum/mutation_upgrade/spur/acidic_slasher,
		/datum/mutation_upgrade/spur/far_sting,
		/datum/mutation_upgrade/spur/imbued_claws,
		/datum/mutation_upgrade/veil/toxic_compatibility,
		/datum/mutation_upgrade/veil/toxic_blood,
		/datum/mutation_upgrade/veil/automatic_sting,
	)

/datum/xeno_caste/sentinel/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/sentinel/retrograde/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/sentinel/primordial
	upgrade_name = "Primordial"
	caste_desc = "A doctors worst nightmare. It's stinger drips with poison."
	primordial_message = "All will succumb to our toxins. Leave noone standing."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid/drone,
		/datum/action/ability/activable/xeno/xeno_spit/toxic_spit,
		/datum/action/ability/xeno_action/toxic_slash,
		/datum/action/ability/activable/xeno/drain_sting,
		/datum/action/ability/activable/xeno/toxic_grenade,
	)

/datum/xeno_caste/sentinel/retrograde
	caste_type_path = /mob/living/carbon/xenomorph/sentinel/retrograde
	upgrade_name = ""
	caste_name = "Retrograde Sentinel"
	display_name = "Sentinel"
	upgrade = XENO_UPGRADE_BASETYPE
	caste_desc = "A weak ranged combat alien. This one seems to have a different kind of spit."

		// *** Ranged Attack *** //
	spit_delay = 1 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin, /datum/ammo/xeno/acid/passthrough)

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid/drone,
		/datum/action/ability/activable/xeno/neurotox_sting,
		/datum/action/ability/activable/xeno/xeno_spit,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/gaseous_blood,
		/datum/mutation_upgrade/spur/toxic_claws,
		/datum/mutation_upgrade/veil/toxic_spillage
	)

/datum/xeno_caste/sentinel/retrograde/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_PRIMO
	caste_desc = "A neurotoxic nightmare. It's stingers drip with poison."

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid/drone,
		/datum/action/ability/activable/xeno/neurotox_sting,
		/datum/action/ability/activable/xeno/xeno_spit,
		/datum/action/ability/activable/xeno/toxic_grenade/neuro
	)
