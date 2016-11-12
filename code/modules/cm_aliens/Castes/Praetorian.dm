//Praetorian Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Praetorian
	caste = "Praetorian"
	name = "Praetorian"
	desc = "A huge, looming beast of an alien."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Praetorian Walking"
	melee_damage_lower = 15
	melee_damage_upper = 25
	tacklemin = 3
	tacklemax = 8
	tackle_chance = 75
	health = 200
	maxHealth = 200
	storedplasma = 200
	plasma_gain = 25
	maxplasma = 800
	jellyMax = 800
	spit_delay = 20
	speed = 1.7
	jelly = 1
	pixel_x = -16
	caste_desc = "Ptui!"
	evolves_to = list()
	armor_deflection = 45
	big_xeno = 1
	tier = 3
	upgrade = 0
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/proc/corrosive_acid,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/shift_spits,
		/mob/living/carbon/Xenomorph/proc/toggle_auras,
		/mob/living/carbon/Xenomorph/proc/neurotoxin //Stronger version
		)

/mob/living/carbon/Xenomorph/Praetorian/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && middle_mouse_toggle)
		neurotoxin(A)
		return
	if(modifiers["shift"] && shift_mouse_toggle)
		neurotoxin(A)
		return
	..()
