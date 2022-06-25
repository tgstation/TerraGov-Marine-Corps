/datum/xeno_caste/sentinel
	caste_name = "Sentinel"
	display_name = "Sentinel"
	upgrade_name = ""
	caste_desc = "A weak ranged combat alien."
	caste_type_path = /mob/living/carbon/xenomorph/sentinel
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 16

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 10

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	evolution_threshold = 80
	upgrade_threshold = TIER_ONE_YOUNG_THRESHOLD

	evolves_to = list(/mob/living/carbon/xenomorph/spitter)

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING|CASTE_CAN_RIDE_CRUSHER

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 0, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin, /datum/ammo/xeno/acid)

	// *** Minimap Icon *** //
	minimap_icon = "sentinel"

	// *** Abilities *** //
	actions = list\(
		/datum/action/xeno_action/show_hivestatus,
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/corrosive_acid/drone,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/neurotox_sting,
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
	plasma_max = 450
	plasma_gain = 15

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 0, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 20)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/upgrade1, /datum/ammo/xeno/acid)

/datum/xeno_caste/sentinel/elder
	upgrade_name = "Elder"
	caste_desc = "A ranged combat alien. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 17

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 550
	plasma_gain = 18

	// *** Health *** //
	max_health = 275

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 23, "bullet" = 23, "laser" = 23, "energy" = 23, "bomb" = 0, "bio" = 23, "rad" = 23, "fire" = 23, "acid" = 23)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/upgrade2, /datum/ammo/xeno/acid)

/datum/xeno_caste/sentinel/ancient
	upgrade_name = "Ancient"
	caste_desc = "Neurotoxin Factory, don't let it get you."
	ancient_message = "We are the stun master. We will take down any opponent."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 17

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 20

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 26, "bullet" = 26, "laser" = 26, "energy" = 26, "bomb" = 0, "bio" = 25, "rad" = 25, "fire" = 26, "acid" = 25)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/upgrade3, /datum/ammo/xeno/acid)



/datum/xeno_caste/sentinel/primordial
	upgrade_name = "Primordial"
	caste_desc = "A doctors worst nightmare. It's stinger drips with poison."
	ancient_message = "All will succumb to our toxins. Leave noone standing."
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 17

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 20

	// *** Health *** //
	max_health = 300

	// *** Defense *** //
	soft_armor = list("melee" = 26, "bullet" = 26, "laser" = 26, "energy" = 26, "bomb" = 0, "bio" = 25, "rad" = 25, "fire" = 26, "acid" = 25)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/upgrade3, /datum/ammo/xeno/acid)

	actions = list\(
		/datum/action/xeno_action/show_hivestatus,
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/corrosive_acid/drone,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/neurotox_sting,
		/datum/action/xeno_action/activable/neurogas_grenade,
	)
