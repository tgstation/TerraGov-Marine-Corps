



/mob/living/proc/has_brain()
	return 1

/mob/living/proc/has_eyes()
	return 1

/mob/living/proc/has_vision()
	if(sdisabilities & BLIND)
		return FALSE
	return has_eyes()
