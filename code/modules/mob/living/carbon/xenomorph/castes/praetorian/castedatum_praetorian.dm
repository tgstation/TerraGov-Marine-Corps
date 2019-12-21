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
	melee_damage = 30

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = 0.0

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 25

	// *** Health *** //
	max_health = 210

	// *** Evolution *** //
	upgrade_threshold = 200

	deevolves_to = /mob/living/carbon/xenomorph/spitter

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor = list("melee" = 28, "bullet" = 28, "laser" = 28, "energy" = 28, "bomb" = XENO_BOMB_RESIST_0, "bio" = 28, "rad" = 28, "fire" = 10, "acid" = 28)

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/heavy, /datum/ammo/xeno/acid/heavy)

	acid_spray_range = 4

	// *** Pheromones *** //
	aura_strength = 2.5 //Praetorian's aura starts strong. They are the Queen's right hand. Climbs by 1 to 4.5
	aura_allowed = list("frenzy", "warding", "recovery")

	// *** Abilities *** //
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/shift_spits,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/spray_acid/cone,
		/datum/action/xeno_action/toggle_pheromones
		)

/datum/xeno_caste/praetorian/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/praetorian/mature
	upgrade_name = "Mature"
	caste_desc = "A giant ranged monster. It looks a little more dangerous."
	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage = 32

	// *** Tackle *** //
	tackle_damage = 42

	// *** Speed *** //
	speed = -0.15

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 30

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor = list("melee" = 33, "bullet" = 33, "laser" = 33, "energy" = 33, "bomb" = XENO_BOMB_RESIST_0, "bio" = 33, "rad" = 33, "fire" = 13, "acid" = 33)

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/heavy/upgrade1, /datum/ammo/xeno/acid/heavy)

	// *** Pheromones *** //
	aura_strength = 3.5

/datum/xeno_caste/praetorian/elder
	upgrade_name = "Elder"
	caste_desc = "A giant ranged monster. It looks pretty strong."
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 35

	// *** Tackle *** //
	tackle_damage = 47

	// *** Speed *** //
	speed = -0.22

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 40

	// *** Health *** //
	max_health = 270

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor = list("melee" = 35, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = XENO_BOMB_RESIST_0, "bio" = 35, "rad" = 35, "fire" = 15, "acid" = 35)

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/heavy/upgrade2, /datum/ammo/xeno/acid/heavy)

	// *** Pheromones *** //
	aura_strength = 4

/datum/xeno_caste/praetorian/ancient
	upgrade_name = "Ancient"
	caste_desc = "Its mouth looks like a minigun."
	upgrade = XENO_UPGRADE_THREE
	ancient_message = "We are the strongest range fighter around. Our spit is devestating and we can fire nearly a constant stream."

	// *** Melee Attacks *** //
	melee_damage = 37

	// *** Tackle *** //
	tackle_damage = 50

	// *** Speed *** //
	speed = -0.25

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 280

	// *** Defense *** //
	armor = list("melee" = 38, "bullet" = 38, "laser" = 38, "energy" = 38, "bomb" = XENO_BOMB_RESIST_0, "bio" = 38, "rad" = 38, "fire" = 18, "acid" = 38)

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/heavy/upgrade3, /datum/ammo/xeno/acid/heavy)

	// *** Pheromones *** //
	aura_strength = 4.5

