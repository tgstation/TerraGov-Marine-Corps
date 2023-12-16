/mob/living/carbon/xenomorph/defiler
	caste_base_type = /mob/living/carbon/xenomorph/defiler
	name = "Defiler"
	desc = "A large, powerfully muscled xeno replete with dripping spines and gas leaking dorsal vents."
	icon = 'icons/Xeno/castes/defiler.dmi'
	icon_state = "Defiler Walking"
	bubble_icon = "alienroyal"
	health = 225
	maxHealth = 225
	plasma_stored = 400
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_NORMAL
	var/emitting_gas = FALSE
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)
