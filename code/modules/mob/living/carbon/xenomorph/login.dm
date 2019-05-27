/mob/living/carbon/xenomorph/Login()
	. = ..()

	if(!isdistress(SSticker.mode))
		return 

	var/datum/game_mode/distress/D = SSticker.mode
	D.xenomorphs |= mind

	mind.assigned_role = ROLE_XENOMORPH


/mob/living/carbon/xenomorph/queen/Login()
	. = ..()

	mind.assigned_role = ROLE_XENO_QUEEN