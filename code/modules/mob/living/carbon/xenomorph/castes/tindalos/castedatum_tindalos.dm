/datum/xeno_caste/tindalos
	caste_name = "Tindalos"
	display_name = "Tindalos"
	upgrade_name = ""
	caste_desc = "A strange xeno that utilizes its psychic powers to move out of phase with reality."
	caste_type_path = /mob/living/carbon/xenomorph/tindalos
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "screecher" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 17

	// *** Tackle *** //
	tackle_damage = 21

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 15

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	evolution_threshold = 180
	upgrade_threshold = 120

	evolves_to = list(
		/mob/living/carbon/xenomorph/crusher,
		/mob/living/carbon/xenomorph/ravager,
	)
	deevolves_to = /mob/living/carbon/xenomorph/runner

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 20, "energy" = 20, "bomb" = XENO_BOMB_RESIST_0, "bio" = 10, "rad" = 15, "fire" = 15, "acid" = 10)


	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/headbite,
		/datum/action/xeno_action/place_warp_beacon,
		/datum/action/xeno_action/hyperposition,
		/datum/action/xeno_action/phase_shift,
		/datum/action/xeno_action/activable/blink,
		/datum/action/xeno_action/activable/banish,
		/datum/action/xeno_action/recall
	)

/datum/xeno_caste/tindalos/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/tindalos/mature
	upgrade_name = "Mature"
	caste_desc = "A manipulator of space and time. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Tackle *** //
	tackle_damage = 21

	// *** Speed *** //
	speed = -1.1

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 20

	// *** Health *** //
	max_health = 230

	// *** Evolution *** //
	upgrade_threshold = 240

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 25, "energy" = 25, "bomb" = XENO_BOMB_RESIST_0, "bio" = 15, "rad" = 20, "fire" = 20, "acid" = 15)


/datum/xeno_caste/tindalos/elder
	upgrade_name = "Elder"
	caste_desc = "A manipulator of space and time. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = -1.2

	// *** Plasma *** //
	plasma_max = 350
	plasma_gain = 23

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 480

	// *** Defense *** //
	soft_armor = list("melee" = 20, "bullet" = 20, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_0, "bio" = 18, "rad" = 25, "fire" = 25, "acid" = 18)


/datum/xeno_caste/tindalos/ancient
	upgrade_name = "Ancient"
	caste_desc = "A master manipulator of space and time."
	ancient_message = "We are the master of space and time. Reality bends to our will."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = -1.25

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 25

	// *** Health *** //
	max_health = 260

	// *** Evolution *** //
	upgrade_threshold = 480

	// *** Defense *** //
	soft_armor = list("melee" = 25, "bullet" = 25, "laser" = 40, "energy" = 40, "bomb" = XENO_BOMB_RESIST_0, "bio" = 18, "rad" = 25, "fire" = 30, "acid" = 18)

