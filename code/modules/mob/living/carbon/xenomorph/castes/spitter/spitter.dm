/mob/living/carbon/xenomorph/spitter
	caste_base_type = /mob/living/carbon/xenomorph/spitter
	name = "Spitter"
	desc = "A gross, oozing alien of some kind."
	icon = 'icons/Xeno/48x48_Xenos.dmi'
	icon_state = "Spitter Walking"
	health = 180
	maxHealth = 180
	plasma_stored = 150
	speed = -0.5
	pixel_x = -12
	old_x = -12
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
		)
