/datum/xeno_caste/boiler
	caste_name = "Boiler"
	display_name = "Boiler"
	upgrade_name = ""
	caste_desc = "Gross!"

	caste_type_path = /mob/living/carbon/xenomorph/boiler

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "boiler" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 22.5

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = 0.6

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 30

	// *** Health *** //
	max_health = 230

	// *** Evolution *** //
	upgrade_threshold = 200

	deevolves_to = /mob/living/carbon/xenomorph/spitter

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_ACID_BLOOD

	// *** Defense *** //
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_0, "bio" = 30, "rad" = 30, "fire" = 15, "acid" = 30)

	// *** Ranged Attack *** //
	spit_delay = 4 SECONDS

	// *** Boiler Abilities *** //
	max_ammo = 4
	bomb_strength = 1 //Multiplier to the effectiveness of the boiler glob.
	acid_delay = 9 SECONDS
	bomb_delay = 25 SECONDS

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/create_boiler_bomb,
		/datum/action/xeno_action/activable/bombard,
		/datum/action/xeno_action/toggle_long_range,
		/datum/action/xeno_action/toggle_bomb,
		/datum/action/xeno_action/activable/spray_acid/line/boiler
		)

/datum/xeno_caste/boiler/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/boiler/mature
	upgrade_name = "Mature"
	caste_desc = "Some sort of abomination. It looks a little more dangerous."
	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 27.5

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = 0.5

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 35

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor = list("melee" = 33, "bullet" = 33, "laser" = 33, "energy" = 33, "bomb" = XENO_BOMB_RESIST_0, "bio" = 33, "rad" = 33, "fire" = 20, "acid" = 33)

	// *** Ranged Attack *** //
	spit_delay = 3 SECONDS

	// *** Boiler Abilities *** //
	max_ammo = 5
	bomb_strength = 1.1
	acid_delay = 9 SECONDS
	bomb_delay = 25 SECONDS

/datum/xeno_caste/boiler/elder
	upgrade_name = "Elder"
	caste_desc = "Some sort of abomination. It looks pretty strong."
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 32.5

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = 0.4

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 40

	// *** Health *** //
	max_health = 270

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor = list("melee" = 35, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = XENO_BOMB_RESIST_0, "bio" = 35, "rad" = 35, "fire" = 22, "acid" = 35)

	// *** Ranged Attack *** //
	spit_delay = 2 SECONDS

	// *** Boiler Abilities *** //
	max_ammo = 6
	bomb_strength = 1.2
	acid_delay = 9 SECONDS
	bomb_delay = 25 SECONDS

/datum/xeno_caste/boiler/ancient
	upgrade_name = "Ancient"
	caste_desc = "A devestating piece of alien artillery."
	upgrade = XENO_UPGRADE_THREE
	ancient_message = "We are the master of ranged artillery. Let's bring death from above."

	// *** Melee Attacks *** //
	melee_damage = 37.5

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = 0.3

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 300

	// *** Defense *** //
	armor = list("melee" = 37, "bullet" = 37, "laser" = 37, "energy" = 37, "bomb" = XENO_BOMB_RESIST_0, "bio" = 37, "rad" = 37, "fire" = 25, "acid" = 37)

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS

	// *** Boiler Abilities *** //
	max_ammo = 7
	bomb_strength = 1.3
	acid_delay = 9 SECONDS
	bomb_delay = 20 SECONDS
