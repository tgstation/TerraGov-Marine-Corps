/datum/xeno_caste/spitter
	caste_name = "Spitter"
	display_name = "Spitter"
	upgrade_name = ""
	caste_desc = "Gotta dodge!"
	caste_type_path = /mob/living/carbon/xenomorph/spitter
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "spitter" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 17

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 650
	plasma_gain = 21

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	evolution_threshold = 180
	upgrade_threshold = TIER_TWO_YOUNG_THRESHOLD

	evolves_to = list(
		/mob/living/carbon/xenomorph/boiler,
		/mob/living/carbon/xenomorph/praetorian,
	)
	deevolves_to = /mob/living/carbon/xenomorph/sentinel

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING|CASTE_CAN_RIDE_CRUSHER

	// *** Defense *** //
	soft_armor = list(MELEE = 10, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 10, "rad" = 10, FIRE = 20, ACID = 10)

	// *** Minimap Icon *** //
	minimap_icon = "spitter"

	// *** Ranged Attack *** //
	spit_delay = 0.8 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/medium, /datum/ammo/xeno/corrosive/upgrade1) //spit types//

	acid_spray_duration = 10 SECONDS
	acid_spray_damage_on_hit = 35
	acid_spray_damage = 16
	acid_spray_structure_damage = 45

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/scatter_spit,
		/datum/action/xeno_action/activable/spray_acid/line,
	)

/datum/xeno_caste/spitter/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/spitter/mature
	upgrade_name = "Mature"
	caste_desc = "A ranged damage dealer. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 25

	// *** Health *** //
	max_health = 270

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 15, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 0, BIO = 15, "rad" = 15, FIRE = 25, ACID = 15)

	// *** Ranged Attack *** //
	spit_delay = 0.7 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/medium, /datum/ammo/xeno/corrosive/upgrade1)


/datum/xeno_caste/spitter/elder
	upgrade_name = "Elder"
	caste_desc = "A ranged damage dealer. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 875
	plasma_gain = 28

	// *** Health *** //
	max_health = 290

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 20, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 18, "rad" = 18, FIRE = 30, ACID = 18)

	// *** Ranged Attack *** //
	spit_delay = 0.6 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/medium, /datum/ammo/xeno/corrosive/upgrade2)


/datum/xeno_caste/spitter/ancient
	upgrade_name = "Ancient"
	caste_desc = "A ranged destruction machine."
	ancient_message = "We are a master of ranged stuns and damage. Go forth and conquer."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 925
	plasma_gain = 30

	// *** Health *** //
	max_health = 310

	// *** Evolution *** //
	upgrade_threshold = TIER_TWO_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 25, BULLET = 35, LASER = 35, ENERGY = 35, BOMB = 0, BIO = 20, "rad" = 20, FIRE = 35, ACID = 20)

	// *** Ranged Attack *** //
	spit_delay = 0.5 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/medium, /datum/ammo/xeno/corrosive/upgrade3)

/datum/xeno_caste/spitter/primordial
	upgrade_name = "Primordial"
	caste_desc = "Master of ranged combat, this xeno knows no equal."
	upgrade = XENO_UPGRADE_FOUR
	primordial_message = "Our suppression is unmatched! Let nothing show its head!"

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 925
	plasma_gain = 30

	// *** Health *** //
	max_health = 310

	// *** Defense *** //
	soft_armor = list(MELEE = 25, BULLET = 35, LASER = 35, ENERGY = 35, BOMB = 0, BIO = 20, "rad" = 20, FIRE = 35, ACID = 20)

	// *** Ranged Attack *** //
	spit_delay = 0.3 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/auto, /datum/ammo/xeno/acid/medium)
