/datum/xeno_caste/defiler
	caste_name = "Defiler"
	display_name = "Defiler"
	upgrade_name = ""
	caste_desc = "A frightening looking, bulky xeno that drips with suspect green fluids."

	caste_type_path = /mob/living/carbon/xenomorph/Defiler

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "defiler" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage_lower = 30
	melee_damage_upper = 35

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 14

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 400

	deevolves_to = /mob/living/carbon/xenomorph/carrier

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_VENT_CRAWL

	// *** Defense *** //
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_0, "bio" = 30, "rad" = 30, "fire" = 30, "acid" = 30)

	// *** Defiler Abilities *** //
	neuro_claws_amount = DEFILER_CLAW_AMOUNT

/datum/xeno_caste/defiler/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/defiler/mature
	upgrade_name = "Mature"
	caste_desc = "A frightening looking, bulky xeno that drips with suspect green fluids. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage_lower = 35
	melee_damage_upper = 45

	// *** Tackle *** //
	tackle_damage = 45

	// *** Speed *** //
	speed = -1.1

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 17

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor = list("melee" = 35, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = XENO_BOMB_RESIST_0, "bio" = 35, "rad" = 35, "fire" = 35, "acid" = 35)

	// *** Defiler Abilities *** //
	neuro_claws_amount = 7.5

/datum/xeno_caste/defiler/elder
	upgrade_name = "Elder"
	caste_desc = "A frightening looking, bulky xeno that drips with suspect green fluids. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage_lower = 40
	melee_damage_upper = 45

	// *** Tackle *** //
	tackle_damage = 50

	// *** Speed *** //
	speed = -1.17

	// *** Plasma *** //
	plasma_max = 550
	plasma_gain = 19

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor = list("melee" = 38, "bullet" = 38, "laser" = 38, "energy" = 38, "bomb" = XENO_BOMB_RESIST_0, "bio" = 38, "rad" = 38, "fire" = 38, "acid" = 38)

	// *** Defiler Abilities *** //
	neuro_claws_amount = 8.2

/datum/xeno_caste/defiler/ancient
	upgrade_name = "Ancient"
	caste_desc = "Being within mere eyeshot of this hulking, dripping monstrosity fills you with a deep, unshakeable sense of unease."
	ancient_message = "We are the ultimate alien impregnator. We will infect the marines, see them burst open before us, and hear the gleeful screes of our larvae."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage_lower = 45
	melee_damage_upper = 50

	// *** Tackle *** //
	tackle_damage = 55

	// *** Speed *** //
	speed = -1.2

	// *** Plasma *** //
	plasma_max = 575
	plasma_gain = 20

	// *** Health *** //
	max_health = 340

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = XENO_BOMB_RESIST_0, "bio" = 40, "rad" = 40, "fire" = 40, "acid" = 40)

	// *** Defiler Abilities *** //
	neuro_claws_amount = 8.5
	
