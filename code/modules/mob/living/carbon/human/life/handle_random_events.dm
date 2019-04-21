//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_random_events()
	//Puke if toxloss is too high
	if(!stat)
		if(getToxLoss() >= 45 && nutrition > 20)
			vomit()


