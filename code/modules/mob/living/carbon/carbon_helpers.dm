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

///Return the most damaged internal_organ that isn't at 0, or null.
/mob/living/carbon/proc/get_damaged_organ()
	var/datum/internal_organ/chosen_organ
	for(var/datum/internal_organ/test_organ AS in internal_organs)
		if(!test_organ.damage)
			continue
		if(!chosen_organ)
			chosen_organ = test_organ
			continue
		if(test_organ.damage > chosen_organ.damage)
			chosen_organ = test_organ
	return chosen_organ
