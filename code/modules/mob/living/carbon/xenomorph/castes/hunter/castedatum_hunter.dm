/datum/xeno_caste/hunter
	caste_name = "Hunter"
	display_name = "Hunter"
	upgrade_name = ""
	caste_desc = "A fast, powerful front line combatant."

	caste_type_path = /mob/living/carbon/xenomorph/hunter

	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "hunter" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 21
	attack_delay = 7

	// *** Speed *** //
	speed = -1.1
	weeds_speed_mod = -0.1

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 10

	// *** Health *** //
	max_health = 230

	// *** Evolution *** //
	evolution_threshold = 180
	upgrade_threshold = 120

	evolves_to = list(/mob/living/carbon/xenomorph/ravager)
	deevolves_to = /mob/living/carbon/xenomorph/runner

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 40, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 10, "rad" = 10, "fire" = 15, "acid" = 10)

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_MEDIUM
	pounce_delay = 15 SECONDS

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/headbite,
		/datum/action/xeno_action/activable/devour,
		/datum/action/xeno_action/activable/silence,
		/datum/action/xeno_action/activable/pounce/hunter,
		/datum/action/xeno_action/stealth,
		/datum/action/xeno_action/activable/hunter_mark,
		/datum/action/xeno_action/psychic_trace,
	)

/datum/xeno_caste/hunter/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/hunter/mature
	upgrade_name = "Mature"
	caste_desc = "A fast, powerful front line combatant. It looks a little more dangerous."
	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -1.2

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 15

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 360

	// *** Defense *** //
	soft_armor = list("melee" = 45, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = XENO_BOMB_RESIST_0, "bio" = 15, "rad" = 15, "fire" = 20, "acid" = 15)

	// *** Ranged Attack *** //
	pounce_delay = 12.5 SECONDS

/datum/xeno_caste/hunter/elder
	upgrade_name = "Elder"
	caste_desc = "A fast, powerful front line combatant. It looks pretty strong."
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 24

	// *** Speed *** //
	speed = -1.3

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 18

	// *** Health *** //
	max_health = 270

	// *** Evolution *** //
	upgrade_threshold = 840

	// *** Defense *** //
	soft_armor = list("melee" = 50, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = XENO_BOMB_RESIST_0, "bio" = 18, "rad" = 18, "fire" = 25, "acid" = 18)

	// *** Ranged Attack *** //
	pounce_delay = 11.0 SECONDS

/datum/xeno_caste/hunter/ancient
	upgrade_name = "Ancient"
	caste_desc = "A fast, powerful front line combatant. It looks extremely deadly."
	upgrade = XENO_UPGRADE_THREE
	ancient_message = "We are the epitome of the hunter. Few can stand against us in open combat."

	// *** Melee Attacks *** //
	melee_damage = 24

	// *** Speed *** //
	speed = -1.4

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 18

	// *** Health *** //
	max_health = 290

	// *** Evolution *** //
	upgrade_threshold = 1320

	// *** Defense *** //
	soft_armor = list("melee" = 55, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_0, "bio" = 18, "rad" = 18, "fire" = 30, "acid" = 18)

	// *** Ranged Attack *** //
	pounce_delay = 10.0 SECONDS
