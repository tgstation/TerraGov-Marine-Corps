/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return FALSE
	if(buckled && ! istype(buckled, /obj/structure/bed/chair)) // buckling does not restrict hands
		return FALSE
	return TRUE


/mob/living/carbon/restrained()
	if(handcuffed)
		return TRUE
	return FALSE

/mob/living/carbon/proc/need_breathe()
	if(reagents.has_reagent("lexorin") || in_stasis)
		return FALSE
	return TRUE