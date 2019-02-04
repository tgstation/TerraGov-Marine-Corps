
/mob/living/carbon/Xenomorph/can_ventcrawl()
	if(mob_size == MOB_SIZE_BIG || !(xeno_caste.caste_flags & CASTE_CAN_VENT_CRAWL))
		return FALSE
	else
		return TRUE

/mob/living/carbon/Xenomorph/ventcrawl_carry()
	return TRUE


/mob/living/carbon/Xenomorph/can_inject()
	return FALSE

//These don't do much currently. Or anything? Only around for legacy code.
/mob/living/carbon/Xenomorph/is_mob_restrained()
	return FALSE

/mob/living/carbon/Xenomorph/has_smoke_protection()
	return TRUE

/mob/living/carbon/Xenomorph/are_eyes_covered(check_glasses = TRUE, check_head = TRUE, check_mask = TRUE, check_limb = FALSE)
	return TRUE

/mob/living/carbon/Xenomorph/a_select_zone(input as text, screen_num as null|num)
	screen_num = 9
	return ..()
