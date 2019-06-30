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
	melee_damage_lower = 30
	melee_damage_upper = 35

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 80
	plasma_gain = 8

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	evolution_threshold = 200
	upgrade_threshold = 200

	evolves_to = list(/mob/living/carbon/xenomorph/crusher)
	deevolves_to = /mob/living/carbon/xenomorph/defender

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor_deflection = 40

	// *** Warrior Abilities *** //
	agility_speed_increase = 0

/datum/xeno_caste/warrior/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/warrior/mature
	upgrade_name = "Mature"
	caste_desc = "An alien with an armored carapace. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage_lower = 35
	melee_damage_upper = 45

	// *** Tackle *** //
	tackle_damage = 50

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 10

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 50

	// *** Warrior Abilities *** //

/datum/xeno_caste/warrior/elder
	upgrade_name = "Elder"
	caste_desc = "An alien with an armored carapace. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage_lower = 40
	melee_damage_upper = 45

	// *** Tackle *** //
	tackle_damage = 53

	// *** Speed *** //
	speed = -0.45

	// *** Plasma *** //
	plasma_max = 115
	plasma_gain = 11

	// *** Health *** //
	max_health = 260

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 50

	// *** Warrior Abilities *** //
	agility_speed_increase = 0

/datum/xeno_caste/warrior/ancient
	upgrade_name = "Ancient"
	caste_desc = "An hulking beast capable of effortlessly breaking and tearing through its enemies."
	ancient_message = "None can stand before us. We will annihilate all weaklings who try."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage_lower = 45
	melee_damage_upper = 50

	// *** Tackle *** //
	tackle_damage = 55

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 120
	plasma_gain = 12

	// *** Health *** //
	max_health = 270

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 55

	// *** Warrior Abilities *** //
	agility_speed_increase = 0
