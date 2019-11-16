//A singleton action state; AI components are added to the list and a subsystem will periodically call the process() for this
/datum/element/action_state

/datum/element/action_state/Attach(mob/living/carbon/mob)
	if(mob && istype(mob))
		..()
	else
		return ELEMENT_INCOMPATIBLE

/datum/element/action_state/Detach()
	ai_components -= ai
	..()

//A special process() that doesn't rely on the processing subsystem but rather the action_states subsystem
/datum/element/action_state/proc/state_process(mob/living/carbon/mob)
	for(var/mob/living/carbon/mob in

/datum/element/action_state/move_to_atom
	var/list/distances_to_maintain = list() //Distance we want to maintain from atom and send signals once distance has been maintained
	var/list/atoms_to_walk_to
	var/list/last_moves = list() //Last world.time we moved at, move delay calculation

/datum/element/action_state/move_to_atom/state_process(mob/living/carbon/mob)
	if(get_dist(mob, atoms_to_walk_to[mob]) == distances_to_maintain[mob])
		return
	current_mob = mob.parent
	if(last_moves[ai] > world.time + current_mob.movement_delay())
		return
	else
		step(ai.parent, get_dir(ai.parent, wrapped_get_step_to(ai.parent, atoms_to_walk_to[ai], distances_to_maintain[ai])))
		last_moves[ai] = world.time + current_mob.movement_delay()

/datum/element/action_state/move_to_atom/Attach(mob/living/carbon/mob, atom/atom_to_walk_to, distance_to_maintain)
	if(!QDELETED(ai) && iscarbon(ai.parent) && atom_to_walk_to)
		ai_components += ai
		atoms_to_walk_to[ai] = atom_to_walk_to
		distance_to_maintain[ai] = distance_to_maintain
		last_moves[ai] = world.time

/datum/element/action_state/move_to_atom/Detach(mob/living/carbon/mob)
	distances_to_maintain.Remove(ai)
	last_moves.Remove(ai)
