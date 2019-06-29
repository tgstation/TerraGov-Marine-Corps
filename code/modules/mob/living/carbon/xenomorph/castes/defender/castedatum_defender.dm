/datum/xeno_caste/defender
	caste_name = "Defender"
	display_name = "Defender"
	upgrade_name = ""
	caste_desc = "A sturdy front line combatant."

	caste_type_path = /mob/living/carbon/xenomorph/defender

	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "defender" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage_lower = 15
	melee_damage_upper = 25

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 10

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	evolution_threshold = 100
	upgrade_threshold = 100

	evolves_to = list(/mob/living/carbon/xenomorph/warrior)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor_deflection = 20

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_LARGE 

	// *** Defender Abilities *** //
	crest_defense_armor = 35
	fortify_armor = 70

/datum/xeno_caste/defender/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/defender/mature
	upgrade_name = "Mature"
	caste_desc = "An alien with an armored head crest. It looks a little more dangerous."
	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 30

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 175
	plasma_gain = 13

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Defense *** //
	armor_deflection = 25

	// *** Defender Abilities *** //
	crest_defense_armor = 40
	fortify_armor = 80

/datum/xeno_caste/defender/elder
	upgrade_name = "Elder"
	caste_desc = "An alien with an armored head crest. It looks pretty strong."
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage_lower = 23
	melee_damage_upper = 33

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 190
	plasma_gain = 14

	// *** Health *** //
	max_health = 260

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 28

	// *** Defender Abilities *** //
	crest_defense_armor = 43
	fortify_armor = 87

/datum/xeno_caste/defender/ancient
	upgrade_name = "Ancient"
	caste_desc = "An unstoppable force that remains when others would fall."
	upgrade = XENO_UPGRADE_THREE
	ancient_message = "We are a incredibly resilient, we can control the battle through sheer force."

	// *** Melee Attacks *** //
	melee_damage_lower = 26
	melee_damage_upper = 36

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 15

	// *** Health *** //
	max_health = 270

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 30

	// *** Defender Abilities *** //
	crest_defense_armor = 45
	fortify_armor = 90
