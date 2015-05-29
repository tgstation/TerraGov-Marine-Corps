//Xenomorph General Procs And Functions - Colonial Marines


//FUNCTIONS

/mob/living/carbon/Xenomorph/Stat()//Displays the Jelly Status 08FEB2015
	..()
	if(jelly)
		stat(null, "Jelly Progress: [jellyGrow]/[jellyMax]")



/mob/living/carbon/Xenomorph/proc/check_plasma(var/value)
	if(stat)
		src << "\red Can't do this while unconcious."
		return 0

	if(value > 0)
		if(storedplasma < value)
			src << "\red Insufficient plasma. You require [value] but have only [storedplasma]."
			return 0

		storedplasma -= value
//		adjustToxLoss(-value) //Is this even used at all anymore??
		return 1
	else
		return 1 //If plasma cost is 0 just go ahead and do it


//Check if you can plant on groundmap turfs.
/mob/living/carbon/Xenomorph/proc/is_weedable(turf/T)
	if(isnull(T) || !isturf(T)) return 0
	if(istype(T,/turf/space)) return 0
	if(istype(T,/turf/simulated/floor/gm/grass) || istype(T,/turf/simulated/floor/gm/dirtgrassborder) || istype(T,/turf/simulated/floor/gm/river) || istype(T,/turf/simulated/floor/gm/coast)) return 0
	return 1

/mob/living/carbon/Xenomorph/proc/remove_inherent_verbs()
	if(inherent_verbs)
		for(var/verb_path in inherent_verbs)
			verbs -= verb_path
	return

/mob/living/carbon/Xenomorph/proc/add_inherent_verbs()
	if(inherent_verbs)
		for(var/verb_path in inherent_verbs)
			verbs |= verb_path
	return


	return

/* OBSOLETE
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
*/

/mob/living/carbon/Xenomorph/movement_delay()

	var/tally = 0

	tally = speed

	if (istype(loc, /turf/space)) return -1 // It's hard to be slowed down in space by... anything

	if(src.pulling)  //Dragging stuff slows you down a bit.
		tally += 0.5

	return (tally)