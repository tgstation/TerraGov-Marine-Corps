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
	soft_armor = list("melee" = 10, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 0, "bio" = 10, "rad" = 10, "fire" = 20, "acid" = 10)

	// *** Minimap Icon *** //
	minimap_icon = "spitter"

	// *** Ranged Attack *** //
	spit_delay = 0.8 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/medium) //Gotta give them their own version of heavy acid; kludgy but necessary as 100 plasma is way too costly.

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
	soft_armor = list("melee" = 15, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = 0, "bio" = 15, "rad" = 15, "fire" = 25, "acid" = 15)

	// *** Ranged Attack *** //
	spit_delay = 0.7 SECONDS



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
	soft_armor = list("melee" = 20, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 0, "bio" = 18, "rad" = 18, "fire" = 30, "acid" = 18)

	// *** Ranged Attack *** //
	spit_delay = 0.6 SECONDS



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
	soft_armor = list("melee" = 25, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = 0, "bio" = 20, "rad" = 20, "fire" = 35, "acid" = 20)

	// *** Ranged Attack *** //
	spit_delay = 0.5 SECONDS

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
	soft_armor = list("melee" = 25, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = 0, "bio" = 20, "rad" = 20, "fire" = 35, "acid" = 20)

	// *** Ranged Attack *** //
	spit_delay = 0.3 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/auto, /datum/ammo/xeno/acid/medium)
