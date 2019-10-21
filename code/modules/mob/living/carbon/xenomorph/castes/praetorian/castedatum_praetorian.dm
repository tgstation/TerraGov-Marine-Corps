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
	melee_damage = 32.5

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
	upgrade_threshold = 400

	deevolves_to = /mob/living/carbon/xenomorph/spitter

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor = list("melee" = 35, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = XENO_BOMB_RESIST_0, "bio" = 35, "rad" = 35, "fire" = 17, "acid" = 35)

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
	melee_damage = 42.5

	// *** Tackle *** //
	tackle_damage = 50

	// *** Speed *** //
	speed = -0.15

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 30

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = XENO_BOMB_RESIST_0, "bio" = 40, "rad" = 40, "fire" = 20, "acid" = 40)

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
	melee_damage = 47.5

	// *** Tackle *** //
	tackle_damage = 57

	// *** Speed *** //
	speed = -0.22

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 40

	// *** Health *** //
	max_health = 270

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor = list("melee" = 43, "bullet" = 43, "laser" = 43, "energy" = 43, "bomb" = XENO_BOMB_RESIST_0, "bio" = 43, "rad" = 43, "fire" = 21, "acid" = 43)

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
	melee_damage = 50.5

	// *** Tackle *** //
	tackle_damage = 60

	// *** Speed *** //
	speed = -0.25

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 280

	// *** Defense *** //
	armor = list("melee" = 45, "bullet" = 45, "laser" = 45, "energy" = 45, "bomb" = XENO_BOMB_RESIST_0, "bio" = 45, "rad" = 45, "fire" = 22, "acid" = 45)

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/heavy/upgrade3, /datum/ammo/xeno/acid/heavy)

	// *** Pheromones *** //
	aura_strength = 4.5

