/mob/living/carbon/Xenomorph/Login()
	. = ..()

	if(!isdistress(SSticker.mode))
		return 

	var/datum/game_mode/distress/D = SSticker.mode
	D.xenomorphs |= mind

	mind.assigned_role = ROLE_XENOMORPH


/mob/living/carbon/Xenomorph/Queen/Login()
	. = ..()

	mind.assigned_role = ROLE_XENO_QUEEN