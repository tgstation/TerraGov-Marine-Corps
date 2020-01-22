//A example runner xeno that uses it's pounce ability

/datum/ai_behavior/carbon/xeno/runner
	var/datum/action/xeno_action/activable/pounce/pounce

/datum/ai_behavior/carbon/xeno/runner/New()
	..()
	pounce = mob_parent.actions_by_path[/datum/action/xeno_action/activable/pounce]

/datum/ai_behavior/carbon/xeno/runner/do_process()
	if(!iscarbon(atom_to_walk_to))
		return ..()
	if(get_dist(atom_to_walk_to, mob_parent) > 6)
		return ..()
	if(!pounce.can_use_ability(atom_to_walk_to, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()

	pounce.use_ability(atom_to_walk_to)
	return REASON_REFRESH_TARGET
