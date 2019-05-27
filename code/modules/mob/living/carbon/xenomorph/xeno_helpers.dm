
/mob/living/carbon/xenomorph/can_ventcrawl()
	if(mob_size == MOB_SIZE_BIG || !(xeno_caste.caste_flags & CASTE_CAN_VENT_CRAWL))
		return FALSE
	else
		return TRUE

/mob/living/carbon/xenomorph/ventcrawl_carry()
	return TRUE

/mob/living/carbon/human/get_reagent_tags()
	. = ..()
	return .|IS_XENO

/mob/living/carbon/xenomorph/can_inject(mob/user, error_msg, target_zone, penetrate_thick = FALSE)
	return FALSE

//These don't do much currently. Or anything? Only around for legacy code.
/mob/living/carbon/xenomorph/restrained()
	return FALSE

/mob/living/carbon/xenomorph/has_smoke_protection()
	return TRUE

/mob/living/carbon/xenomorph/smoke_contact()
	return