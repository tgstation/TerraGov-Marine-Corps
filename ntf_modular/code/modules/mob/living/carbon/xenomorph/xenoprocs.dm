/mob/living/carbon/xenomorph/proc/apply_melee_stat_buff()
	xeno_melee_damage_modifier += (hive.melee_multiplier - melee_multiplier_from_hive)
	melee_multiplier_from_hive = hive.melee_multiplier

/mob/living/carbon/xenomorph/verb/toggle_bump_attack_allies()
	set name = "Toggle Bump Attack Allies"
	set desc = "Toggles the ability to bump attack your allies."
	set category = "Alien"

	xeno_flags ^= XENO_ALLIES_BUMP
	to_chat(src, span_notice("You have [(xeno_flags & XENO_ALLIES_BUMP) ? "enabled" : "disabled"] the Bump Attack Allies Toggle."))

/mob/living/carbon/xenomorph/verb/toggle_destroy_own_structures()
	set name = "Toggle Destroy Own Structures"
	set desc = "Toggles the ability to destroy your own structures."
	set category = "Alien"

	xeno_flags ^= XENO_DESTROY_OWN_STRUCTURES
	to_chat(src, span_notice("You have [(xeno_flags & XENO_DESTROY_OWN_STRUCTURES) ? "enabled" : "disabled"] the Destroy Own Structures Toggle."))

/mob/living/carbon/xenomorph/verb/toggle_destroy_weeds()
	set name = "Toggle Destroy Weeds"
	set desc = "Toggles the ability to destroy weeds."
	set category = "Alien"

	xeno_flags ^= XENO_DESTROY_WEEDS
	to_chat(src, span_notice("You have [(xeno_flags & XENO_DESTROY_WEEDS) ? "enabled" : "disabled"] the Destroy Weeds Toggle."))

/mob/living/carbon/xenomorph/verb/swapgender()
	set name = "Swap Gender"
	set desc = "Swap between xeno genders in an instant, nothing compared to evolving. Some may not have textures, PR it yourself."
	set category = "Alien"

	update_xeno_gender(src, TRUE)

/mob/living/carbon/xenomorph/proc/update_xeno_gender(mob/living/carbon/xenomorph/user = src, swapping = FALSE)
	remove_overlay(GENITAL_LAYER)
	if(QDELETED(user)||QDELETED(src))
		return
	var/xgen = user?.client?.prefs?.xenogender
	if(swapping) //flips to next in selection
		xgen += 1
	if(xgen >= 5) //revert to start if over max.
		xgen = 1
	//updates the overlays
	user.client?.prefs?.xenogender = xgen
	genital_overlay.layer = layer + 0.3
	genital_overlay.vis_flags |= VIS_HIDE
	genital_overlay.icon = src.icon
	genital_overlay.icon_state = "none"
	switch(xgen)
		if(1) //blank
			genital_overlay.icon_state = null
			gender=NEUTER
			if(swapping)
				user.balloon_alert(user, "None")
		if(2)
			genital_overlay.icon_state = "[icon_state]_female"
			gender=FEMALE
			if(swapping)
				user.balloon_alert(user, "Female")
		if(3)
			genital_overlay.icon_state = "[icon_state]_male"
			gender=MALE
			if(swapping)
				user.balloon_alert(user, "Male")
		if(4)
			genital_overlay.icon_state = "[icon_state]_futa"
			gender=FEMALE
			if(swapping)
				user.balloon_alert(user, "Futa")

	if(xeno_caste.caste_flags & CASTE_HAS_WOUND_MASK) //ig if u cant see wounds u shouldnt see tiddies too maybe for things like being ethereal
		apply_overlay(GENITAL_LAYER)
	genital_overlay.vis_flags &= ~VIS_HIDE // Show the overlay

/mob/living/carbon/xenomorph/update_cloak()
	return

/mob/living/carbon/xenomorph/get_iff_signal()
	return xeno_iff_check()


/mob/living/carbon/xenomorph/adjustToxLoss(amount)
	return FALSE


/mob/living/carbon/xenomorph/setToxLoss(amount)
	return FALSE


/mob/living/carbon/xenomorph/adjustCloneLoss(amount)
	return FALSE


/mob/living/carbon/xenomorph/setCloneLoss(amount)
	return FALSE
