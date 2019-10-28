//Generic moving to atom, used for stuff like moving to nodes or possibly humans
//This will never end and will continue going on forever by default

/datum/action_state/move_to_atom
	var/atom/atomtomoveto //Thing we moving to, MANUALLY ASSIGN THIS SOMEWHERE
	var/distance_to_maintain //Distance we want to get to; also can be used to trigger specific things

/datum/action_state/move_to_atom/GetTargetDir(smart_pathfind) //We give it a direction to the target
	var/mob/living/parent2 = parent_ai.parent
	if(smart_pathfind)
		return get_dir(parent2, get_step_to(parent2, atomtomoveto, distance_to_maintain))
	return get_dir(parent2, atomtomoveto)
