//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_stasis_bag()
	//Handle side effects from stasis
	if(stat != DEAD)
		switch(in_stasis)
			if(STASIS_IN_BAG)
				knocked_down = knocked_down? --knocked_down : knocked_down + 10 //knocked_down set.
			if(STASIS_IN_CRYO_CELL)
				if(sleeping < 10) sleeping += 10 //Puts the mob to sleep indefinitely.
