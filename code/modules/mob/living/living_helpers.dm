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
	if(get_total_tint() >= TINT_BLIND)
		return FALSE
	return has_eyes()

/mob/living/proc/reagent_check(datum/reagent/R)
	return TRUE

/mob/living/proc/get_reagent_tags()
	return


/mob/living/incapacitated(ignore_restrained)
	. = ..()
	if(!.)
		return (stunned || knocked_down || knocked_out)


/mob/living/restrained(ignore_checks)
	. = ..()
	var/flags_to_check = RESTRAINED_NECKGRAB | RESTRAINED_XENO_NEST | RESTRAINED_STRAIGHTJACKET | RESTRAINED_RAZORWIRE | RESTRAINED_PSYCHICGRAB
	if(ignore_checks)
		DISABLE_BITFIELD(flags_to_check, ignore_checks)
	return (. || CHECK_BITFIELD(restrained_flags, flags_to_check))