//Spitter Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Spitter
	caste = "Spitter"
	name = "Spitter"
	desc = "A gross, oozing alien of some kind."
	icon = 'icons/Xeno/xenomorph_48x48.dmi'
	icon_state = "Spitter Walking"
	melee_damage_lower = 12
	melee_damage_upper = 22
	health = 160
	maxHealth = 160
	plasma_stored = 150
	plasma_gain = 20
	plasma_max = 600
	evolution_threshold = 250
	upgrade_threshold = 250
	spit_delay = 25
	spit_types = list(/datum/ammo/xeno/toxin/medium, /datum/ammo/xeno/acid/medium)
	speed = -0.5
	caste_desc = "Ptui!"
	pixel_x = -12
	old_x = -12
	evolves_to = list("Boiler")
	armor_deflection = 15
	tier = 2
	upgrade = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/shift_spits,
		/datum/action/xeno_action/activable/xeno_spit,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)
