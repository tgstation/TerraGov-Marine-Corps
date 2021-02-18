/datum/xeno_caste/praetorian
	caste_name = "Praetorian"
	display_name = "Praetorian"
	upgrade_name = ""
	caste_desc = "Ptui!"
	caste_type_path = /mob/living/carbon/xenomorph/praetorian
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "praetorian" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 50

	// *** Health *** //
	max_health = 290

	// *** Evolution *** //
	upgrade_threshold = 250

	deevolves_to = /mob/living/carbon/xenomorph/spitter

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 30, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = XENO_BOMB_RESIST_0, "bio" = 28, "rad" = 28, "fire" = 35, "acid" = 28)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/heavy, /datum/ammo/xeno/acid/heavy)

	acid_spray_duration = 10 SECONDS
	acid_spray_range = 4
	acid_spray_damage = 16
	acid_spray_damage_on_hit = 35
	acid_spray_structure_damage = 45

	// *** Pheromones *** //
	aura_strength = 3 //Praetorian's aura starts strong. They are the Queen's right hand. Climbs by 1 to 4.5
	aura_allowed = list("frenzy", "warding", "recovery")

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/place_acidwell,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/shift_spits,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/spray_acid/cone,
		/datum/action/xeno_action/toggle_pheromones,
	)

/datum/xeno_caste/praetorian/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/praetorian/mature
	upgrade_name = "Mature"
	caste_desc = "A giant ranged monster. It looks a little more dangerous."
	upgrade = XENO_UPGRADE_ONE

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 60

	// *** Health *** //
	max_health = 320

	// *** Evolution *** //
	upgrade_threshold = 500

	// *** Defense *** //
	soft_armor = list("melee" = 35, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = XENO_BOMB_RESIST_0, "bio" = 33, "rad" = 33, "fire" = 40, "acid" = 33)

	// *** Ranged Attack *** //
	spit_delay = 1.2 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/heavy/upgrade1, /datum/ammo/xeno/acid/heavy)

	acid_spray_damage_on_hit = 39
	acid_spray_structure_damage = 53

	// *** Pheromones *** //
	aura_strength = 3.5

/datum/xeno_caste/praetorian/elder
	upgrade_name = "Elder"
	caste_desc = "A giant ranged monster. It looks pretty strong."
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Tackle *** //
	tackle_damage = 28

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 70

	// *** Health *** //
	max_health = 340

	// *** Evolution *** //
	upgrade_threshold = 1000

	// *** Defense *** //
	soft_armor = list("melee" = 40, "bullet" = 45, "laser" = 45, "energy" = 45, "bomb" = XENO_BOMB_RESIST_0, "bio" = 35, "rad" = 35, "fire" = 45, "acid" = 35)

	// *** Ranged Attack *** //
	spit_delay = 1.1 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/heavy/upgrade2, /datum/ammo/xeno/acid/heavy)

	acid_spray_damage_on_hit = 43
	acid_spray_structure_damage = 61

	// *** Pheromones *** //
	aura_strength = 4

/datum/xeno_caste/praetorian/ancient
	upgrade_name = "Ancient"
	caste_desc = "The maw of this creature drips with acid."
	upgrade = XENO_UPGRADE_THREE
	ancient_message = "We are the strongest ranged fighter around. Our spit is devastating and we can fire nearly a constant stream."

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Tackle *** //
	tackle_damage = 28

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 80

	// *** Health *** //
	max_health = 360

	// *** Defense *** //
	soft_armor = list("melee" = 45, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = XENO_BOMB_RESIST_0, "bio" = 38, "rad" = 38, "fire" = 50, "acid" = 38)

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/heavy/upgrade3, /datum/ammo/xeno/acid/heavy)

	acid_spray_damage_on_hit = 47
	acid_spray_structure_damage = 69

	// *** Pheromones *** //
	aura_strength = 4.5

