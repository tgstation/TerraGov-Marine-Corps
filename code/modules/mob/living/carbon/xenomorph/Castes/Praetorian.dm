/datum/xeno_caste/praetorian
	caste_name = "Praetorian"
	display_name = "Praetorian"
	upgrade_name = "Young"
	caste_desc = "Ptui!"
	caste_type_path = /mob/living/carbon/Xenomorph/Praetorian
	tier = 3
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 25

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 25

	// *** Health *** //
	max_health = 210

	// *** Evolution *** //
	upgrade_threshold = 400

	deevolves_to = /mob/living/carbon/Xenomorph/Drone

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	armor_deflection = 35

	// *** Ranged Attack *** //
	spit_delay = 2 SECONDS 
	spit_types = list(/datum/ammo/xeno/toxin/heavy, /datum/ammo/xeno/acid/heavy, /datum/ammo/xeno/sticky)

	acid_spray_range = 3
	acid_spray_cooldown = 15 SECONDS

	// *** Pheromones *** //	
	aura_strength = 1.5 //Praetorian's aura starts strong. They are the Queen's right hand. Climbs by 1 to 4.5
	aura_allowed = list("frenzy", "warding", "recovery")

/datum/xeno_caste/praetorian/mature
	upgrade_name = "Mature"
	caste_desc = "A giant ranged monster. It looks a little more dangerous."
	upgrade = 1

	// *** Melee Attacks *** //
	melee_damage_lower = 25
	melee_damage_upper = 30

	// *** Tackle *** //
	tackle_damage = 45

	// *** Speed *** //
	speed = 0.0

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 30

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 40

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS 

	// *** Pheromones *** //	
	aura_strength = 2.5 

/datum/xeno_caste/praetorian/elder
	upgrade_name = "Elder"
	caste_desc = "A giant ranged monster. It looks pretty strong."
	upgrade = 2

	// *** Melee Attacks *** //
	melee_damage_lower = 30
	melee_damage_upper = 35

	// *** Tackle *** //
	tackle_damage = 50

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 40

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor_deflection = 40

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS 

	// *** Pheromones *** //	
	aura_strength = 3.5 

/datum/xeno_caste/praetorian/ancient
	upgrade_name = "Ancient"
	caste_desc = "Its mouth looks like a minigun."
	upgrade = 3
	ancient_message = "You are the strongest range fighter around. Your spit is devestating and you can fire nearly a constant stream."

	// *** Melee Attacks *** //
	melee_damage_lower = 35
	melee_damage_upper = 40

	// *** Tackle *** //
	tackle_damage = 60

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 250

	// *** Defense *** //
	armor_deflection = 45

	// *** Ranged Attack *** //
	spit_delay = 1.0 SECONDS

	// *** Pheromones *** //	
	aura_strength = 4.5 

/mob/living/carbon/Xenomorph/Praetorian
	caste_base_type = /mob/living/carbon/Xenomorph/Praetorian
	name = "Praetorian"
	desc = "A huge, looming beast of an alien."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Praetorian Walking"
	health = 210
	maxHealth = 210
	plasma_stored = 200
	speed = -0.1
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = 3
	upgrade = 0
	var/sticky_cooldown = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/emit_pheromones,
		/datum/action/xeno_action/shift_spits,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/spray_acid
		)
