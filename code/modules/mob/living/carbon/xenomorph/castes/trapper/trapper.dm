/mob/living/carbon/xenomorph/trapper
	caste_base_type = /mob/living/carbon/xenomorph/trapper
	name = "Trapper"
	desc = "An Alien Trapper"
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Trapper Walking"
	health = 120
	maxHealth = 100
	plasma_stored = 500
	flags_pass = PASSTABLE
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16  //Needed for 2x2
	old_x = -16
	pull_speed = -2
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl
		)

/mob/living/carbon/xenomorph/trapper/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER
