/mob/living/carbon/Xenomorph/Login()
	..()
	if(ticker && ticker.mode && !is_robotic && !(mind in ticker.mode.xenomorphs)) ticker.mode.xenomorphs += mind

