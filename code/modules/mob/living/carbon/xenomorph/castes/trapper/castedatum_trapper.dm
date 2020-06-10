/datum/xeno_caste/trapper
	caste_name = "Trapper"
	display_name = "Trapper"
	upgrade_name = ""
	caste_desc = "A monster that is geared towards setting up for the future."
	caste_type_path = /mob/living/carbon/xenomorph/trapper
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "runner" //used to match appropriate wound overlays

	gib_anim = "gibbed-a-corpse-runner"
	gib_flick = "gibbed-a-runner"

	// *** Melee Attacks *** //
	melee_damage = 10

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 25

	// *** Health *** //
	max_health = 100

	// *** Evolution *** //
	evolution_threshold = 80
	upgrade_threshold = 60

	evolves_to = list(/mob/living/carbon/xenomorph/carrier, /mob/living/carbon/xenomorph/Defiler, /mob/living/carbon/xenomorph/drone)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = XENO_BOMB_RESIST_0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	// *** Ranged Attack *** //
	//NONE

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/place_trap,
		/datum/action/xeno_action/tripwire,
		/datum/action/xeno_action/blurrer,
		/datum/action/xeno_action/sensor,
		)

/datum/xeno_caste/trapper/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/trapper/mature
	upgrade_name = "Mature"
	caste_desc = "A monster that is geared towards setting up for the future. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 15

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -1.0

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 30

	// *** Health *** //
	max_health = 150

	// *** Evolution *** //
	upgrade_threshold = 120

	// *** Defense *** //
	soft_armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = XENO_BOMB_RESIST_0, "bio" = 5, "rad" = 5, "fire" = 5, "acid" = 5)

	// *** Ranged Attack *** //
	//NONE

/datum/xeno_caste/trapper/elder
	upgrade_name = "Elder"
	caste_desc = "A monster that is geared towards setting up for the future. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -1.2

	// *** Plasma *** //
	plasma_max = 700
	plasma_gain = 35

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	upgrade_threshold = 240

	// *** Defense *** //
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = XENO_BOMB_RESIST_0, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)

	// *** Ranged Attack *** //
	//NONE

/datum/xeno_caste/trapper/ancient
	upgrade_name = "Ancient"
	caste_desc = "It has taken all the time it needs. Once you've seen it, it is over."
	ancient_message = "We have taken precautions and have become an apex predator."
	upgrade = XENO_UPGRADE_THREE
	wound_type = "runner" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 25

	// *** Tackle *** //
	tackle_damage = 45

	// *** Speed *** //
	speed = -1.4

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 40

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 240

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)

	// *** Ranged Attack *** //
	//NONE

