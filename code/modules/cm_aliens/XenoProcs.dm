//Xenomorph General Procs And Functions - Colonial Marines - Apophis775 - Last Edit: 8FEB2015



//PROCS


/mob/living/carbon/Xenomorph/proc/growJelly()//Grows the delicious Jelly 08FEB2015
	spawn while (1)
		if(jelly)
			if(jellyGrow<jellyMax)
				jellyGrow++
			sleep(10)



/mob/living/carbon/Xenomorph/proc/canEvolve()//Determines if they alien can evolve 08FEB2015
	if(!jelly)
		return 0
	if(jellyGrow < jellyMax)
		return 0
	return 1


/mob/living/carbon/Xenomorph/proc/checkPlasma()
	return storedplasma



//FUNCTIONS


/mob/living/carbon/Xenomorph/Stat()//Displays the Jelly Status 08FEB2015
	..()
	if(jelly)
		stat(null, "Jelly Progress: [jellyGrow]/[jellyMax]")