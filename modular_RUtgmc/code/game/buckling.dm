/mob/living/carbon/xenomorph/user_can_buckle(mob/living/buckling_mob)
	if(buckling_mob.stat == DEAD)
		return FALSE
	return ..()
