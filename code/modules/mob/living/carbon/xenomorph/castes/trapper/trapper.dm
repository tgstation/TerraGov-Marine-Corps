/mob/living/carbon/xenomorph/trapper
	caste_base_type = /mob/living/carbon/xenomorph/trapper
	name = "Trapper"
	desc = "A rather small alien that resembles one of the big cats you'd find back on Terra."
	icon = 'icons/Xeno/2x2_Xenos.dmi' //They are now like, 2x1 or something
	icon_state = "Trapper Walking"
	health = 100
	maxHealth = 150
	plasma_stored = 600
	flags_pass = PASSTABLE
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16  //Needed for 2x2
	old_x = -16
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
		)

/mob/living/carbon/xenomorph/panther/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER
