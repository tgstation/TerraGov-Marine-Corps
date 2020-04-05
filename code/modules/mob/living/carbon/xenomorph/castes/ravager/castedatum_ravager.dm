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
	melee_damage = 40
	attack_delay = 7

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 20

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	upgrade_threshold = 200

	deevolves_to = /mob/living/carbon/xenomorph/hunter

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_1, "bio" = 30, "rad" = 30, "fire" = 15, "acid" = 30)

	// *** Ranged Attack *** //
	charge_type = 3 //Claw at end of charge

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/charge,
		/datum/action/xeno_action/activable/ravage
		)

/datum/xeno_caste/ravager/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/ravager/mature
	upgrade_name = "Mature"
	caste_desc = "A brutal, devastating front-line attacker. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 43

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 500 //Enables using either both abilities at once or one after another
	plasma_gain = 30

	// *** Health *** //
	max_health = 265

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor = list("melee" = 35, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = XENO_BOMB_RESIST_1, "bio" = 35, "rad" = 35, "fire" = 20, "acid" = 35)

/datum/xeno_caste/ravager/elder
	upgrade_name = "Elder"
	caste_desc = "A brutal, devastating front-line attacker. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 48

	// *** Tackle *** //
	tackle_damage = 45

	// *** Speed *** //
	speed = -0.97

	// *** Plasma *** //
	plasma_max = 550
	plasma_gain = 35

	// *** Health *** //
	max_health = 290

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor = list("melee" = 38, "bullet" = 38, "laser" = 38, "energy" = 38, "bomb" = XENO_BOMB_RESIST_1, "bio" = 38, "rad" = 38, "fire" = 25, "acid" = 38)

/datum/xeno_caste/ravager/ancient
	upgrade_name = "Ancient"
	caste_desc = "As I walk through the valley of the shadow of death."
	ancient_message = "We are death incarnate. All will tremble before us."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 50

	// *** Tackle *** //
	tackle_damage = 50

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 40

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = XENO_BOMB_RESIST_1, "bio" = 40, "rad" = 40, "fire" = 28, "acid" = 40)
