/datum/xeno_caste/warrior
	caste_name = "Warrior"
	display_name = "Warrior"
	upgrade_name = ""
	caste_desc = "A powerful front line combatant."
	caste_type_path = /mob/living/carbon/xenomorph/warrior
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "warrior" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 80
	plasma_gain = 8

	// *** Health *** //
	max_health = 290

	// *** Evolution *** //
	evolution_threshold = 180
	upgrade_threshold = 120

	evolves_to = list(/mob/living/carbon/xenomorph/crusher)
	deevolves_to = /mob/living/carbon/xenomorph/defender

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_IS_STRONG

	// *** Defense *** //
	soft_armor = list("melee" = 30, "bullet" = 40, "laser" = 40, "energy" = 30, "bomb" = XENO_BOMB_RESIST_2, "bio" = 36, "rad" = 36, "fire" = 40, "acid" = 36)

	// *** Warrior Abilities *** //
	agility_speed_increase = -0.6
	agility_speed_armor = -30

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/toggle_agility,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/fling,
		/datum/action/xeno_action/activable/toss,
		/datum/action/xeno_action/activable/punch,
	)

/datum/xeno_caste/warrior/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/warrior/mature
	upgrade_name = "Mature"
	caste_desc = "An alien with an armored carapace. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 10

	// *** Health *** //
	max_health = 310

	// *** Evolution *** //
	upgrade_threshold = 240

	// *** Defense *** //
	soft_armor = list("melee" = 34, "bullet" = 45, "laser" = 45, "energy" = 34, "bomb" = XENO_BOMB_RESIST_2, "bio" = 36, "rad" = 36, "fire" = 45, "acid" = 36)

	// *** Warrior Abilities *** //
	agility_speed_increase = -0.6
	agility_speed_armor = -30

/datum/xeno_caste/warrior/elder
	upgrade_name = "Elder"
	caste_desc = "An alien with an armored carapace. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Tackle *** //
	tackle_damage = 28

	// *** Speed *** //
	speed = -0.45

	// *** Plasma *** //
	plasma_max = 115
	plasma_gain = 11

	// *** Health *** //
	max_health = 330

	// *** Evolution *** //
	upgrade_threshold = 480

	// *** Defense *** //
	soft_armor = list("melee" = 38, "bullet" = 50, "laser" = 50, "energy" = 38, "bomb" = XENO_BOMB_RESIST_2, "bio" = 40, "rad" = 40, "fire" = 50, "acid" = 40)

	// *** Warrior Abilities *** //
	agility_speed_increase = -0.6
	agility_speed_armor = -30

/datum/xeno_caste/warrior/ancient
	upgrade_name = "Ancient"
	caste_desc = "An hulking beast capable of effortlessly breaking and tearing through its enemies."
	ancient_message = "None can stand before us. We will annihilate all weaklings who try."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Tackle *** //
	tackle_damage = 28

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 120
	plasma_gain = 12

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = 480

	// *** Defense *** //
	soft_armor = list("melee" = 42, "bullet" = 55, "laser" = 55, "energy" = 42, "bomb" = XENO_BOMB_RESIST_2, "bio" = 50, "rad" = 50, "fire" = 55, "acid" = 50)

	// *** Warrior Abilities *** //
	agility_speed_increase = -0.6
	agility_speed_armor = -30
