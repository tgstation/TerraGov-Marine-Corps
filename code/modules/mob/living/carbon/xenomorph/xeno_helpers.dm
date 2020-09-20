
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
/mob/living/carbon/xenomorph/restrained(ignore_checks)
	return FALSE

/mob/living/carbon/xenomorph/get_death_threshold()
	return xeno_caste.crit_health

/mob/living/carbon/xenomorph/proc/returncrestarmor(var/armor) //Defender helper for getting their bonus armor
	return xeno_caste.soft_armor["[armor]"] + xeno_caste.crest_defense_armor

/mob/living/carbon/xenomorph/proc/returnfortifyarmor(var/armor) //Defender helper for getting their bonus armor
	return xeno_caste.soft_armor["[armor]"] + xeno_caste.fortify_armor
