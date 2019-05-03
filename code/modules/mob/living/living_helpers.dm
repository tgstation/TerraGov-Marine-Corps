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
	if(get_total_tint() >= TINT_HEAVY)
		return FALSE
	return has_eyes()

/mob/living/proc/reagent_check(datum/reagent/R)
	return TRUE

/mob/living/proc/get_reagent_tags()
	return
