/datum/xeno_caste/ravager
	caste_name = "Ravager"
	display_name = "Ravager"
	upgrade_name = ""
	caste_desc = "A brutal, devastating front-line attacker."
	caste_type_path = /mob/living/carbon/xenomorph/ravager
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "ravager" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 26
	attack_delay = 7

	// *** Tackle *** //
	tackle_damage = 26

	// *** Speed *** //
	speed = -0.7

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 20

	// *** Health *** //
	max_health = 290

	// *** Evolution *** //
	upgrade_threshold = 250

	deevolves_to = /mob/living/carbon/xenomorph/hunter

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 35, "bullet" = 40, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_1, "bio" = 30, "rad" = 30, "fire" = 50, "acid" = 30)

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_LARGE

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/charge,
		/datum/action/xeno_action/activable/ravage,
		/datum/action/xeno_action/activable/ignore_pain,
	)

/datum/xeno_caste/ravager/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/ravager/mature
	upgrade_name = "Mature"
	caste_desc = "A brutal, devastating front-line attacker. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Tackle *** //
	tackle_damage = 26

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 700 //Enables using either both abilities at once or one after another
	plasma_gain = 30

	// *** Health *** //
	max_health = 310

	// *** Evolution *** //
	upgrade_threshold = 500

	// *** Defense *** //
	soft_armor = list("melee" = 40, "bullet" = 45, "laser" = 40, "energy" = 40, "bomb" = XENO_BOMB_RESIST_1, "bio" = 35, "rad" = 35, "fire" = 55, "acid" = 35)

/datum/xeno_caste/ravager/elder
	upgrade_name = "Elder"
	caste_desc = "A brutal, devastating front-line attacker. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 32

	// *** Tackle *** //
	tackle_damage = 32

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 750
	plasma_gain = 35

	// *** Health *** //
	max_health = 330

	// *** Evolution *** //
	upgrade_threshold = 1000

	// *** Defense *** //
	soft_armor = list("melee" = 45, "bullet" = 50, "laser" = 45, "energy" = 45, "bomb" = XENO_BOMB_RESIST_1, "bio" = 38, "rad" = 38, "fire" = 65, "acid" = 38)

/datum/xeno_caste/ravager/ancient
	upgrade_name = "Ancient"
	caste_desc = "As I walk through the valley of the shadow of death."
	ancient_message = "We are death incarnate. All will tremble before us."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 32

	// *** Tackle *** //
	tackle_damage = 32

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 40

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = 1000

	// *** Defense *** //
	soft_armor = list("melee" = 50, "bullet" = 55, "laser" = 50, "energy" = 50, "bomb" = XENO_BOMB_RESIST_1, "bio" = 40, "rad" = 40, "fire" = 70, "acid" = 40)
