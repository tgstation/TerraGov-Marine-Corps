/mob/living/carbon/xenomorph/runner
	caste_base_type = /mob/living/carbon/xenomorph/runner
	name = "Runner"
	desc = "A small red alien that looks like it could run fairly quickly..."
	icon = 'icons/Xeno/castes/runner.dmi' //They are now like, 2x1 or something
	icon_state = "Runner Walking"
	bubble_icon = "alienleft"
	health = 100
	maxHealth = 100
	plasma_stored = 50
	pass_flags = PASS_LOW_STRUCTURE
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_NORMAL
	pixel_x = -16  //Needed for 2x2
	old_x = -16
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

/mob/living/carbon/xenomorph/runner/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_LIGHT_STEP, XENO_TRAIT)

/mob/living/carbon/xenomorph/runner/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER

/mob/living/carbon/xenomorph/runner/med_hud_set_status()
	. = ..()
	hud_set_evasion()

/mob/living/carbon/xenomorph/runner/proc/hud_set_evasion(duration)
	var/image/holder = hud_list[XENO_EVASION_HUD]
	if(!holder)
		return
	holder.overlays.Cut()
	holder.icon_state = "hudblank"
	if(stat == DEAD || !duration)
		return
	holder.icon_state = "evasion_duration[duration]"
	holder.pixel_x = 24
	holder.pixel_y = 24
	hud_list[XENO_EVASION_HUD] = holder
