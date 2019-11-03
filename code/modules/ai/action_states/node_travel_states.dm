//Generic moving to atom, used for stuff like moving to nodes or possibly humans

/datum/action_state/move_to_atom/node //Just here as a base type

/datum/action_state/move_to_atom/node/process() //When we get near the node, we're close enough to consider new nodes to travel to
	if(get_dist(parent_ai.parent, atomtomoveto) <= 2)
		if(!istype(atomtomoveto, /obj/effect/AINode))
			stack_trace("Action state to move to a node was given non node target, BAD!!")
			Complete(FINISHED_MOVE)
			return
		else
			parent_ai.current_node = atomtomoveto
			Complete(FINISHED_MOVE)
