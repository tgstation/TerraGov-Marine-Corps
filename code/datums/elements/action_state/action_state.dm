//A singleton action state; AI components are added to the list and a subsystem will periodically call the process() for this
/datum/element/action_state
	element_flags = ELEMENT_DETACH //Detaches on mob death and when Qdel'd

/datum/element/action_state/New()
	. = ..()
	SSactionstate.processing += src

/datum/element/action_state/Attach(mob/living/carbon/mob)
	if(mob && istype(mob))
		. = ..()
		RegisterSignal(mob, COMSIG_MOB_DEATH, .proc/RemoveElement, src) //Remove on death
	else
		return ELEMENT_INCOMPATIBLE

//A special process() that doesn't rely on the processing subsystem but rather the action_states subsystem
/datum/element/action_state/proc/state_process()

/datum/element/action_state/move_to_atom
	var/list/distances_to_maintain = list() //Distance we want to maintain from atom and send signals once distance has been maintained
	var/list/atoms_to_walk_to = list()
	var/move_delay //Placeholder variable used to store the current move_delay via movement_delay(), saves cpu from not needing duplicate calls

/datum/element/action_state/move_to_atom/state_process()
	for(var/mob/living/carbon/mob in distances_to_maintain)
		if(get_dist(mob, atoms_to_walk_to[mob]) != distances_to_maintain[mob])
			SEND_SIGNAL(mob, COMSIG_MOB_TARGET_REACHED)
			continue
		move_delay = mob.movement_delay()
		if(world.time <= mob.last_move_time + move_delay)
			continue
		else
			mob.Move(get_step_to(mob, atoms_to_walk_to[mob], distances_to_maintain[mob]))

/datum/element/action_state/move_to_atom/Attach(mob/living/carbon/mob, atom/atom_to_walk_to, distance_to_maintain)
	if(mob && iscarbon(mob) && atom_to_walk_to)
		distances_to_maintain[mob] = distance_to_maintain
		atoms_to_walk_to[mob] = atom_to_walk_to

/datum/element/action_state/move_to_atom/Detach(mob/living/carbon/mob)
	distances_to_maintain.Remove(mob)
	..()

/datum/element/action_state/move_to_atom/node //Uses node signal instead of DISTANCE_MAINTAINEd

/datum/element/action_state/move_to_atom/node/state_process()
	for(var/mob/living/carbon/mob in distances_to_maintain)
		if(get_dist(mob, atoms_to_walk_to[mob]) == distances_to_maintain[mob])
			SEND_SIGNAL(mob, COMSIG_MOB_TARGET_REACHED)
			continue
		move_delay = mob.movement_delay()
		if(mob.last_move > world.time + move_delay)
			continue
		else
			mob.Move(get_step_to(mob, atoms_to_walk_to[mob], distances_to_maintain[mob]))
