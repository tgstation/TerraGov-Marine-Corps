
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
	jellyMax = 400
	spit_delay = 90
	caste_desc = ""
	evolves_to = list("Spitter")

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/corrosive_acid,
		/mob/living/carbon/Xenomorph/proc/neurotoxin //Weakest version

		)

/mob/living/carbon/Xenomorph/Sentinel/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && middle_mouse_toggle)
		neurotoxin(A)
		return
	if(modifiers["shift"] && shift_mouse_toggle)
		neurotoxin(A)
		return
	..()
