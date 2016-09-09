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
	jelly = 1
	jellyMax = 500
	plasma_gain = 12
	tier = 1
	upgrade = -2 //Drones can't upgrade, since they become Le Queen  Maybe this will change in the future?
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
		/mob/living/carbon/Xenomorph/proc/secure_host
		)


