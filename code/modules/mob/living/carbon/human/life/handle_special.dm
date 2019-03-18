/mob/living/carbon/human/handle_special() //random events and unsorted.
	. = ..()
	if(stat == DEAD)
		return

	//Puke if toxloss is too high
	if(!stat)
		if(getToxLoss() >= 45 && nutrition > 50)
			vomit()