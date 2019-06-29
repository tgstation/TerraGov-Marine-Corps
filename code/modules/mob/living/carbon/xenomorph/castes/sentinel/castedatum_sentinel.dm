/datum/xeno_caste/sentinel
	caste_name = "Sentinel"
	display_name = "Sentinel"
	upgrade_name = ""
	caste_desc = "A weak ranged combat alien."
	caste_type_path = /mob/living/carbon/xenomorph/sentinel
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage_lower = 15
	melee_damage_upper = 25

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 10

	// *** Health *** //
	max_health = 150

	// *** Evolution *** //
	evolution_threshold = 100
	upgrade_threshold = 100

	evolves_to = list(/mob/living/carbon/xenomorph/spitter)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor_deflection = 15

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin)

/datum/xeno_caste/sentinel/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/sentinel/mature
	upgrade_name = "Mature"
	caste_desc = "A ranged combat alien. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 30

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -0.95

	// *** Plasma *** //
	plasma_max = 450
	plasma_gain = 15

	// *** Health *** //
	max_health = 180

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Defense *** //
	armor_deflection = 20

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/upgrade1)

/datum/xeno_caste/sentinel/elder
	upgrade_name = "Elder"
	caste_desc = "A ranged combat alien. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage_lower = 23
	melee_damage_upper = 33

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -1.05

	// *** Plasma *** //
	plasma_max = 550
	plasma_gain = 18

	// *** Health *** //
	max_health = 190

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 23

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/upgrade2)

/datum/xeno_caste/sentinel/ancient
	upgrade_name = "Ancient"
	caste_desc = "Neurotoxin Factory, don't let it get you."
	ancient_message = "We are the stun master. Our stunning is legendary and causes massive quantities of salt."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage_lower = 25
	melee_damage_upper = 35

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -1.1

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 20

	// *** Health *** //
	max_health = 195

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 25

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/upgrade3)
	