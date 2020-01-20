//A example runner xeno that uses it's pounce ability

/datum/ai_mind/carbon/xeno/runner
	var/datum/action/xeno_action/activable/pounce/pounce

/datum/ai_mind/carbon/xeno/runner/New()
	..()
	pounce = locate(/datum/action/xeno_action/activable/pounce in mob_parent.actions)

/datum/ai_mind/carbon/xeno/runner/do_process()
	if(istype(atom_to_walk_to, /mob/living/carbon/human))
		if(get_dist(atom_to_walk_to, mob_parent) < 7 && pounce.can_use_ability(atom_to_walk_to, override_flags = XACT_IGNORE_SELECTED_ABILITY))
			pounce.use_ability(atom_to_walk_to)
		return REASON_REFRESH_TARGET
	return ..()
