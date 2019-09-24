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
	melee_damage = 50
	attack_delay = 7

	// *** Tackle *** //
	tackle_damage = 55

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 10

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	upgrade_threshold = 400

	deevolves_to = /mob/living/carbon/xenomorph/hunter

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = XENO_BOMB_RESIST_1, "bio" = 20, "rad" = 20, "fire" = 40, "acid" = 20)

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

	// *** Ranged Attack *** //
	charge_type = 3 //Claw at end of charge

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/charge,
		/datum/action/xeno_action/activable/ravage,
		/datum/action/xeno_action/second_wind,
		)

/datum/xeno_caste/ravager/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/ravager/mature
	upgrade_name = "Mature"
	caste_desc = "A brutal, devastating front-line attacker. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 60

	// *** Tackle *** //
	tackle_damage = 60

	// *** Speed *** //
	speed = -0.55

	// *** Plasma *** //
	plasma_max = 175
	plasma_gain = 13

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = XENO_BOMB_RESIST_1, "bio" = 25, "rad" = 25, "fire" = 50, "acid" = 25)

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

/datum/xeno_caste/ravager/elder
	upgrade_name = "Elder"
	caste_desc = "A brutal, devastating front-line attacker. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 65

	// *** Tackle *** //
	tackle_damage = 65

	// *** Speed *** //
	speed = -0.58

	// *** Plasma *** //
	plasma_max = 190
	plasma_gain = 14

	// *** Health *** //
	max_health = 260

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor = list("melee" = 28, "bullet" = 28, "laser" = 28, "energy" = 28, "bomb" = XENO_BOMB_RESIST_1, "bio" = 28, "rad" = 28, "fire" = 56, "acid" = 28)

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

/datum/xeno_caste/ravager/ancient
	upgrade_name = "Ancient"
	caste_desc = "As I walk through the valley of the shadow of death."
	ancient_message = "We are death incarnate. All will tremble before us."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 70

	// *** Tackle *** //
	tackle_damage = 70

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 15

	// *** Health *** //
	max_health = 265

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_1, "bio" = 30, "rad" = 30, "fire" = 60, "acid" = 30)

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.
	
