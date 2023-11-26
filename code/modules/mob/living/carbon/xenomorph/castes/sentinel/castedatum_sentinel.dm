/datum/xeno_caste/sentinel
	caste_name = "Sentinel"
	display_name = "Sentinel"
	upgrade_name = ""
	caste_desc = "A weak ranged combat alien."
	caste_type_path = /mob/living/carbon/xenomorph/sentinel
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE

	gib_anim = "gibbed-a-small-corpse"
	gib_flick = "gibbed-a-small"

	// *** Melee Attacks *** //
	melee_damage = 16

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 20

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	evolution_threshold = 100
	upgrade_threshold = TIER_ONE_THRESHOLD

	evolves_to = list(/mob/living/carbon/xenomorph/spitter)

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_RIDE_CRUSHER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 0, BIO = 25, FIRE = 26, ACID = 25)

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

/datum/xeno_caste/sentinel/normal
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
