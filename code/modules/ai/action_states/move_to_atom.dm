//Generic moving to atom, used for stuff like moving to nodes or possibly humans

/datum/action_state/move_to_atom
	var/atom/atomtomoveto //Thing we moving to


/datum/action_state/move_to_atom/GetTargetDir(smart_pathfind) //We give it a direction to the target
	var/mob/living/parent2 = parent_ai.parent
	if(smart_pathfind)
		return get_dir(parent2, get_step_to(parent2, next_node))
	return get_dir(parent2, next_node)

