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

/mob/living/proc/ff_check(total_damage)
	var/list/adm = get_admin_counts(R_ADMIN)
	if(length(adm["present"]) > 0)
		return // Let an admin deal with it.

	var/ff_cooldown = CONFIG_GET(number/ff_damage_reset)
	if(COOLDOWN_CHECK(src, COOLDOWN_FRIENDLY_FIRE))
		ff_damage = 0
	ff_damage += total_damage
	COOLDOWN_START(src, COOLDOWN_FRIENDLY_FIRE, ff_cooldown)

	// Do we need to take action
	var/ff_limit = CONFIG_GET(number/ff_damage_threshold)
	if(ff_damage > ff_limit)
		message_admins("[key_name_admin(src)] would've been kicked for excessive friendly fire. [ff_damage] damage witin [ff_cooldown / 10] seconds")
		// send2tgs("FF ALERT", "[key_name(src)] was kicked for excessive friendly fire. [ff_damage] damage witin [ff_cooldown / 10] seconds")
		// create_message("note", ckey(client.key), "SYSTEM", "Autokicked due to excessive friendly fire. [ff_damage] damage witin [ff_cooldown / 10] seconds.", null, null, FALSE, FALSE, null, FALSE, "Minor")
		// qdel(client) // Disconnect the client




