/mob/living/carbon/has_mouth()
	return TRUE

/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return FALSE
	if(buckled && ! istype(buckled, /obj/structure/bed/chair)) // buckling does not restrict hands
		return FALSE
	return TRUE


/mob/living/carbon/is_mob_restrained()
	if(handcuffed)
		return TRUE
	return FALSE


/mob/living/carbon/proc/handle_special()
	if(acid_process_cooldown)
		acid_process_cooldown = max(acid_process_cooldown - 1, 0) //Your protection from the acid puddle process eventually goes away.