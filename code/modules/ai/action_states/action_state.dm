//A singleton action state; AI components are added to the list and a subsystem will periodically call the process() for this
//AI components will also GetTargetDir() from the action_state their connected to so they can have a direction to move in
/datum/element/action_state
	var/list/ai_components = list() //All AI components currently attached to this action state

/datum/element/action_state/New()
	..()
	if(!QDELETED(src)) //No duplicates allowed
		SSactionstate.action_states += src

/datum/element/action_state/proc/attach_component(datum/component/ai_behavior/ai)
	if(!QDELETED(ai) && iscarbon(ai.parent))
		ai_components += ai
	else
		return ELEMENT_INCOMPATIBLE

/datum/element/action_state/proc/detach_component(datum/component/ai_behavior/ai)
	if(!QDELETED(ai))
		ai_components -= ai

//A special process() that doesn't rely on the processing subsystem but rather the action_states subsystem
/datum/element/action_state/proc/state_process(datum/component/ai_behavior/ai)

/datum/element/action_state/move_to_atom
	var/list/distances_to_maintain = list() //Distance we want to maintain from atom and send signals once distance has been maintained
	var/list/atoms_to_walk_to
	var/mob/living/carbon/current_mob //Defining it here so I don't have to make a new var every process for typecasting purposes
	var/list/last_moves = list() //Last world.time we moved at, move delay calculation

/datum/element/action_state/move_to_atom/state_process(datum/component/ai_behavior/ai)
	if(get_dist(ai.parent, atoms_to_walk_to[ai]) == distances_to_maintain[ai])
		SEND_SIGNAL(ai, DISTANCE_MAINTAINED)
		return
	current_mob = ai.parent
	if(last_moves[ai] > world.time + current_mob.movement_delay())
		return
	else
		step(ai.parent, get_dir(ai.parent, wrapped_get_step_to(ai.parent, atoms_to_walk_to[ai], distances_to_maintain[ai])))
		last_moves[ai] = world.time + current_mob.movement_delay()

/datum/element/action_state/move_to_atom/attach_component(datum/component/ai_behavior/ai, atom/atom_to_walk_to, distance_to_maintain)
	if(!QDELETED(ai) && iscarbon(ai.parent) && atom_to_walk_to)
		ai_components += ai
		atoms_to_walk_to += ai
		atoms_to_walk_to[ai] = atom_to_walk_to
		distance_to_maintain += ai
		distance_to_maintain[ai] = distance_to_maintain
		last_moves += ai
		last_moves[ai] = world.time

/datum/element/action_state/move_to_atom/detach_component(datum/component/ai_behavior/ai)
	if(!QDELETED(ai))
		ai_components -= ai
	distances_to_maintain.Remove(ai)
	last_moves.Remove(ai)

/datum/element/action_state/move_to_atom/node //Node basetype, moves to random nodes nearby
	//atoms_to_walk_to are now classified as nodes and will be typecasted as such

/datum/element/action_state/move_to_atom/node/state_process(datum/component/ai_behavior/ai)
	if(get_dist(ai.parent, atoms_to_walk_to[ai]) == distances_to_maintain[ai])
		SEND_SIGNAL(ai, NODE_REACHED)
		return
	current_mob = ai.parent
	if(last_moves[ai] > world.time + current_mob.movement_delay())
		return
	else
		step(ai.parent, get_dir(ai.parent, wrapped_get_step_to(ai.parent, atoms_to_walk_to[ai], distances_to_maintain[ai])))
		last_moves[ai] = world.time + current_mob.movement_delay()
