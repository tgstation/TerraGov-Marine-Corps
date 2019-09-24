/datum/xeno_caste/queen
	caste_name = "Queen"
	display_name = "Queen"
	caste_type_path = /mob/living/carbon/xenomorph/queen
	caste_desc = "The biggest and baddest xeno. The Queen controls the hive and plants eggs"

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "queen" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 50

	// *** Tackle *** //
	tackle_damage = 55

	// *** Speed *** //
	speed = 0.6

	// *** Plasma *** //
	plasma_max = 700
	plasma_gain = 30

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_FIRE_IMMUNE|CASTE_HIDE_IN_STATUS

	can_hold_eggs = CAN_HOLD_TWO_HANDS

	// *** Defense *** //
	armor = list("melee" = 45, "bullet" = 45, "laser" = 45, "energy" = 45, "bomb" = XENO_BOMB_RESIST_3, "bio" = 45, "rad" = 45, "fire" = 100, "acid" = 45)

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/sticky, /datum/ammo/xeno/acid/heavy)

	// *** Pheromones *** //
	aura_strength = 3 //The Queen's aura is strong and stays so, and gets devastating late game. Climbs by 1 to 5
	aura_allowed = list("frenzy", "warding", "recovery")

	// *** Queen Abilities *** //
	queen_leader_limit = 1 //Amount of leaders allowed

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/grow_ovipositor,
		/datum/action/xeno_action/activable/screech,
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/psychic_whisper,
		/datum/action/xeno_action/shift_spits,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/toggle_pheromones
		)

/datum/xeno_caste/queen/young
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/queen/mature
	caste_desc = "The biggest and baddest xeno. The Queen controls the hive and plants eggs"

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 55

	// *** Tackle *** //
	tackle_damage = 60

	// *** Speed *** //
	speed = 0.5

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 40

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = XENO_BOMB_RESIST_3, "bio" = 50, "rad" = 50, "fire" = 100, "acid" = 50)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS

	// *** Pheromones *** //
	aura_strength = 4

	// *** Queen Abilities *** //
	queen_leader_limit = 2

/datum/xeno_caste/queen/elder
	caste_desc = "The biggest and baddest xeno. The Empress controls multiple hives and planets."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 60

	// *** Tackle *** //
	tackle_damage = 65

	// *** Speed *** //
	speed = 0.4

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 50

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = 3200

	// *** Defense *** //
	armor = list("melee" = 55, "bullet" = 55, "laser" = 55, "energy" = 55, "bomb" = XENO_BOMB_RESIST_3, "bio" = 55, "rad" = 55, "fire" = 100, "acid" = 55)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS

	// *** Pheromones *** //
	aura_strength = 4.7

	// *** Queen Abilities *** //
	queen_leader_limit = 3

/datum/xeno_caste/queen/ancient
	caste_desc = "The most perfect Xeno form imaginable."
	ancient_message = "We are the Alpha and the Omega. The beginning and the end."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 65

	// *** Tackle *** //
	tackle_damage = 70

	// *** Speed *** //
	speed = 0.3

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 375

	// *** Evolution *** //
	upgrade_threshold = 3200

	// *** Defense *** //
	armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 60, "bomb" = XENO_BOMB_RESIST_3, "bio" = 60, "rad" = 60, "fire" = 100, "acid" = 60)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS

	// *** Pheromones *** //
	aura_strength = 5

	// *** Queen Abilities *** //
	queen_leader_limit = 4
