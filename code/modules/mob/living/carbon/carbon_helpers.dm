
/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return 0
	if(buckled && ! istype(buckled, /obj/structure/bed/chair)) // buckling does not restrict hands
		return 0
	return 1

/mob/living/carbon/is_mob_restrained()
	if (handcuffed)
		return 1
	return

/mob/living/carbon/proc/handle_special()
	if(acid_process_cooldown)
		acid_process_cooldown = max(acid_process_cooldown - 1, 0) //Your protection from the acid puddle process eventually goes away.