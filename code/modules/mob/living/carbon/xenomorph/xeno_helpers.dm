
/mob/living/carbon/Xenomorph/can_ventcrawl()
	if(mob_size == MOB_SIZE_BIG || !(xeno_caste.caste_flags & CASTE_CAN_VENT_CRAWL))
		return FALSE
	else
		return TRUE

/mob/living/carbon/Xenomorph/ventcrawl_carry()
	return TRUE


/mob/living/carbon/Xenomorph/can_inject(mob/user, error_msg, target_zone, penetrate_thick = FALSE)
	return FALSE




//These don't do much currently. Or anything? Only around for legacy code.
/mob/living/carbon/Xenomorph/restrained()
	return FALSE

/mob/living/carbon/Xenomorph/has_smoke_protection()
	return TRUE

/mob/living/carbon/Xenomorph/smoke_contact()
	return

/mob/living/carbon/Xenomorph/a_select_zone(input as text, screen_num as null|num)
	screen_num = 8
	return ..()


/mob/living/carbon/Xenomorph/toggle_move_intent(screen_num as null|num)
	screen_num = 2
	. = ..()
	update_icons()