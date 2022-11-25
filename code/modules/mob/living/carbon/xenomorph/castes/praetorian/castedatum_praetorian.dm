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

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 50

	// *** Health *** //
	max_health = 290

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/spitter

	// *** Flags *** //
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING

	// *** Defense *** //
	soft_armor = list(MELEE = 30, BULLET = 35, LASER = 35, ENERGY = 35, BOMB = 0, BIO = 28, FIRE = 35, ACID = 28)

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/heavy, /datum/ammo/xeno/acid/heavy)

	acid_spray_duration = 10 SECONDS
	acid_spray_range = 5
	acid_spray_damage = 16
	acid_spray_damage_on_hit = 35
	acid_spray_structure_damage = 45

	// *** Pheromones *** //
	aura_strength = 3 //Praetorian's aura starts strong. They are the Queen's right hand. Climbs by 1 to 4.5

	// *** Minimap Icon *** //
	minimap_icon = "praetorian"

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/place_acidwell,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/spray_acid/cone,
		/datum/action/xeno_action/pheromones,
		/datum/action/xeno_action/pheromones/emit_recovery,
		/datum/action/xeno_action/pheromones/emit_warding,
		/datum/action/xeno_action/pheromones/emit_frenzy,
	)

/datum/xeno_caste/praetorian/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/praetorian/mature
	upgrade_name = "Mature"
	caste_desc = "A giant ranged monster. It looks a little more dangerous."
	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 60

	// *** Health *** //
	max_health = 320

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 35, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 0, BIO = 33, FIRE = 40, ACID = 33)

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

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 70

	// *** Health *** //
	max_health = 340

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 40, BULLET = 45, LASER = 45, ENERGY = 45, BOMB = 0, BIO = 35, FIRE = 45, ACID = 35)

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

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 80

	// *** Health *** //
	max_health = 360

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list(MELEE = 45, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 38, FIRE = 50, ACID = 38)

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/heavy/upgrade3, /datum/ammo/xeno/acid/heavy)

	acid_spray_damage_on_hit = 47
	acid_spray_structure_damage = 69

	// *** Pheromones *** //
	aura_strength = 4.5

/datum/xeno_caste/praetorian/primordial
	upgrade_name = "Primordial"
	caste_desc = "An aberrant creature extremely proficient with acid, keep your distance if you don't wish to be burned."
	upgrade = XENO_UPGRADE_FOUR
	primordial_message = "The strongest of acids flows through our veins, let's reduce them to dust."

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 80

	// *** Health *** //
	max_health = 360

	// *** Defense *** //
	soft_armor = list(MELEE = 45, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 38, FIRE = 50, ACID = 38)

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/heavy/upgrade3, /datum/ammo/xeno/acid/heavy)

	acid_spray_damage_on_hit = 47
	acid_spray_structure_damage = 69

	// *** Pheromones *** //
	aura_strength = 4.5

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_LARGE

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/place_acidwell,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/spray_acid/cone,
		/datum/action/xeno_action/activable/acid_dash,
		/datum/action/xeno_action/pheromones,
		/datum/action/xeno_action/pheromones/emit_recovery,
		/datum/action/xeno_action/pheromones/emit_warding,
		/datum/action/xeno_action/pheromones/emit_frenzy,
	)
