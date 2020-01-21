//Moves to an atom, sends signals if a distance is maintained

/datum/element/action_state/move_to_atom
	var/list/distances_to_maintain = list() //Distance we want to maintain from atom and send signals once distance has been maintained
	var/list/atoms_to_walk_to = list() //All the targets some mobs gotta move to
	var/list/stutter_step_prob = list() //The prob() chance of a mob going left or right when distance is maintained with the target

/datum/element/action_state/move_to_atom/process()
	for(var/mob in distances_to_maintain)
		var/mob/mob_to_process = mob
		if(!mob_to_process.canmove || mob_to_process.stat == DEAD)
			continue
		if(get_dist(mob_to_process, atoms_to_walk_to[mob_to_process]) == distances_to_maintain[mob_to_process])
			SEND_SIGNAL(mob_to_process, COMSIG_STATE_MAINTAINED_DISTANCE)
			if(world.time <= mob_to_process.last_move_time + mob_to_process.cached_multiplicative_slowdown || mob_to_process.action_busy)
				continue
			if(!(get_dir(mob_to_process, atoms_to_walk_to[mob_to_process]))) //We're right on top, move out of it
				if(!step(mob_to_process, pick(CARDINAL_ALL_DIRS)))
					SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE)
			if(prob(stutter_step_prob[mob_to_process]))
				if(!step(mob_to_process, pick(LeftAndRightOfDir(get_dir(mob_to_process, atoms_to_walk_to[mob_to_process]), diagonal_check = TRUE)))) //Couldn't move, something in the way
					SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE)
			continue
		if(world.time <= mob_to_process.last_move_time + mob_to_process.cached_multiplicative_slowdown || mob_to_process.action_busy)
			continue
		if(get_dist(mob_to_process, atoms_to_walk_to[mob_to_process]) < distances_to_maintain[mob_to_process]) //We're too close, back it up
			if(!step(mob_to_process, get_dir(mob, get_step_away(mob_to_process, atoms_to_walk_to[mob_to_process], distances_to_maintain[mob_to_process]))))
				SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE)
			mob_to_process.last_move_time = world.time
			continue
		if(!step(mob_to_process, get_dir(mob_to_process, get_step_to(mob_to_process, atoms_to_walk_to[mob_to_process], distances_to_maintain[mob_to_process])))) //Couldn't move, something in the way
			SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE)
		mob_to_process.last_move_time = world.time

//mob: the mob that's getting the action state
//atom_to_walk_to: target to move to
//distance to maintain: mob will try to be at this distance away from the atom to walk to
//stutter_step: a prob() chance to go left or right of the mob's direction towards the target when distance has been maintained
/datum/element/action_state/move_to_atom/Attach(mob/mob, atom/atom_to_walk_to, distance_to_maintain = 0, stutter_step = 0)
	. = ..()
	if(QDELETED(mob))
		return ELEMENT_INCOMPATIBLE
	if(!ismob(mob))
		return ELEMENT_INCOMPATIBLE
	if(!atom_to_walk_to)
		return ELEMENT_INCOMPATIBLE
	distances_to_maintain[mob] = distance_to_maintain
	atoms_to_walk_to[mob] = atom_to_walk_to
	stutter_step_prob[mob] = stutter_step

/datum/element/action_state/move_to_atom/Detach(mob/mob)
	distances_to_maintain.Remove(mob)
	atoms_to_walk_to.Remove(mob)
	stutter_step_prob.Remove(mob)
	return ..()
