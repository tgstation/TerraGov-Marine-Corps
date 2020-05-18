/mob/living/carbon/xenomorph/battle_droid
	caste_base_type = /mob/living/carbon/xenomorph/battle_droid
	name = "Battle Droid"
	desc = "A Battle Droid"
	icon = 'icons/star/mob/droid/battle_droid/battle_droid.dmi'
	icon_state = "battle_droid"
	health = 120
	maxHealth = 120
	plasma_stored = 350
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_ZERO
	speed = -0.8
	pixel_x = -12
	old_x = -12
	pull_speed = -2
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl
		)
