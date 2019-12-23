//Moves to an atom, sends signals if a distance is maintained

/datum/element/action_state/move_to_atom
	var/list/distances_to_maintain = list() //Distance we want to maintain from atom and send signals once distance has been maintained
	var/list/atoms_to_walk_to = list() //All the targets some mobs gotta move to
	var/list/stutter_step_prob = list() //The prob() chance of a mob going left or right when distance is maintained with the target

/datum/element/action_state/move_to_atom/process()
	for(var/mob/living/carbon/mob in distances_to_maintain)
		if(!mob.canmove || mob.stat == DEAD)
			continue
		if(get_dist(mob, atoms_to_walk_to[mob]) == distances_to_maintain[mob])
			if(istype(atoms_to_walk_to[mob], /obj/effect/ai_node))
				SEND_SIGNAL(mob, COMSIG_CLOSE_TO_NODE)
			if(istype(atoms_to_walk_to[mob], /mob/living))
				SEND_SIGNAL(mob, COMSIG_CLOSE_TO_MOB)
			if(istype(atoms_to_walk_to[mob], /obj/machinery))
				SEND_SIGNAL(mob, COMSIG_CLOSE_TO_MACHINERY)
			if(world.time <= mob.last_move_time + mob.cached_multiplicative_slowdown || mob.action_busy)
				continue
			if(!(get_dir(mob, atoms_to_walk_to[mob]))) //We're right on top, move out of it
				if(!step(mob, pick(CARDINAL_ALL_DIRS)))
					SEND_SIGNAL(mob, COMSIG_OBSTRUCTED_MOVE)
			if(prob(stutter_step_prob[mob]))
				if(!step(mob, pick(LeftAndRightOfDir(get_dir(mob, atoms_to_walk_to[mob]), diagonal_check = TRUE)))) //Couldn't move, something in the way
					SEND_SIGNAL(mob, COMSIG_OBSTRUCTED_MOVE)
			continue
		if(world.time <= mob.last_move_time + mob.cached_multiplicative_slowdown || mob.action_busy)
			continue
		if(get_dist(mob, atoms_to_walk_to[mob]) < distances_to_maintain[mob]) //We're to close, back it up
			if(!step(mob, get_dir(mob, get_step_away(mob, atoms_to_walk_to[mob], distances_to_maintain[mob]))))
				SEND_SIGNAL(mob, COMSIG_OBSTRUCTED_MOVE)
			mob.last_move_time = world.time
			continue
		if(!step(mob, get_dir(mob, get_step_to(mob, atoms_to_walk_to[mob], distances_to_maintain[mob])))) //Couldn't move, something in the way
			SEND_SIGNAL(mob, COMSIG_OBSTRUCTED_MOVE)
		mob.last_move_time = world.time

//mob: the mob that's getting the action state
//atom_to_walk_to: target to move to
//distance to maintain: mob will try to be at this distance away from the atom to walk to
//stutter_step: a prob() chance to go left or right of the mob's direction towards the target when distance has been maintained
/datum/element/action_state/move_to_atom/Attach(mob/living/carbon/mob, atom/atom_to_walk_to, distance_to_maintain = 0, stutter_step = 0)
	. = ..()
	if(mob && iscarbon(mob) && atom_to_walk_to)
		distances_to_maintain[mob] = distance_to_maintain
		atoms_to_walk_to[mob] = atom_to_walk_to
		stutter_step_prob[mob] = stutter_step
	else
		return ELEMENT_INCOMPATIBLE //Not enough args provided or null args

/datum/element/action_state/move_to_atom/Detach(mob/living/carbon/mob)
	distances_to_maintain.Remove(mob)
	atoms_to_walk_to.Remove(mob)
	stutter_step_prob.Remove(mob)
	. = ..()
