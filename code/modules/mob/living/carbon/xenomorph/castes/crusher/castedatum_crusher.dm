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
	melee_damage = 30
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

	deevolves_to = /mob/living/carbon/xenomorph/bull

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor = list("melee" = 80, "bullet" = 40, "laser" = 40, "energy" = 80, "bomb" = XENO_BOMB_RESIST_3, "bio" = 80, "rad" = 80, "fire" = 0, "acid" = 80)

	// *** Crusher Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
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

	// *** Melee Attacks *** //
	melee_damage = 30

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

	// *** Defense *** //
	armor = list("melee" = 90, "bullet" = 45, "laser" = 45, "energy" = 90, "bomb" = XENO_BOMB_RESIST_3, "bio" = 90, "rad" = 90, "fire" = 5, "acid" = 90)

/datum/xeno_caste/crusher/elder
	upgrade_name = "Elder"
	caste_desc = "A huge tanky xenomorph. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 35

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

	// *** Defense *** //
	armor = list("melee" = 95, "bullet" = 47, "laser" = 47, "energy" = 95, "bomb" = XENO_BOMB_RESIST_3, "bio" = 95, "rad" = 95, "fire" = 10, "acid" = 95)

/datum/xeno_caste/crusher/ancient
	upgrade_name = "Ancient"
	caste_desc = "It always has the right of way."
	ancient_message = "We are the physical manifestation of a Tank. Almost nothing can harm us."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 40

	// *** Tackle *** //
	tackle_damage = 70

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 30

	// *** Health *** //
	max_health = 350

	// *** Defense *** //
	armor = list("melee" = 100, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = XENO_BOMB_RESIST_3, "bio" = 100, "rad" = 100, "fire" = 15, "acid" = 100)
	
