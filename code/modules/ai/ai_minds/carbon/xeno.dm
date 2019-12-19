//Generic ai mind, goes around attacking but with the alien attack proc instead of carbon fist
/datum/ai_mind/carbon/xeno
	starting_signals = list(COMSIG_XENOMORPH_TAKING_DAMAGE = /datum/component/ai_behavior/proc/do_action,
							COMSIG_MOB_TARGET_REACHED = /datum/component/ai_behavior/proc/do_action)


/datum/ai_mind/carbon/xeno/request_action(mob/living/parent)
	if(istype(atom_to_walk_to, /mob/living/carbon) &&  parent.next_move < world.time && get_dist(parent, atom_to_walk_to) <= 1)
		return(list(atom_to_walk_to, /mob/living/attack_alien, list(parent)))

/datum/ai_mind/carbon/xeno/get_new_state(reason_for, mob/living/parent)
	for(var/mob/living/carbon/human/h in cheap_get_humans_near(h, 7))
		if(h && h.stat != DEAD)
			atom_to_walk_to = h
			cur_action_state = /datum/element/action_state/move_to_atom
			return list(cur_action_state, atom_to_walk_to, distance_to_maintain, stutter_step = 25)

	return ..()
	/*
	if(!reason_for || reason_for == COMSIG_FINISHED_NODE_MOVE) //AI mind got initialized or something messed up
		atom_to_walk_to = pick(current_node.datumnode.adjacent_nodes)
		cur_action_state = /datum/element/action_state/move_to_atom
		return list(cur_action_state, atom_to_walk_to, distance_to_maintain)
	*/

