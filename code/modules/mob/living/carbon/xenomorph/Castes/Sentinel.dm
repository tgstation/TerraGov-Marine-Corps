//Sentinal Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Sentinel
	caste = "Sentinel"
	name = "Sentinel"
	desc = "A slithery, spitting kind of alien."
	icon = 'icons/Xeno/xenomorph_48x48.dmi'
	icon_state = "Sentinel Walking"
	melee_damage_lower = 10
	melee_damage_upper = 20
	health = 130
	maxHealth = 130
	plasma_stored = 75
	plasma_gain = 10
	plasma_max = 300
	evolution_threshold = 200
	upgrade_threshold = 200
	spit_delay = 30
	spit_types = list(/datum/ammo/xeno/toxin)
	caste_desc = "A weak ranged combat alien."
	pixel_x = -12
	old_x = -12
	evolves_to = list("Spitter")
	armor_deflection = 15
	tier = 1
	upgrade = 0
	speed = -0.8
	pull_speed = -1
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid/drone,
		/datum/action/xeno_action/activable/xeno_spit,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)
