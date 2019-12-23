/datum/ai_mind/carbon/xeno/sentinel
	var/datum/action/xeno_action/activable/xeno_spit/xeno_spit = new
	distance_to_maintain = 5 //Fair kiting range

/datum/ai_mind/carbon/xeno/sentinel/New()
	..()
	xeno_spit.owner = mob_parent

/datum/ai_mind/carbon/xeno/sentinel/do_process()
	if(istype(atom_to_walk_to, /mob/living/carbon/human) || istype(atom_to_walk_to, /obj/machinery/marine_turret))
		if(get_dist(atom_to_walk_to, mob_parent) < 8 && xeno_spit.can_use_ability(atom_to_walk_to, TRUE, override_flags = XACT_IGNORE_SELECTED_ABILITY))
			xeno_spit.use_ability(atom_to_walk_to)
		return REASON_REFRESH_TARGET
	return ..()
