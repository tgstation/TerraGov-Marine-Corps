/mob/living/proc/get_death_threshold()
	return CONFIG_GET(number/health_threshold_dead)

/mob/living/proc/get_crit_threshold()
	return CONFIG_GET(number/health_threshold_crit)

/mob/living/proc/has_brain()
	return 1

/mob/living/proc/has_eyes()
	return 1

/mob/living/proc/has_vision()
	if(sdisabilities & BLIND)
		return FALSE
	return has_eyes()
