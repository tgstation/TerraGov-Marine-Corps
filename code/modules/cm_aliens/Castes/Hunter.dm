
/mob/living/carbon/Xenomorph/Hunter
	caste = "Hunter"
	name = "Hunter"
	desc = "A beefy, fast alien with sharp claws."
	icon_state = "Hunter Walking"
	melee_damage_lower = 18
	melee_damage_upper = 32
	health = 140
	maxHealth = 140
	storedplasma = 50
	plasma_gain = 8
	maxplasma = 100
	jellyMax = 500
	caste_desc = "A fast, powerful front line combatant."
	speed = -1.4 //Not as fast as runners, but faster than other xenos
	evolves_to = list("Ravager", "Crusher")
	charge_type = 1 //Pounce
	armor_deflection = 32
	attack_delay = -2

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
