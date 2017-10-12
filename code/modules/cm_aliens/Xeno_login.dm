/mob/living/carbon/Xenomorph/Login()
	..()
	if(ticker && ticker.mode) ticker.mode.xenomorphs |= mind
	update_mob_static_effect()
