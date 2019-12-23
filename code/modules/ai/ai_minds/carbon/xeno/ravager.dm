/datum/ai_mind/carbon/xeno/ravager
	var/datum/action/xeno_action/activable/charge/charge = new

/datum/ai_mind/carbon/xeno/ravager/New()
	..()
	charge.owner = mob_parent

/datum/ai_mind/carbon/xeno/ravager/do_process()
	if(istype(atom_to_walk_to, /mob/living/carbon/human))
		if(get_dist(atom_to_walk_to, mob_parent) < 4 && charge.can_use_ability(atom_to_walk_to, override_flags = XACT_IGNORE_SELECTED_ABILITY))
			charge.use_ability(atom_to_walk_to)
		return REASON_REFRESH_TARGET
	return ..()
