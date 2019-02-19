/mob/living/proc/get_death_threshold()
	return CONFIG_GET(number/health_threshold_dead)

/mob/living/proc/get_crit_threshold()
	return CONFIG_GET(number/health_threshold_crit)

/mob/living/proc/has_brain()
	return TRUE

/mob/living/proc/has_eyes()
	return TRUE

/mob/living/proc/has_vision()
	if(sdisabilities & BLIND)
		return FALSE
	return has_eyes()

/mob/living/proc/has_extravision()
	return (!has_eyes() && has_vision())

/mob/living/proc/has_mouth()
	return FALSE

/mob/living/proc/is_mouth_covered(check_head = TRUE, check_mask = TRUE, check_limb = FALSE)
	if(check_limb && !has_mouth())
		return "lack of mouth"
	return FALSE

/mob/living/proc/are_eyes_covered(check_glasses = TRUE, check_head = TRUE, check_mask = TRUE, check_limb = FALSE)
	if(check_limb && !has_eyes())
		return "lack of eyes"
	return FALSE
