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
	melee_damage = 17

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 10

	// *** Health *** //
	max_health = 260

	// *** Evolution *** //
	evolution_threshold = 80
	upgrade_threshold = TIER_ONE_YOUNG_THRESHOLD

	evolves_to = list(/mob/living/carbon/xenomorph/warrior)

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING

	// *** Defense *** //
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 25, ENERGY = 20, BOMB = 20, BIO = 20, "rad" = 20, FIRE = 30, ACID = 20)

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_LARGE

	// *** Minimap Icon *** //
	minimap_icon = "defender"

	// *** Defender Abilities *** //
	crest_defense_armor = 22
	crest_defense_slowdown = 0.8
	fortify_armor = 50

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/toggle_crest_defense,
		/datum/action/xeno_action/fortify,
		/datum/action/xeno_action/activable/forward_charge,
		/datum/action/xeno_action/tail_sweep,
		/datum/action/xeno_action/regenerate_skin,
	)

/datum/xeno_caste/defender/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/defender/mature
	upgrade_name = "Mature"
	caste_desc = "An alien with an armored crest. It looks pretty durable."
	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 175
	plasma_gain = 13

	// *** Health *** //
	max_health = 280

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 33, BULLET = 33, LASER = 28, ENERGY = 25, BOMB = 20
	, BIO = 25, "rad" = 25, FIRE = 33, ACID = 25)

	// *** Defender Abilities *** //
	crest_defense_armor = 26
	crest_defense_slowdown = 0.8
	fortify_armor = 52

/datum/xeno_caste/defender/elder
	upgrade_name = "Elder"
	caste_desc = "An alien with a heavily armored head crest. It looks very tough."
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 21

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 190
	plasma_gain = 14

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 35, BULLET = 35, LASER = 30, ENERGY = 28, BOMB = 20, BIO = 28, "rad" = 28, FIRE = 35, ACID = 28)

	// *** Defender Abilities *** //
	crest_defense_armor = 30
	crest_defense_slowdown = 0.8
	fortify_armor = 55

/datum/xeno_caste/defender/ancient
	upgrade_name = "Ancient"
	caste_desc = "An alien with a heavily armored head crest. It looks like it could stop bullets!"
	upgrade = XENO_UPGRADE_THREE
	ancient_message = "We are incredibly resilient, we can control the battle through sheer force."

	// *** Melee Attacks *** //
	melee_damage = 21

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 15

	// *** Health *** //
	max_health = 320

	// *** Evolution *** //
	upgrade_threshold = TIER_ONE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 20, BIO = 30, "rad" = 30, FIRE = 40, ACID = 30)

	// *** Defender Abilities *** //
	crest_defense_armor = 30
	crest_defense_slowdown = 0.8
	fortify_armor = 55

/datum/xeno_caste/defender/primordial
	upgrade_name = "Primordial"
	caste_desc = "Alien with an incredibly tough and armored head crest able to endure even the strongest hits."
	upgrade = XENO_UPGRADE_FOUR
	primordial_message = "We are the aegis of the hive. Let nothing pierce our guard."

	// *** Melee Attacks *** //
	melee_damage = 21

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 15

	// *** Health *** //
	max_health = 320

	// *** Defense *** //
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 20, BIO = 30, "rad" = 30, FIRE = 40, ACID = 30)

	// *** Defender Abilities *** //
	crest_defense_armor = 30
	crest_defense_slowdown = 0.8
	fortify_armor = 55

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/toggle_crest_defense,
		/datum/action/xeno_action/fortify,
		/datum/action/xeno_action/activable/forward_charge,
		/datum/action/xeno_action/tail_sweep,
		/datum/action/xeno_action/regenerate_skin,
		/datum/action/xeno_action/centrifugal_force,
	)
