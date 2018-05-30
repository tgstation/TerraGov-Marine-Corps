//Hunter Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Lurker
	caste = "Lurker"
	name = "Lurker"
	desc = "A beefy, fast alien with sharp claws."
	icon = 'icons/Xeno/xenomorph_48x48.dmi'
	icon_state = "Lurker Walking"
	melee_damage_lower = 20
	melee_damage_upper = 30
	health = 150
	maxHealth = 150
	plasma_stored = 50
	plasma_gain = 8
	plasma_max = 100
	evolution_threshold = 500
	upgrade_threshold = 500
	caste_desc = "A fast, powerful front line combatant."
	speed = -1.5 //Not as fast as runners, but faster than other xenos
	pixel_x = -12
	old_x = -12
	evolves_to = list("Ravager")
	charge_type = 2 //Pounce - Hunter
	armor_deflection = 15
	attack_delay = -2
	pounce_delay = 55
	tier = 2
	upgrade = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/pounce
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)
