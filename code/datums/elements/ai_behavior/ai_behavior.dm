/*
Elementized ai behaviors
Just attach this to a thing and it'll start moving around and such
Controls the mob and determines whats it wants to do
*/

/datum/element/ai_behavior

	var/list/atoms_to_walk_to = list() //An atom for the overall AI to walk to; this is a cache
	var/list/distance_to_maintains = list() //Default distance to maintain from a target while in combat usually
	var/list/sidestep_probs = list() //Prob chance of sidestepping (left or right) when distance maintained with target
	var/list/current_nodes = list() //Current node to use for calculating action states: this is the mob's node
	var/list/cur_actions = list() //Contains a defined term that tells us what we're doing; useful for switch() statements
	var/list/attached_to_mobs = list() //Mobs the element is attached to

/datum/element/ai_behavior/New()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/datum/element/ai_behavior/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/element/ai_behavior/Attach(datum/target, distance_to_maintain = 1, sidestep_prob = 0)
	. = ..()
	if(!ismob(target)) //Requires a mob as the element action states needed to be apply depend on several mob defines like cached_multiplicative_slowdown or action_busy
		stack_trace("An AI behavior was added to a [target.type] that isn't considered compatible with the ai behavior.")
		return COMPONENT_INCOMPATIBLE
	var/atom/movable/movable_target = target
	for(var/obj/effect/ai_node/node in range(7))
		current_nodes[target] = node
		movable_target.forceMove(node.loc)
		break
	if(isnull(current_nodes[target]))
		stack_trace("An AI behavior was being attached to a mob however it was unable to locate a node nearby to attach itself to; stopped attachment.")
		message_admins("Notice: An AI behavior was attached to a thing but wasn't close enough to a node; if you were spawning AI behavior users, then do it closer to a node.")
		return COMPONENT_INCOMPATIBLE

	distance_to_maintains[target] = distance_to_maintain
	sidestep_probs[target] = sidestep_prob

	RegisterSignal(target, list(COMSIG_PARENT_PREQDELETED, COMSIG_MOB_DEATH), .proc/clean_up)
	change_state(movable_target, REASON_FINISHED_NODE_MOVE) //Let's get moving to a adjacent node

/datum/element/ai_behavior/Detach(datum/target, force)
	. = ..()
	unregister_action_signals(target, cur_actions[target])

//Apart of the detaching process, removes signals and unassigns pathfinding
/datum/element/ai_behavior/proc/clean_up(the_mob)
	unregister_action_signals(the_mob, cur_actions[the_mob])
	attached_to_mobs[the_mob].RemoveElement(/datum/element/pathfinder)

//We finished moving to a node, let's pick a random nearby one to travel to
/datum/element/ai_behavior/proc/finished_node_move(mob)
	to_chat(world, mob)
	change_state(attached_to_mobs[mob], REASON_FINISHED_NODE_MOVE)

//Cleans up signals related to the action and element(s)
/datum/element/ai_behavior/proc/cleanup_current_action(mob)
	unregister_action_signals(cur_actions[mob])
	RemoveElement(/datum/element/pathfinder)

//Cleanups variables related to current state then attempts to transition to a new state based on reasoning for interrupting the current action
/datum/element/ai_behavior/proc/change_state(mob/mob, reasoning_for)
	switch(reasoning_for)
		if(REASON_FINISHED_NODE_MOVE)
			cleanup_current_action()
			if(isainode(atoms_to_walk_to[mob])) //Cases where the atom we're walking to can be a mob to kill or turfs
				current_nodes[mob] = atoms_to_walk_to[mob]
			atoms_to_walk_to[mob] = pick(current_nodes[mob].adjacent_nodes)
			mob.AddElement(/datum/element/pathfinder, atoms_to_walk_to[mob], distance_to_maintains[mob], sidestep_probs[mob])
			cur_actions[mob] = MOVING_TO_NODE
			register_action_signals(mob, cur_actions[mob])

//Generic process(), this is used for mainly looking at the world around the AI and determining if a new action must be considered and executed
/datum/element/ai_behavior/process()
	return

/*
Registering and unregistering signals related to a particular cur_action
These are parameter based so the ai behavior can choose to (un)register the signals it wants to rather than based off of cur_action
*/

/datum/element/ai_behavior/proc/register_action_signals(mob, action_type)
	switch(action_type)
		if(MOVING_TO_NODE)
			RegisterSignal(attached_to_mobs[mob], COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)

/datum/element/ai_behavior/proc/unregister_action_signals(mob, action_type)
	switch(action_type)
		if(MOVING_TO_NODE)
			UnregisterSignal(attached_to_mobs[mob], COMSIG_STATE_MAINTAINED_DISTANCE)
