
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

/mob/living/carbon/xenomorph/switch_attack_type()
	/datum/component/directional_attack/d_attack = GetComponent(/datum/component/directional_attack)
	/datum/component/directional_attack/b_attack = GetComponent(/datum/component/bump_attack)
	b_attack.active = !b_attack.active
	d_attack.active = !d_attack.active
	if(d_attack.active && !b_attack.active)
		to_chat(src, "<span class='notice'>You will now attack enemies in melee range upon clicking in their direction.</span>")
		RegisterSignal(src, COMSIG_MOB_CLICKON, .proc/d_attack.select_directional_action)
		UnregisterSignal(src, COMSIG_MOVABLE_BUMP)
	else if(b_attack.active && !d_attack.active)
		RegisterSignal(src, COMSIG_MOVABLE_BUMP, .proc/b_attack.bump_action_path)
		UnregisterSignal(src, COMSIG_MOB_CLICKON, .proc/d_attack.select_directional_action)
		