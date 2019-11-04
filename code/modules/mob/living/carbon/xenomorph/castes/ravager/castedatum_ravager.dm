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
	plasma_max = 150
	plasma_gain = 10

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	upgrade_threshold = 400

	deevolves_to = /mob/living/carbon/xenomorph/hunter

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor = list("melee" = 45, "bullet" = 45, "laser" = 45, "energy" = 45, "bomb" = XENO_BOMB_RESIST_1, "bio" = 45, "rad" = 45, "fire" = 45, "acid" = 45)

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

	// *** Ranged Attack *** //
	charge_type = 3 //Claw at end of charge

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/charge,
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
	plasma_max = 175
	plasma_gain = 13

	// *** Health *** //
	max_health = 275

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor = list("melee" = 55, "bullet" = 55, "laser" = 55, "energy" = 55, "bomb" = XENO_BOMB_RESIST_2, "bio" = 55, "rad" = 55, "fire" = 55, "acid" = 55)

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

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
	plasma_max = 190
	plasma_gain = 14

	// *** Health *** //
	max_health = 290

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor = list("melee" = 58, "bullet" = 58, "laser" = 58, "energy" = 58, "bomb" = XENO_BOMB_RESIST_2, "bio" = 58, "rad" = 58, "fire" = 58, "acid" = 58)

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

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
	plasma_max = 200
	plasma_gain = 15

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 60, "bomb" = XENO_BOMB_RESIST_2, "bio" = 60, "rad" = 60, "fire" = 60, "acid" = 60)

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

