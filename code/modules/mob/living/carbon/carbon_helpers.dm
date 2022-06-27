/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return FALSE
	if(buckled && ! istype(buckled, /obj/structure/bed/chair)) // buckling does not restrict hands
		return FALSE
	return TRUE


/mob/living/carbon/restrained(ignore_checks)
	. = ..()
	return (. || handcuffed)

/mob/living/carbon/get_reagent_tags()
	return species?.reagent_tag

/mob/living/carbon/proc/get_damaged_organ()
	for(var/datum/internal_organ/our_organ AS in internal_organs)
		if(our_organ.damage)
			return our_organ
