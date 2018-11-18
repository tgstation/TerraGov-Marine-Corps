/datum/xeno_caste/drone
	caste_name = "Drone"
	display_name = "Drone"
	upgrade_name = "Young"
	caste_desc = "A builder of hives. Only drones may evolve into Queens."
	caste_type_path = /mob/living/carbon/Xenomorph/Drone

	tier = 1
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 12
	melee_damage_upper = 16

	// *** Tackle *** //
	tackle_damage = 25 

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 750
	plasma_gain = 25

	// *** Health *** //
	max_health = 120

	// *** Evolution *** //
	evolution_threshold = 100 
	upgrade_threshold = 100

	evolves_to = list(/mob/living/carbon/Xenomorph/Queen, /mob/living/carbon/Xenomorph/Carrier, /mob/living/carbon/Xenomorph/Hivelord)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA

	can_hold_eggs = CAN_HOLD_TWO_HANDS

	// *** Defense *** //
	armor_deflection = 0

	// *** Pheromones *** //	
	aura_strength = 0.5 //Drone's aura is the weakest. At the top of their evolution, it's equivalent to a Young Queen Climbs by 0.5 to 2
	aura_allowed = list("frenzy", "warding", "recovery")

/datum/xeno_caste/drone/mature
	upgrade_name = "Mature"
	caste_desc = "The workhorse of the hive. It looks a little more dangerous."

	upgrade = 1

	// *** Melee Attacks *** //
	melee_damage_lower = 15
	melee_damage_upper = 20

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 30

	// *** Health *** //
	max_health = 150

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Defense *** //
	armor_deflection = 5

	// *** Pheromones *** //	
	aura_strength = 1 

/datum/xeno_caste/drone/elite
	upgrade_name = "Elite"
	caste_desc = "The workhorse of the hive. It looks a little more dangerous."

	upgrade = 2

	// *** Melee Attacks *** //
	melee_damage_lower = 15
	melee_damage_upper = 20

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -1.0

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 35

	// *** Health *** //
	max_health = 170

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 10

	// *** Pheromones *** //	
	aura_strength = 1.5

/datum/xeno_caste/drone/ancient
	upgrade_name = "Ancient"
	caste_desc = "A very mean architect."
	ancient_message = "You are the ultimate worker of the Hive. Time to clock in, and clock the tallhosts out."
	upgrade = 3

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 25

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -1.1

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 40

	// *** Health *** //
	max_health = 180

	// *** Defense *** //
	armor_deflection = 15

	// *** Pheromones *** //	
	aura_strength = 2
					
/mob/living/carbon/Xenomorph/Drone
	caste_base_type = /mob/living/carbon/Xenomorph/Drone
	name = "Drone"
	desc = "An Alien Drone"
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Drone Walking"
	health = 120
	maxHealth = 120
	plasma_stored = 350
	tier = 1
	upgrade = 0
	speed = -0.8
	pixel_x = 0
	old_x = 0
	pull_speed = -2
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/activable/transfer_plasma,
		/datum/action/xeno_action/activable/corrosive_acid/drone,
		/datum/action/xeno_action/emit_pheromones,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)
