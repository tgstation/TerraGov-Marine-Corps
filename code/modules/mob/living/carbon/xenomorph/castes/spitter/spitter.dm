/mob/living/carbon/xenomorph/spitter
	caste_base_type = /mob/living/carbon/xenomorph/spitter
	name = "Spitter"
	desc = "A gross, oozing alien of some kind."
	icon = 'icons/Xeno/castes/spitter.dmi'
	icon_state = "Spitter Walking"
	bubble_icon = "alienroyal"
	health = 180
	maxHealth = 180
	plasma_stored = 150
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_NORMAL
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)
