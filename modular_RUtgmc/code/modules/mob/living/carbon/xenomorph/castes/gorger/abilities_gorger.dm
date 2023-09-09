// ***************************************
// *********** Drain blood
// ***************************************

/datum/action/xeno_action/activable/drain/use_ability(mob/living/carbon/human/target_human)
	. = ..()
	target_human.blood_volume = max(target_human.blood_volume - 30, 0)

// ***************************************
// *********** Transfusion
// ***************************************

/datum/action/xeno_action/activable/transfusion/can_use_ability(atom/target, silent = FALSE, override_flags) //it is set up to only return true on specific xeno or human targets
	. = ..()
	if(!.)
		return

	if(!isxeno(target))
		if(!silent)
			to_chat(owner, span_notice("We can only restore familiar biological lifeforms."))
		return FALSE

	var/mob/living/carbon/xenomorph/target_xeno = target

	if(owner.do_actions)
		return FALSE
	if(!line_of_sight(owner, target_xeno, 3) || get_dist(owner, target_xeno) > 3)
		if(!silent)
			to_chat(owner, span_notice("It is beyond our reach, we must be close and our way must be clear."))
		return FALSE
	if(target_xeno.stat == DEAD)
		if(!silent)
			to_chat(owner, span_notice("We can only help living sisters."))
		return FALSE
	target_health = target_xeno.health
	if(!do_mob(owner, target_xeno, 1 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL, ignore_flags = IGNORE_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(extra_health_check), target_xeno)))
		return FALSE
	return TRUE

// ***************************************
// *********** Psychic Link
// ***************************************

/datum/action/xeno_action/activable/psychic_link
	desc = "Link to a xenomorph and take some damage in their place."
	cooldown_timer = 15 SECONDS

/datum/action/xeno_action/activable/psychic_link/use_ability(atom/target)
	if(HAS_TRAIT(owner, TRAIT_PSY_LINKED))
		to_chat(owner, span_notice("Cancelled link to [target]."))
		cancel_psychic_link()
		return
	return ..()

// ***************************************
// *********** Feast
// ***************************************
/datum/action/xeno_action/activable/feast
	cooldown_timer = 30 SECONDS
