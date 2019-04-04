/datum/xeno_caste/ravager
	caste_name = "Ravager"
	display_name = "Ravager"
	upgrade_name = ""
	caste_desc = "A brutal, devastating front-line attacker."
	caste_type_path = /mob/living/carbon/Xenomorph/Ravager
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage_lower = 40
	melee_damage_upper = 60
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

	deevolves_to = /mob/living/carbon/Xenomorph/Hunter

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor_deflection = 20

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

	// *** Ranged Attack *** //
	charge_type = 3 //Claw at end of charge

/datum/xeno_caste/ravager/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/ravager/mature
	upgrade_name = "Mature"
	caste_desc = "A brutal, devastating front-line attacker. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage_lower = 50
	melee_damage_upper = 70

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
	armor_deflection = 25

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

/datum/xeno_caste/ravager/elder
	upgrade_name = "Elder"
	caste_desc = "A brutal, devastating front-line attacker. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage_lower = 55
	melee_damage_upper = 75

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
	armor_deflection = 28

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

/datum/xeno_caste/ravager/ancient
	upgrade_name = "Ancient"
	caste_desc = "As I walk through the valley of the shadow of death."
	ancient_message = "You are death incarnate. All will tremble before you."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage_lower = 60
	melee_damage_upper = 80

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
	armor_deflection = 30

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.
	