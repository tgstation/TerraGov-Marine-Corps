/datum/ai_mind/carbon/xeno/queen
	var/datum/action/xeno_action/activable/screech/screech = new
	var/datum/action/xeno_action/plant_weeds/plantweeds = new

/datum/ai_mind/carbon/xeno/queen/New()
	..()
	screech.owner = mob_parent
	plantweeds.owner = mob_parent

/datum/ai_mind/carbon/xeno/queen/do_process()

	if(istype(atom_to_walk_to, /mob/living/carbon/human) || istype(atom_to_walk_to, /obj/machinery/marine_turret))
		if(length(get_targets()) > 3 && get_dist(atom_to_walk_to, mob_parent) < 6 && screech.can_use_ability(override_flags = XACT_IGNORE_SELECTED_ABILITY)) //Lots of dudes, screech time
			screech.use_ability()
		return REASON_REFRESH_TARGET
	else
		for(var/obj/effect/alien/weeds/node/node in range(1, mob_parent))
			if(node)
				return ..()
		plantweeds.action_activate()
	return ..()
