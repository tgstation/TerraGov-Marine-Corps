//Generic moving to atom, used for stuff like moving to nodes or possibly humans

/datum/action_state/move_to_atom/node //Just here as a base type

/datum/action_state/move_to_atom/node/Process()
	if(get_dist(parent_ai.parent, atomtowalkto) <= distancetomaintain)
		Complete(FINISHED_MOVE)
