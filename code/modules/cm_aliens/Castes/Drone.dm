//Xenomorph - Drone - Colonial Marines - Apophis775 - Last Edit: 11JUN16

/mob/living/carbon/Xenomorph/Drone
	caste = "Drone"
	name = "Drone"
	desc = "An Alien Drone"
	icon_state = "Drone Walking"
	melee_damage_lower = 12
	melee_damage_upper = 16
	health = 120
	maxHealth = 120
	storedplasma = 350
	maxplasma = 750
	evolution_threshold = 500
	plasma_gain = 12
	tier = 1
	upgrade = 0
	speed = -0.8
	aura_strength = 0.5 //Drone's aura is the weakest. At the top of their evolution, it's equivalent to a Young Queen Climbs by 0.5 to 2
	evolves_to = list("Queen", "Carrier", "Hivelord") //Add more here seperated by commas
	caste_desc = "A builder of hives. Only drones may evolve into Queens."
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/plant,
		/mob/living/carbon/Xenomorph/proc/build_resin,
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/corrosive_acid,
		/mob/living/carbon/Xenomorph/proc/toggle_auras,
	//	/mob/living/carbon/Xenomorph/proc/secure_host
		)
