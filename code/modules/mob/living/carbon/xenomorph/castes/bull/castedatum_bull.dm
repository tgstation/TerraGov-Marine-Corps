/datum/xeno_caste/bull
	caste_name = "Bull"
	display_name = "Bull"
	upgrade_name = ""
	caste_desc = "A well defended hit-and-runner."
	caste_type_path = /mob/living/carbon/xenomorph/bull
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "bull" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 19

	// *** Speed *** //
	speed = -0.7

	// *** Plasma *** //
	plasma_max = 200 //High plasma is need for charging
	plasma_gain = 10

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	evolution_threshold = 180
	upgrade_threshold = 120

	evolves_to = list(/mob/living/carbon/xenomorph/crusher)
	deevolves_to = /mob/living/carbon/xenomorph/runner

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CAN_BECOME_KING

	// *** Defense *** //
	soft_armor = list("melee" = 25, "bullet" = 35, "laser" = 25, "energy" = 25, "bomb" = XENO_BOMB_RESIST_0, "bio" = 25, "rad" = 25, "fire" = 35, "acid" = 25)

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/headbite,
		/datum/action/xeno_action/activable/devour,
		/datum/action/xeno_action/ready_charge/bull_charge,
		/datum/action/xeno_action/activable/bull_charge,
		/datum/action/xeno_action/activable/bull_charge/headbutt,
		/datum/action/xeno_action/activable/bull_charge/gore,
	)

/datum/xeno_caste/bull/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/bull/mature
	upgrade_name = "Mature"
	caste_desc = "A bright red alien with a matching temper. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.7

	// *** Plasma *** //
	plasma_max = 250
	plasma_gain = 13

	// *** Health *** //
	max_health = 275

	// *** Evolution *** //
	upgrade_threshold = 360

	// *** Defense *** //
	soft_armor = list("melee" = 30, "bullet" = 40, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_0, "bio" = 28, "rad" = 28, "fire" = 40, "acid" = 28)

/datum/xeno_caste/bull/elder
	upgrade_name = "Elder"
	caste_desc = "A bright red alien with a matching temper. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 21

	// *** Speed *** //
	speed = -0.7

	// *** Plasma *** //
	plasma_max = 260
	plasma_gain = 16

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 840

	// *** Defense *** //
	soft_armor = list("melee" = 35, "bullet" = 45, "laser" = 35, "energy" = 35, "bomb" = XENO_BOMB_RESIST_0, "bio" = 30, "rad" = 30, "fire" = 45, "acid" = 30)

/datum/xeno_caste/bull/ancient
	upgrade_name = "Ancient"
	caste_desc = "The only red it will be seeing is your blood."
	ancient_message = "We are strong, nothing can stand in our way lest we topple them."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 21

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 270
	plasma_gain = 18

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = 1320

	// *** Defense *** //
	soft_armor = list("melee" = 40, "bullet" = 50, "laser" = 40, "energy" = 40, "bomb" = XENO_BOMB_RESIST_0, "bio" = 33, "rad" = 33, "fire" = 50, "acid" = 33)
