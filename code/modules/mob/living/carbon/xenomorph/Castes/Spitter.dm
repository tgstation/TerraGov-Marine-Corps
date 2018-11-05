//Spitter Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Spitter
	caste = "Spitter"
	name = "Spitter"
	desc = "A gross, oozing alien of some kind."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Spitter Walking"
	melee_damage_lower = 15
	melee_damage_upper = 25
	tackle_damage = 30
	health = 180
	maxHealth = 180
	plasma_stored = 150
	plasma_gain = 20
	plasma_max = 600
	evolution_threshold = 200
	upgrade_threshold = 200
	spit_delay = 25
	spit_types = list(/datum/ammo/xeno/toxin/medium, /datum/ammo/xeno/acid/medium)
	speed = -0.5
	caste_desc = "Ptui!"
	pixel_x = 0
	old_x = 0
	evolves_to = list("Boiler")
	armor_deflection = 20
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
