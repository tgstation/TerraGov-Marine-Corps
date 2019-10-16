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
	melee_damage = 25
	attack_delay = 7

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -1.5

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 10

	// *** Health *** //
	max_health = 150

	// *** Evolution *** //
	evolution_threshold = 200
	upgrade_threshold = 200

	evolves_to = list(/mob/living/carbon/xenomorph/ravager)
	deevolves_to = /mob/living/carbon/xenomorph/runner

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = XENO_BOMB_RESIST_0, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)

	// *** Ranged Attack *** //
	charge_type = 2 //Pounce - Hunter
	pounce_delay = 15 SECONDS

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/pounce/hunter,
		/datum/action/xeno_action/stealth,
		)

/datum/xeno_caste/hunter/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/hunter/mature
	upgrade_name = "Mature"
	caste_desc = "A fast, powerful front line combatant. It looks a little more dangerous."
	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 35
	attack_delay = 6.75

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -1.6

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 15

	// *** Health *** //
	max_health = 175

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 15, "rad" = 15, "fire" = 15, "acid" = 15)

	// *** Ranged Attack *** //
	pounce_delay = 12.5 SECONDS

/datum/xeno_caste/hunter/elder
	upgrade_name = "Elder"
	caste_desc = "A fast, powerful front line combatant. It looks pretty strong."
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 40
	attack_delay = 6.6

	// *** Tackle *** //
	tackle_damage = 45

	// *** Speed *** //
	speed = -1.7

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 18

	// *** Health *** //
	max_health = 190

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor = list("melee" = 18, "bullet" = 18, "laser" = 18, "energy" = 18, "bomb" = XENO_BOMB_RESIST_0, "bio" = 18, "rad" = 18, "fire" = 18, "acid" = 18)

	// *** Ranged Attack *** //
	pounce_delay = 11.0 SECONDS

/datum/xeno_caste/hunter/ancient
	upgrade_name = "Ancient"
	caste_desc = "A fast, powerful front line combatant. It looks pretty strong."
	upgrade = XENO_UPGRADE_THREE
	ancient_message = "We are the epitome of the hunter. Few can stand against us in open combat."

	// *** Melee Attacks *** //
	melee_damage = 45
	attack_delay = 6.5

	// *** Tackle *** //
	tackle_damage = 50

	// *** Speed *** //
	speed = -1.7

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 18

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = XENO_BOMB_RESIST_0, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 20)

	// *** Ranged Attack *** //
	pounce_delay = 10.0 SECONDS
	
