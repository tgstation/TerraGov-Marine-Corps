/mob/living/carbon/xenomorph/Login()
	. = ..()

	if(see_in_dark == XENO_NIGHTVISION_ENABLED)
		var/obj/screen/plane_master/lighting/L = hud_used.plane_masters["[LIGHTING_PLANE]"]
		if(!L)
			return

		L.alpha = 0

	if(!isdistress(SSticker.mode))
		return 

	var/datum/game_mode/distress/D = SSticker.mode
	D.xenomorphs |= mind

	mind.assigned_role = ROLE_XENOMORPH


/mob/living/carbon/xenomorph/queen/Login()
	. = ..()

	mind.assigned_role = ROLE_XENO_QUEEN