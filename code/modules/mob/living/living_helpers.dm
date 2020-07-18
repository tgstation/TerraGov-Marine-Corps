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


#define FF_VICTIM_LIST "victim_list"
#define FF_DAMAGE_OUTGOING "damage_outgoing"
#define FF_DAMAGE_INCOMING "damage_incoming"
/mob/living/proc/ff_check(total_damage, mob/living/victim)
	if(victim == src)
		return

	// We don't take action on victimless crimes
	if(victim.stat == DEAD || !victim.client)
		return

	var/list/adm = get_admin_counts(R_ADMIN)
	if(length(adm["present"]) > 0)
		return // Let an admin deal with it.

	var/ff_cooldown = CONFIG_GET(number/ff_damage_reset)
	if(!COOLDOWN_CHECK(src, COOLDOWN_FRIENDLY_FIRE_CAUSED))
		COOLDOWN_START(src, COOLDOWN_FRIENDLY_FIRE_CAUSED, ff_cooldown)
		friendly_fire[FF_VICTIM_LIST] = list()
		friendly_fire[FF_DAMAGE_OUTGOING] = 0

	friendly_fire[FF_VICTIM_LIST] |= victim
	friendly_fire[FF_DAMAGE_OUTGOING] += total_damage

	// Victim stats
	if(!COOLDOWN_CHECK(victim, COOLDOWN_FRIENDLY_FIRE_TAKEN))
		COOLDOWN_START(victim, COOLDOWN_FRIENDLY_FIRE_TAKEN, ff_cooldown)
		victim.friendly_fire[FF_DAMAGE_INCOMING] = 0
	victim.friendly_fire[FF_DAMAGE_INCOMING] += total_damage

	// Do we need to take action
	var/ff_limit = CONFIG_GET(number/ff_damage_threshold)
	if(friendly_fire[FF_DAMAGE_OUTGOING] < ff_limit)
		return
	send2tgs("FF ALERT", "[key_name(src)] was kicked for excessive friendly fire. [friendly_fire[FF_DAMAGE_OUTGOING]] damage witin [ff_cooldown / 10] seconds")
	create_message("note", ckey(client.key), "SYSTEM", "Autokicked due to excessive friendly fire. [friendly_fire[FF_DAMAGE_OUTGOING]] damage within [ff_cooldown / 10] seconds.", null, null, FALSE, FALSE, null, FALSE, "Minor")
	ghostize(FALSE) // make them a ghost (so they can't return to the round)
	qdel(client) // Disconnect the client

	// Heal everyone involved
	for(var/i in friendly_fire[FF_VICTIM_LIST])
		var/mob/living/vic = i
		var/total_heal = vic.friendly_fire[FF_DAMAGE_INCOMING]
		log_admin("[key_name(vic)] healed for [total_heal] due to excessive friendly fire from [key_name(src)]")
		to_chat(vic, "<span class='boldannounce'>You've been healed due to the recent friendly fire</span>")
		vic.heal_overall_damage(total_heal)


#undef FF_VICTIM_LIST
#undef FF_DAMAGE_OUTGOING
#undef FF_DAMAGE_INCOMING
