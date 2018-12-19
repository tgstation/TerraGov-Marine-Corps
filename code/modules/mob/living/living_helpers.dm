/mob/living/proc/has_brain()
	return TRUE

/mob/living/proc/has_eyes()
	return TRUE

/mob/living/proc/has_vision()
	if(sdisabilities & BLIND)
		return FALSE
	return has_eyes()

/mob/living/proc/has_mouth()
	return FALSE
