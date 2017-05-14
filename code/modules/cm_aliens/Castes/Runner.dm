//Runner Code - Colonial Marines - Last Edit: Apophis775 - 11JUN16

/mob/living/carbon/Xenomorph/Runner
	caste = "Runner"
	name = "Runner"
	desc = "A small red alien that looks like it could run fairly quickly..."
	icon = 'icons/xeno/2x2_Xenos.dmi' //They are now like, 2x1 or something
	icon_state = "Runner Walking"
	melee_damage_lower = 10
	melee_damage_upper = 20
	health = 100
	maxHealth = 100
	storedplasma = 50
	plasma_gain = 1
	maxplasma = 100
	jelly = 1
	jellyMax = 200
	caste_desc = "A fast, four-legged terror, but weak in sustained combat."
	speed = -1.9
	evolves_to = list("Hunter")
	charge_type = 1 //Pounce - Runner
	flags_pass = PASSTABLE
	attack_delay = -4
	tier = 1
	upgrade = 0
	pixel_x = -16  //Needed for 2x2

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		/mob/living/carbon/Xenomorph/proc/Pounce,
		/mob/living/carbon/Xenomorph/proc/transfer_plasma,
		/mob/living/carbon/Xenomorph/Larva/proc/xenohide,
		/mob/living/carbon/Xenomorph/proc/tail_attack
		)

