/mob/living/carbon/Xenomorph/Login()
	. = ..()

	if(!isdistress(SSticker.mode))
		return 

	var/datum/game_mode/distress/D = SSticker.mode
	D.xenomorphs |= mind