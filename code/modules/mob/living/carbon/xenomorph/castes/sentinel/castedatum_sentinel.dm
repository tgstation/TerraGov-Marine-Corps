/datum/xeno_caste/sentinel
	caste_name = "Sentinel"
	display_name = "Sentinel"
	upgrade_name = ""
	caste_desc = "A weak ranged combat alien."
	caste_type_path = /mob/living/carbon/xenomorph/sentinel
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 14

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 350
	plasma_gain = 15

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	evolution_threshold = 80
	upgrade_threshold = TIER_ONE_YOUNG_THRESHOLD

	evolves_to = list(/mob/living/carbon/xenomorph/spitter)
	deevolves_to = /mob/living/carbon/xenomorph/larva

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_RIDE_CRUSHER|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_HOLD_JELLY
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 0, BIO = 15, FIRE = 15, ACID = 15)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/toxic_spit)

	// *** Sentinel Abilities ***
	additional_stacks = 0

	// *** Minimap Icon *** //
	minimap_icon = "sentinel"

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/corrosive_acid/drone,
		/datum/action/xeno_action/activable/xeno_spit/toxic_spit,
		/datum/action/xeno_action/toxic_slash,
		/datum/action/xeno_action/activable/drain_sting,
	)

/datum/xeno_caste/sentinel/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/sentinel/mature
	upgrade_name = "Mature"
	caste_desc = "A ranged combat alien. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 18

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 20, FIRE = 20, ACID = 20)

	// *** Ranged Attack *** //
	spit_delay = 1.2 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/toxic_spit/upgrade1)

	// *** Sentinel Abilities ***
	additional_stacks = 1

/datum/xeno_caste/sentinel/elder
	upgrade_name = "Elder"
	caste_desc = "A ranged combat alien. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 16

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 21

	// *** Health *** //
	max_health = 275

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 23, BULLET = 23, LASER = 23, ENERGY = 23, BOMB = 0, BIO = 23, FIRE = 23, ACID = 23)

	// *** Ranged Attack *** //
	spit_delay = 1.1 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/toxic_spit/upgrade2)

	// *** Sentinel Abilities ***
	additional_stacks = 2

/datum/xeno_caste/sentinel/ancient
	upgrade_name = "Ancient"
	caste_desc = "Neurotoxin Factory, don't let it get you."
	ancient_message = "We are the stun master. We will take down any opponent."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 16

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 650
	plasma_gain = 21

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 26, BULLET = 26, LASER = 26, ENERGY = 26, BOMB = 0, BIO = 25, FIRE = 26, ACID = 25)

	// *** Ranged Attack *** //
	spit_delay = 1.0 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/toxic_spit/upgrade3)

	// *** Sentinel Abilities ***
	additional_stacks = 3

/datum/xeno_caste/sentinel/primordial
	upgrade_name = "Primordial"
	caste_desc = "A doctors worst nightmare. It's stinger drips with poison."
	ancient_message = "All will succumb to our toxins. Leave noone standing."
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 16

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 650
	plasma_gain = 21

	// *** Health *** //
	max_health = 300

	// *** Defense *** //
	soft_armor = list(MELEE = 26, BULLET = 26, LASER = 26, ENERGY = 26, BOMB = 0, BIO = 25, FIRE = 26, ACID = 25)

	// *** Ranged Attack *** //
	spit_delay = 1.0 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/toxic_spit/upgrade3)

	// *** Sentinel Abilities ***
	additional_stacks = 3

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/corrosive_acid/drone,
		/datum/action/xeno_action/activable/xeno_spit/toxic_spit,
		/datum/action/xeno_action/toxic_slash,
		/datum/action/xeno_action/activable/drain_sting,
		/datum/action/xeno_action/activable/toxic_grenade,
	)
