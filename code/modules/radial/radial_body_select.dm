/proc/radial_medical(mob/living/carbon/patient, mob/doctor)
	var/mob/living/carbon/human/H = patient
	var/radial_state = ""
	var/datum/limb/part = null

	var/list/radial_options = list()

	for(var/bodypart in GLOB.human_body_parts)
		part = H.get_limb(bodypart)
		if(!part.burn_dam)
			if(!part.brute_dam)
				radial_state = "radial_[bodypart]_un"
			else
				radial_state = "radial_[bodypart]_brute"
		else
			if(part.brute_dam)
				radial_state = "radial_[bodypart]_both"
			else
				radial_state = "radial_[bodypart]_burn"
		if(part.surgery_open_stage)
			radial_state = "radial_[bodypart]_surgery"

		radial_options[bodypart] = image(icon = 'icons/mob/radial.dmi', icon_state = radial_state)

	//the list of the above
	var/list/radial_options_show = list("head" = radial_options[BODY_ZONE_HEAD],
									"chest" = radial_options[BODY_ZONE_CHEST],
									"groin" = radial_options[BODY_ZONE_PRECISE_GROIN],
									"Larm" = radial_options[BODY_ZONE_L_ARM],
									"Lhand" = radial_options[BODY_ZONE_PRECISE_L_HAND],
									"Rarm" = radial_options[BODY_ZONE_R_ARM],
									"Rhand" = radial_options[BODY_ZONE_PRECISE_R_HAND],
									"Lleg" = radial_options[BODY_ZONE_L_LEG],
									"Lfoot" = radial_options[BODY_ZONE_PRECISE_L_FOOT],
									"Rleg" = radial_options[BODY_ZONE_R_LEG],
									"Rfoot" = radial_options[BODY_ZONE_PRECISE_R_FOOT])

	var/datum/limb/affecting = null
	var/choice = show_radial_menu(doctor, H, radial_options_show, null, 48, null, TRUE)
	switch(choice)
		if("head")
			affecting = H.get_limb(BODY_ZONE_HEAD)
		if("chest")
			affecting = H.get_limb(BODY_ZONE_CHEST)
		if("groin")
			affecting = H.get_limb(BODY_ZONE_PRECISE_GROIN)
		if("Larm")
			affecting = H.get_limb(BODY_ZONE_L_ARM)
		if("Lhand")
			affecting = H.get_limb(BODY_ZONE_PRECISE_L_HAND)
		if("Rarm")
			affecting = H.get_limb(BODY_ZONE_R_ARM)
		if("Rhand")
			affecting = H.get_limb(BODY_ZONE_PRECISE_R_HAND)
		if("Lleg")
			affecting = H.get_limb(BODY_ZONE_L_LEG)
		if("Lfoot")
			affecting = H.get_limb(BODY_ZONE_PRECISE_L_FOOT)
		if("Rleg")
			affecting = H.get_limb(BODY_ZONE_R_LEG)
		if("Rfoot")
			affecting = H.get_limb(BODY_ZONE_PRECISE_R_FOOT)
	return affecting
