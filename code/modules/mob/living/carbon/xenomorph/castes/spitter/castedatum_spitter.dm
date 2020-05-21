/datum/xeno_caste/spitter
	caste_name = "Spitter"
	display_name = "Spitter"
	upgrade_name = ""
	caste_desc = "Ptui!"
	caste_type_path = /mob/living/carbon/xenomorph/spitter
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage = 25

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 650
	plasma_gain = 21

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	evolution_threshold = 180
	upgrade_threshold = 120

	evolves_to = list(/mob/living/carbon/xenomorph/boiler, /mob/living/carbon/xenomorph/praetorian)
	deevolves_to = /mob/living/carbon/xenomorph/sentinel

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 10, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = XENO_BOMB_RESIST_0, "bio" = 10, "rad" = 10, "fire" = 5, "acid" = 10)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/medium) //Gotta give them their own version of heavy acid; kludgy but necessary as 100 plasma is way too costly.

	acid_delay = 30 SECONDS //30 second delay on acid spray.

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/spray_acid/line,
		)

/datum/xeno_caste/spitter/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/spitter/mature
	upgrade_name = "Mature"
	caste_desc = "A ranged damage dealer. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 27

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 25

	// *** Health *** //
	max_health = 220

	// *** Evolution *** //
	upgrade_threshold = 240

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = XENO_BOMB_RESIST_0, "bio" = 15, "rad" = 15, "fire" = 7, "acid" = 15)

	// *** Ranged Attack *** //
	spit_delay = 1.2 SECONDS

	acid_delay = 30 SECONDS //30 second delay on acid spray.

/datum/xeno_caste/spitter/elder
	upgrade_name = "Elder"
	caste_desc = "A ranged damage dealer. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 30

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 875
	plasma_gain = 28

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	upgrade_threshold = 480

	// *** Defense *** //
	soft_armor = list("melee" = 20, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_0, "bio" = 18, "rad" = 18, "fire" = 10, "acid" = 18)

	// *** Ranged Attack *** //
	spit_delay = 1.1 SECONDS

	acid_delay = 30 SECONDS //30 second delay on acid spray.

/datum/xeno_caste/spitter/ancient
	upgrade_name = "Ancient"
	caste_desc = "A ranged destruction machine."
	ancient_message = "We are a master of ranged stuns and damage. Let's go fourth and generate salt."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 33

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 925
	plasma_gain = 30

	// *** Health *** //
	max_health = 260

	// *** Evolution *** //
	upgrade_threshold = 480

	// *** Defense *** //
	soft_armor = list("melee" = 25, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = XENO_BOMB_RESIST_0, "bio" = 20, "rad" = 20, "fire" = 15, "acid" = 20)

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS

	acid_delay = 30 SECONDS //30 second delay on acid spray.

