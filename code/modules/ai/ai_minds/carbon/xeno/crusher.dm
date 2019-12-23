/datum/ai_mind/carbon/xeno/crusher
	var/datum/action/xeno_action/activable/stomp/stomp = new
	var/datum/action/xeno_action/activable/cresttoss/cresttoss = new
	distance_to_maintain = 1 //Get on top of them for a stomp

/datum/ai_mind/carbon/xeno/crusher/New()
	..()
	stomp.owner = mob_parent
	cresttoss.owner = mob_parent

/datum/ai_mind/carbon/xeno/crusher/do_process()
	if(istype(atom_to_walk_to, /mob/living/carbon/human))
		if(get_dist(mob_parent, atom_to_walk_to) < 2 && stomp.can_use_ability())
			stomp.use_ability()
		else
			if(cresttoss.can_use_ability(atom_to_walk_to, override_flags = XACT_IGNORE_SELECTED_ABILITY))
				cresttoss.use_ability(atom_to_walk_to)

		return REASON_REFRESH_TARGET

	return ..()
