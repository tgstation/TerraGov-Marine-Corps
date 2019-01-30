
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


/mob/living/carbon/Xenomorph/a_select_zone(input as text, screen_num as null|num)
	screen_num = 9
	return ..()


/mob/living/carbon/Xenomorph/lay_down()
	set name = "Rest"
	set category = "IC"

	if(is_mob_incapacitated(TRUE))
		return

	if(!resting)
		resting = TRUE
		to_chat(src, "<span class='notice'>You are now resting.</span>")
		update_canmove()
	else
		if(action_busy) // do_after is unoptimal
			return
		if(do_after(src, 10, FALSE, 5, BUSY_ICON_GENERIC, FALSE, FALSE, TRUE) && !is_mob_incapacitated(TRUE))
			to_chat(src, "<span class='notice'>You get up.</span>")
			resting = FALSE
			update_canmove()
		else
			to_chat(src, "<span class='notice'>You fail to get up.</span>")
