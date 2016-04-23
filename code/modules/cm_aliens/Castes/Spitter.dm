
/mob/living/carbon/Xenomorph/Spitter
	caste = "Spitter"
	name = "Spitter"
	desc = "A gross, oozing alien of some kind."
	icon_state = "Spitter Walking"
	melee_damage_lower = 12
	melee_damage_upper = 22
	health = 150
	maxHealth = 150
	storedplasma = 150
	plasma_gain = 20
	maxplasma = 600
	jellyMax = 500
	spit_delay = 80
	speed = 0
	caste_desc = "Ptui!"
	evolves_to = list("Praetorian", "Boiler")

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/corrosive_acid,
		/mob/living/carbon/Xenomorph/proc/shift_spits,
		/mob/living/carbon/Xenomorph/proc/neurotoxin //Stronger version
		)

/mob/living/carbon/Xenomorph/Spitter/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && middle_mouse_toggle)
		neurotoxin(A)
		return
	if(modifiers["shift"] && shift_mouse_toggle)
		neurotoxin(A)
		return
	..()




