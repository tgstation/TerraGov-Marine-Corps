//Hunter Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Hunter
	caste = "Hunter"
	name = "Hunter"
	desc = "A beefy, fast alien with sharp claws."
	icon_state = "Hunter Walking"
	melee_damage_lower = 20
	melee_damage_upper = 30
	health = 150
	maxHealth = 150
	storedplasma = 50
	plasma_gain = 8
	maxplasma = 100
	jellyMax = 500
	jelly = 1
	caste_desc = "A fast, powerful front line combatant."
	speed = -1.4 //Not as fast as runners, but faster than other xenos
	evolves_to = list("Ravager", "Crusher")
	charge_type = 1 //Pounce - Hunter
	armor_deflection = 32
	attack_delay = -2
	tier = 2
	upgrade = 0
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		/mob/living/carbon/Xenomorph/proc/Pounce,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/proc/tail_attack
		)

/mob/living/carbon/Xenomorph/Hunter/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && middle_mouse_toggle)
		Pounce(A)
		return
	if(modifiers["shift"] && shift_mouse_toggle)
		Pounce(A)
		return
	..()
