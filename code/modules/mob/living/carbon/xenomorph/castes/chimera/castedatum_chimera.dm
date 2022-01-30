/datum/xeno_caste/chimera
	caste_name = "Chimera"
	display_name = "Chimera"
	upgrade_name = ""
	caste_type_path = /mob/living/carbon/xenomorph/chimera
	caste_desc = "A slim, deadly alien creature. It has two additional arms with mantis blades."

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "chimera" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 15

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = 250

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 35, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = XENO_BOMB_RESIST_3, "bio" = 35, "rad" = 35, "fire" = 80, "acid" = 35)

	minimap_icon = "xenoking"

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/chimera_blink,
		/datum/action/xeno_action/select_blink_effect,
		/datum/action/xeno_action/activable/create_wormhole,
		/datum/action/xeno_action/create_forcewall,
		/datum/action/xeno_action/activable/body_swap,
	)


/datum/xeno_caste/chimera/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/chimera/mature
	upgrade_name = "Mature"
	caste_desc = "A slim, deadly alien creature. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 24

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 20

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = 500

	// *** Defense *** //
	soft_armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = XENO_BOMB_RESIST_3, "bio" = 40, "rad" = 40, "fire" = 85, "acid" = 40)

/datum/xeno_caste/chimera/elder
	upgrade_name = "Elder"
	caste_desc = "A slim, deadly alien creature. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 25

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 25

	// *** Health *** //
	max_health = 375

	// *** Evolution *** //
	upgrade_threshold = 1000

	// *** Defense *** //
	soft_armor = list("melee" = 45, "bullet" = 45, "laser" = 45, "energy" = 45, "bomb" = XENO_BOMB_RESIST_3, "bio" = 45, "rad" = 45, "fire" = 90, "acid" = 45)

/datum/xeno_caste/chimera/ancient
	upgrade_name = "Ancient"
	caste_desc = "Apex predator."
	ancient_message = "We are the ultimate killer."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 26

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 30

	// *** Health *** //
	max_health = 400

	// *** Evolution *** //
	upgrade_threshold = 1000

	// *** Defense *** //
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = XENO_BOMB_RESIST_4, "bio" = 50, "rad" = 50, "fire" = 95, "acid" = 50)

/datum/xeno_caste/chimera/primodial
	upgrade_name = "Primodial"
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 26

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 40

	// *** Health *** //
	max_health = 400

	// *** Evolution *** //
	upgrade_threshold = 1000

	// *** Defense *** //
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = XENO_BOMB_RESIST_4, "bio" = 50, "rad" = 50, "fire" = 95, "acid" = 50)
