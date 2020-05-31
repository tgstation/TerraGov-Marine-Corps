/datum/xeno_caste/trapper
	caste_name = "Trapper"
	display_name = "Trapper"
	upgrade_name = ""
	caste_desc = "A sneaky terror capable of placing traps."
	caste_type_path = /mob/living/carbon/xenomorph/trapper
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "runner" //used to match appropriate wound overlays

	gib_anim = "gibbed-a-corpse-runner"
	gib_flick = "gibbed-a-runner"

	// *** Melee Attacks *** //
	melee_damage = 10
	attack_delay = 6


	// *** Tackle *** //
	tackle_damage = 33

	// *** Speed *** //
	speed = 0.5

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 40

	// *** Health *** //
	max_health = 150

	// *** Evolution *** //
	evolution_threshold = 80
	upgrade_threshold = 50

	evolves_to = list(/mob/living/carbon/xenomorph/carrier, /mob/living/carbon/xenomorph/hivelord)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 5, "bomb" = XENO_BOMB_RESIST_0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	// *** Ranged Attack *** //
	//None

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/sensor,
		/datum/action/xeno_action/tripwire,
		/datum/action/xeno_action/build_tunnel,
		/datum/action/xeno_action/place_trap,
		)

/datum/xeno_caste/trapper/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/trapper/mature
	upgrade_name = "Mature"
	caste_desc = "A sneaky terror capable of placing traps."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 14


	// *** Tackle *** //
	tackle_damage = 38

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 650
	plasma_gain = 50

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	upgrade_threshold = 100

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 3, "rad" = 3, "fire" = 3, "acid" = 3)

	// *** Ranged Attack *** //
	pounce_delay = 35.0 SECONDS

/datum/xeno_caste/trapper/elder
	upgrade_name = "Elder"
	caste_desc = "A sneaky terror capable of placing traps."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 17


	// *** Tackle *** //
	tackle_damage = 44

	// *** Speed *** //
	speed = -1.2

	// *** Plasma *** //
	plasma_max = 700
	plasma_gain = 60

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Defense *** //
	soft_armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = XENO_BOMB_RESIST_0, "bio" = 5, "rad" = 5, "fire" = 5, "acid" = 5)

	// *** Ranged Attack *** //
	//None

/datum/xeno_caste/trapper/ancient
	upgrade_name = "Ancient"
	caste_desc = "A sneaky terror capable of placing traps."
	ancient_message = "We are the master at traps. They will know when it's too late"
	upgrade = XENO_UPGRADE_THREE
	wound_type = "runner" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 20


	// *** Tackle *** //
	tackle_damage = 50

	// *** Speed *** //
	speed = -1.4

	// *** Plasma *** //
	plasma_max = 750
	plasma_gain = 70

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Defense *** //
	soft_armor = list("melee" = 24, "bullet" = 24, "laser" = 24, "energy" = 124, "bomb" = XENO_BOMB_RESIST_0, "bio" = 7, "rad" = 7, "fire" = 7, "acid" = 7)

	// *** Ranged Attack *** //
	//None
