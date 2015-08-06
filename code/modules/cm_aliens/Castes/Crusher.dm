
/mob/living/carbon/Xenomorph/Crusher
	caste = "Crusher"
	name = "Crusher"
	desc = "A huge alien with an enormous armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Crusher Walking"
	melee_damage_lower = 14
	melee_damage_upper = 22
	health = 350
	maxHealth = 350
	storedplasma = 200
	plasma_gain = 10
	maxplasma = 200
	jellyMax = 0
	caste_desc = "A huge tanky xenomorph."
	speed = 0.8
	evolves_to = list()
	var/usedcharge = 0
	charge_type = 3
	armor_deflection = 60

	adjust_pixel_x = -16
	adjust_pixel_y = -6

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/proc/charge,
		/mob/living/carbon/Xenomorph/proc/tail_attack
		)

/mob/living/carbon/Xenomorph/Crusher/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && middle_mouse_toggle)
		charge(A)
		return
	if(modifiers["shift"] && shift_mouse_toggle)
		charge(A)
		return
	..()


