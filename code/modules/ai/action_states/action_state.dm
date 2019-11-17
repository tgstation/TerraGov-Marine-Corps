//A singleton action state; AI components are added to the list and a subsystem will periodically call the process() for this
/datum/element/action_state
	var/list/mobs = list() //All mobs attached to this

/datum/element/action_state/Attach(mob/living/carbon/mob)
	if(mob && istype(mob))
		..()
	else
		return ELEMENT_INCOMPATIBLE

/datum/element/action_state/Detach(mob/living/carbon/mob, force)
	mobs.Remove(mob)
	..()

//A special process() that doesn't rely on the processing subsystem but rather the action_states subsystem
/datum/element/action_state/proc/state_process(mob/living/carbon/mob)

/datum/element/action_state/move_to_atom
	var/list/distances_to_maintain = list() //Distance we want to maintain from atom and send signals once distance has been maintained
	var/list/atoms_to_walk_to = list()
	var/list/last_moves = list() //Last world.time we moved at, move delay calculation

/datum/element/action_state/move_to_atom/state_process()
	for(var/mob/living/carbon/mob in mobs)
		if(get_dist(mob, atoms_to_walk_to[mob]) == distances_to_maintain[mob])
			return
		if(mob.last_move > world.time + mob.movement_delay())
			return
		else
			step(mob, get_dir(mob, wrapped_get_step_to(mob, atoms_to_walk_to[mob], distances_to_maintain[mob])))
			mob.last_move = world.time + mob.movement_delay()

/datum/element/action_state/move_to_atom/Attach(mob/living/carbon/mob, atom/atom_to_walk_to, distance_to_maintain)
	if(!QDELETED(mob) && iscarbon(mob) && atom_to_walk_to)
		mobs += mob
		atoms_to_walk_to[mob] = atom_to_walk_to
		distance_to_maintain[mob] = distance_to_maintain
		last_moves[mob] = world.time

/datum/element/action_state/move_to_atom/Detach(mob/living/carbon/mob)
	distances_to_maintain.Remove(mob)
	last_moves.Remove(mob)
	mobs.Remove(mob)
	..()