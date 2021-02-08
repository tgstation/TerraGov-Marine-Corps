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
	melee_damage = 21
	attack_delay = 8

	// *** Tackle *** //
	tackle_damage = 26

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 10

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = 250

	deevolves_to = /mob/living/carbon/xenomorph/bull

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 70, "bullet" = 60, "laser" = 60, "energy" = 60, "bomb" = XENO_BOMB_RESIST_3, "bio" = 80, "rad" = 80, "fire" = 60, "acid" = 80)

	// *** Crusher Abilities *** //
	stomp_damage = 45
	crest_toss_distance = 4

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/stomp,
		/datum/action/xeno_action/ready_charge,
		/datum/action/xeno_action/activable/cresttoss,
	)

/datum/xeno_caste/crusher/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/crusher/mature
	upgrade_name = "Mature"
	caste_desc = "A huge tanky xenomorph. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Tackle *** //
	tackle_damage = 26

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 15

	// *** Health *** //
	max_health = 345

	// *** Evolution *** //
	upgrade_threshold = 500

	// *** Defense *** //
	soft_armor = list("melee" = 75, "bullet" = 65, "laser" = 65, "energy" = 65, "bomb" = XENO_BOMB_RESIST_3, "bio" = 90, "rad" = 90, "fire" = 65, "acid" = 90)

	// *** Abilities *** //
	stomp_damage = 50

/datum/xeno_caste/crusher/elder
	upgrade_name = "Elder"
	caste_desc = "A huge tanky xenomorph. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 24

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 30

	// *** Health *** //
	max_health = 370

	// *** Evolution *** //
	upgrade_threshold = 1000

	// *** Defense *** //
	soft_armor = list("melee" = 80, "bullet" = 70, "laser" = 70, "energy" = 70, "bomb" = XENO_BOMB_RESIST_3, "bio" = 95, "rad" = 95, "fire" = 70, "acid" = 95)

	// *** Abilities *** //
	stomp_damage = 55

/datum/xeno_caste/crusher/ancient
	upgrade_name = "Ancient"
	caste_desc = "It always has the right of way."
	ancient_message = "We are the physical manifestation of a Tank. Almost nothing can harm us."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 24

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 30

	// *** Health *** //
	max_health = 400

	// *** Defense *** //
	soft_armor = list("melee" = 90, "bullet" = 75, "laser" = 75, "energy" = 75, "bomb" = XENO_BOMB_RESIST_3, "bio" = 100, "rad" = 100, "fire" = 75, "acid" = 100)
	// *** Abilities *** //
	stomp_damage = 60
