/datum/xeno_caste/crusher
	caste_name = "Crusher"
	display_name = "Crusher"
	upgrade_name = ""
	caste_desc = "A huge tanky xenomorph."
	caste_type_path = /mob/living/carbon/xenomorph/crusher

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "crusher" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 35
	attack_delay = 8.5

	// *** Tackle *** //
	tackle_damage = 55

	// *** RNG Attacks *** //
	tail_chance = 0 //Inherited from old code. Tail's too big

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 10

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 400

	deevolves_to = /mob/living/carbon/xenomorph/warrior

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor_deflection = 80

	// *** Crusher Abilities *** //

/datum/xeno_caste/crusher/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/crusher/mature
	upgrade_name = "Mature"
	caste_desc = "A huge tanky xenomorph. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 35

	// *** Tackle *** //
	tackle_damage = 60

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 15

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = 800

	deevolves_to = /mob/living/carbon/xenomorph/warrior

	// *** Defense *** //
	armor_deflection = 90

/datum/xeno_caste/crusher/elder
	upgrade_name = "Elder"
	caste_desc = "A huge tanky xenomorph. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage_lower = 30
	melee_damage_upper = 40

	// *** Tackle *** //
	tackle_damage = 65

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 30

	// *** Health *** //
	max_health = 340

	// *** Evolution *** //
	upgrade_threshold = 1600

	deevolves_to = /mob/living/carbon/xenomorph/warrior

	// *** Defense *** //
	armor_deflection = 95

/datum/xeno_caste/crusher/ancient
	upgrade_name = "Ancient"
	caste_desc = "It always has the right of way."
	ancient_message = "We are the physical manifestation of a Tank. Almost nothing can harm us."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage_lower = 35
	melee_damage_upper = 45

	// *** Tackle *** //
	tackle_damage = 70

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 30

	// *** Health *** //
	max_health = 350

	deevolves_to = /mob/living/carbon/xenomorph/warrior

	// *** Defense *** //
	armor_deflection = 100
	