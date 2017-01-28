/mob/living/carbon/Xenomorph/Login()
	..()
	if(ticker && ticker.mode && !(mind in ticker.mode.xenomorphs))
		ticker.mode.xenomorphs += mind

