/mob/living/proc/get_death_threshold()
	return health_threshold_dead

/mob/living/proc/get_crit_threshold()
	return health_threshold_crit

/mob/living/proc/has_brain()
	return 1

/mob/living/proc/has_eyes()
	return 1

/mob/living/proc/has_vision()
	if(disabilities & BLIND)
		return FALSE
	if(tinttotal >= TINT_BLIND)
		return FALSE
	return has_eyes()

/mob/living/proc/reagent_check(datum/reagent/R)
	return TRUE

/mob/living/proc/get_reagent_tags()
	return


/mob/living/incapacitated(ignore_restrained, restrained_flags)
	. = ..()
	if(!.)
		return HAS_TRAIT(src, TRAIT_INCAPACITATED)


/mob/living/restrained(ignore_checks)
	. = ..()
	var/flags_to_check = RESTRAINED_NECKGRAB | RESTRAINED_XENO_NEST | RESTRAINED_STRAIGHTJACKET | RESTRAINED_RAZORWIRE | RESTRAINED_PSYCHICGRAB
	if(ignore_checks)
		DISABLE_BITFIELD(flags_to_check, ignore_checks)
	return (. || CHECK_BITFIELD(restrained_flags, flags_to_check))


/mob/living/get_policy_keywords()
	. = ..()
	if(job)
		. += job.title
