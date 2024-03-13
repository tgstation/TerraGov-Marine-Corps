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

/mob/living/carbon/index_to_hand(hand_index)
	switch(hand_index)
		if(1)
			return get_limb(BODY_ZONE_PRECISE_L_HAND)
		else
			return get_limb(BODY_ZONE_PRECISE_R_HAND)

/mob/living/carbon/put_in_hand_check(obj/item/I, hand_index)
	if(!index_to_hand(hand_index))
		return FALSE
	return ..()
