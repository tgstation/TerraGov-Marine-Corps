//Sentinal Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Sentinel
	caste = "Sentinel"
	name = "Sentinel"
	desc = "A slithery, spitting kind of alien."
	icon_state = "Sentinel Walking"
	melee_damage_lower = 10
	melee_damage_upper = 20
	health = 130
	maxHealth = 130
	storedplasma = 75
	plasma_gain = 10
	maxplasma = 300
	evolution_threshold = 200
	spit_delay = 30
	caste_desc = "A weak ranged combat alien."
	evolves_to = list("Spitter")
	armor_deflection = 15
	tier = 1
	upgrade = 0
	speed = -0.4
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/corrosive_acid,
		/mob/living/carbon/Xenomorph/proc/neurotoxin //Weakest version
		)

