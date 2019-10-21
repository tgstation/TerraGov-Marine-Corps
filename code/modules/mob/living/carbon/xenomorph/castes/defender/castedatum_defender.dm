/datum/xeno_caste/defender
	caste_name = "Defender"
	display_name = "Defender"
	upgrade_name = ""
	caste_desc = "An alien with an armored crest. It looks like it's still developing."

	caste_type_path = /mob/living/carbon/xenomorph/defender

	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "defender" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 20

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
	armor = list("melee" = 20, "bullet" = 18, "laser" = 18, "energy" = 20, "bomb" = XENO_BOMB_RESIST_0, "bio" = 20, "rad" = 20, "fire" = 10, "acid" = 20)

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_LARGE

	// *** Defender Abilities *** //
	crest_defense_armor = 22
	fortify_armor = 52

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/toggle_crest_defense,
		/datum/action/xeno_action/fortify,
		/datum/action/xeno_action/activable/forward_charge,
		/datum/action/xeno_action/activable/tail_sweep
		)

/datum/xeno_caste/defender/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/defender/mature
	upgrade_name = "Mature"
	caste_desc = "An alien with an armored crest. It looks pretty durable."
	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 25

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
	armor = list("melee" = 25, "bullet" = 24, "laser" = 24, "energy" = 25, "bomb" = XENO_BOMB_RESIST_0, "bio" = 25, "rad" = 25, "fire" = 12, "acid" = 25)

	// *** Defender Abilities *** //
	crest_defense_armor = 26
	fortify_armor = 61

/datum/xeno_caste/defender/elder
	upgrade_name = "Elder"
	caste_desc = "An alien with a heavily armored head crest. It looks very tough."
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 28

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
	armor = list("melee" = 28, "bullet" = 27, "laser" = 27, "energy" = 28, "bomb" = XENO_BOMB_RESIST_0, "bio" = 28, "rad" = 28, "fire" = 14, "acid" = 28)

	// *** Defender Abilities *** //
	crest_defense_armor = 33
	fortify_armor = 68

/datum/xeno_caste/defender/ancient
	upgrade_name = "Ancient"
	caste_desc = "An alien with a heavily armored head crest. It looks like it could stop bullets!"
	upgrade = XENO_UPGRADE_THREE
	ancient_message = "We are a incredibly resilient, we can control the battle through sheer force."

	// *** Melee Attacks *** //
	melee_damage = 31

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
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_0, "bio" = 30, "rad" = 30, "fire" = 15, "acid" = 30)

	// *** Defender Abilities *** //
	crest_defense_armor = 35
	fortify_armor = 70

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/toggle_crest_defense,
		/datum/action/xeno_action/fortify,
		/datum/action/xeno_action/activable/lunge,
		/datum/action/xeno_action/activable/tail_sweep
		)
