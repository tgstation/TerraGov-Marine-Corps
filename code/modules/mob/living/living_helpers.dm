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

///Fetches the mob's accuracy modifier. Mostly important for humans.
/mob/living/proc/get_mob_accuracy()
	return ranged_accuracy_mod

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
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_FRIENDLY_FIRE_CAUSED))
		TIMER_COOLDOWN_START(src, COOLDOWN_FRIENDLY_FIRE_CAUSED, ff_cooldown)
		friendly_fire[FF_VICTIM_LIST] = list()
		friendly_fire[FF_DAMAGE_OUTGOING] = 0

	friendly_fire[FF_VICTIM_LIST] |= victim
	friendly_fire[FF_DAMAGE_OUTGOING] += total_damage

	// Victim stats
	if(!TIMER_COOLDOWN_CHECK(victim, COOLDOWN_FRIENDLY_FIRE_TAKEN))
		TIMER_COOLDOWN_START(victim, COOLDOWN_FRIENDLY_FIRE_TAKEN, ff_cooldown)
		victim.friendly_fire[FF_DAMAGE_INCOMING] = 0
	victim.friendly_fire[FF_DAMAGE_INCOMING] += total_damage

	// Do we need to take action
	var/ff_limit = CONFIG_GET(number/ff_damage_threshold)
	if(friendly_fire[FF_DAMAGE_OUTGOING] < ff_limit)
		return
	send2adminchat("FF ALERT", "[key_name(src)] was kicked for excessive friendly fire. [friendly_fire[FF_DAMAGE_OUTGOING]] damage witin [ff_cooldown / 10] seconds")
	create_message("note", ckey(client.key), "SYSTEM", "Autokicked due to excessive friendly fire. [friendly_fire[FF_DAMAGE_OUTGOING]] damage within [ff_cooldown / 10] seconds.", null, null, FALSE, FALSE, null, FALSE, "Minor")
	ghostize(FALSE) // make them a ghost (so they can't return to the round)
	qdel(client) // Disconnect the client

	// Heal everyone involved
	for(var/i in friendly_fire[FF_VICTIM_LIST])
		var/mob/living/vic = i
		var/total_heal = vic.friendly_fire[FF_DAMAGE_INCOMING]
		log_admin("[key_name(vic)] healed for [total_heal] due to excessive friendly fire from [key_name(src)]")
		to_chat(vic, span_boldannounce("You've been healed due to the recent friendly fire"))
		vic.heal_overall_damage(total_heal)


#undef FF_VICTIM_LIST
#undef FF_DAMAGE_OUTGOING
#undef FF_DAMAGE_INCOMING

///Gives us a more natural sounding limb name for descriptions and such
/mob/living/proc/get_living_limb_descriptive_name(target_zone)
	if(!target_zone)
		return

	var/target_location_feedback = target_zone
	switch(target_location_feedback)
		if(BODY_ZONE_R_LEG)
			target_location_feedback = "right leg"
		if(BODY_ZONE_L_LEG)
			target_location_feedback = "left leg"
		if(BODY_ZONE_PRECISE_R_FOOT)
			target_location_feedback = "right foot"
		if(BODY_ZONE_PRECISE_L_FOOT)
			target_location_feedback = "left foot"
		if(BODY_ZONE_R_ARM)
			target_location_feedback = "right arm"
		if(BODY_ZONE_L_ARM)
			target_location_feedback = "left arm"
		if(BODY_ZONE_PRECISE_R_HAND)
			target_location_feedback = "right hand"
		if(BODY_ZONE_PRECISE_L_HAND)
			target_location_feedback = "left hand"

	return target_location_feedback

/**
 * Sends a signal to enable throw parrying for the handed duration, provided the throw_parry component is attached. Otherwise, has no real effect.
 * For more information on parries, see throw_parry.dm
**/
/mob/living/proc/enable_throw_parry(duration)
	SEND_SIGNAL(src, COMSIG_PARRY_TRIGGER, duration)
