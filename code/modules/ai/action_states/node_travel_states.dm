//Generic moving to atom, used for stuff like moving to nodes or possibly humans

/datum/action_state/move_to_atom/node //Just here as a base type

/datum/action_state/move_to_atom/node/process() //When we get near the node, we're close enough to consider new nodes to travel to
	if(get_dist(parent_ai.parent, atomtomoveto) <= distance_to_maintain)
		Complete(FINISHED_MOVE)
