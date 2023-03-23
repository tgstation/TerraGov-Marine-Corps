/mob/living/carbon/xenomorph/slime
	caste_base_type = /mob/living/carbon/xenomorph/slime
	name = "Slime"
	desc = "A viscous, squishy and oozy substance. It quivers every now and then, as if it were alive."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Warlock Walking"
	bubble_icon = "alienleft"
	health = 320
	maxHealth = 320
	plasma_stored = 1400
	pixel_x = -16
	old_x = -16
	pull_speed = -2
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_ZERO
	flags_pass = PASSTABLE
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

/mob/living/carbon/xenomorph/slime/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER
