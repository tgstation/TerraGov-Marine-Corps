/datum/xeno_caste/spitter
	caste_name = "Spitter"
	display_name = "Spitter"
	upgrade_name = ""
	caste_desc = "Ptui!"
	caste_type_path = /mob/living/carbon/Xenomorph/Spitter
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "alien" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage_lower = 18
	melee_damage_upper = 28

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 650
	plasma_gain = 21

	// *** Health *** //
	max_health = 180

	// *** Evolution *** //
	evolution_threshold = 200
	upgrade_threshold = 200

	evolves_to = list(/mob/living/carbon/Xenomorph/Boiler, /mob/living/carbon/Xenomorph/Praetorian)
	deevolves_to = /mob/living/carbon/Xenomorph/Sentinel

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor_deflection = 10

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/heavy) //Gotta give them their own version of heavy acid; kludgy but necessary as 100 plasma is way too costly.

	acid_delay = 30 SECONDS //30 second delay on acid spray.

/datum/xeno_caste/spitter/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/spitter/mature
	upgrade_name = "Mature"
	caste_desc = "A ranged damage dealer. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage_lower = 25
	melee_damage_upper = 35

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 25

	// *** Health *** //
	max_health = 220

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 15

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS

	acid_delay = 30 SECONDS //30 second delay on acid spray.

/datum/xeno_caste/spitter/elder
	upgrade_name = "Elder"
	caste_desc = "A ranged damage dealer. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage_lower = 28
	melee_damage_upper = 38

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -0.7

	// *** Plasma *** //
	plasma_max = 875
	plasma_gain = 28

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 18

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS

	acid_delay = 30 SECONDS //30 second delay on acid spray.

/datum/xeno_caste/spitter/ancient
	upgrade_name = "Ancient"
	caste_desc = "A ranged destruction machine."
	ancient_message = "You are a master of ranged stuns and damage. Go fourth and generate salt."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage_lower = 30
	melee_damage_upper = 40

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 925
	plasma_gain = 30

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 20

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS

	acid_delay = 30 SECONDS //30 second delay on acid spray.
	
