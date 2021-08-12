/*
AI BEHAVIOR

The actual thinking brain that determines what it wants the mob to do
Registers signals, handles the pathfinding element addition/removal alongside making the mob do actions
*/

/datum/ai_behavior
	///What atom is the ai moving to
	var/atom/atom_to_walk_to
	///How far should we stay away from atom_to_walk_to
	var/distance_to_maintain = 1
	///Prob chance of sidestepping (left or right) when distance maintained with target
	var/sidestep_prob = 0
	///Current node to use for calculating action states: this is the mob's node
	var/obj/effect/ai_node/current_node
	///What the ai is doing right now
	var/current_action
	///The standard ation of the AI, aka what it should do at the init or when going back to "normal" behavior
	var/base_action = MOVING_TO_NODE
	///Ref to the parent associated with this mind
	var/mob/mob_parent
	///An identifier associated with this behavior, used for accessing specific values of a node's weights
	var/identifier
	///How far will we look for targets
	var/target_distance = 8
	///What we will escort
	var/atom/escorted_atom
	///When this timer is up, we force a change of node to ensure that the ai will never stay stuck trying to go to a specific node
	var/anti_stuck_timer

/datum/ai_behavior/New(loc, parent_to_assign, escorted_atom)
	..()
	if(isnull(parent_to_assign))
		stack_trace("An ai behavior was initialized without a parent to assign it to; destroying mind. Mind type: [type]")
		qdel(src)
		return
	src.escorted_atom = escorted_atom ? escorted_atom : parent_to_assign //If null, we will escort... ourselves
	mob_parent = parent_to_assign
	START_PROCESSING(SSprocessing, src)

/datum/ai_behavior/Destroy(force, ...)
	. = ..()
	deltimer(anti_stuck_timer)
	anti_stuck_timer = null
	escorted_atom = null
	mob_parent = null
	atom_to_walk_to = null

///Initiate our base behavior
/datum/ai_behavior/proc/late_initialize()
	current_action = base_action
	switch(current_action)
		if(MOVING_TO_NODE)
			look_for_nodes()
		if(ESCORTING_ATOM)
			change_action(ESCORTING_ATOM, escorted_atom)

//We finished moving to a node, let's pick a random nearby one to travel to
/datum/ai_behavior/proc/finished_node_move()
	SIGNAL_HANDLER
	look_for_nodes()

//Cleans up signals related to the action and element(s)
/datum/ai_behavior/proc/cleanup_current_action()
	unregister_action_signals(current_action)
	RemoveElement(/datum/element/pathfinder)

///Cleanup old state vars, start the movement towards our new target
/datum/ai_behavior/proc/change_action(next_action, atom/next_target)
	cleanup_current_action()
	if(next_action)
		current_action = next_action
	if(next_target)
		atom_to_walk_to = next_target
		mob_parent.AddElement(/datum/element/pathfinder, atom_to_walk_to, distance_to_maintain, sidestep_prob)
	register_action_signals(current_action)

///Try to find a node to go to
/datum/ai_behavior/proc/look_for_nodes()
	if(isainode(atom_to_walk_to)) //Cases where the atom we're walking to can be a mob to kill or turfs
		current_node = atom_to_walk_to
		if(identifier)
			current_node.set_weight(identifier, NODE_LAST_VISITED, world.time) //We recently visited this node, update the time

	if(identifier)
		atom_to_walk_to = current_node.get_best_adj_node(list(NODE_LAST_VISITED = -1), identifier)
	else
		atom_to_walk_to = pick(current_node.adjacent_nodes)
	change_action(MOVING_TO_NODE, atom_to_walk_to)

//Generic process(), this is used for mainly looking at the world around the AI and determining if a new action must be considered and executed
/datum/ai_behavior/process()
	look_for_new_state()
	return

///Check if we need to adopt a new state
/datum/ai_behavior/proc/look_for_new_state()
	SIGNAL_HANDLER
	return

/*
Registering and unregistering signals related to a particular current_action
These are parameter based so the ai behavior can choose to (un)register the signals it wants to rather than based off of current_action
*/
/datum/ai_behavior/proc/register_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_NODE)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)
			anti_stuck_timer = addtimer(CALLBACK(src, .proc/look_for_nodes), 45 SECONDS)

/datum/ai_behavior/proc/unregister_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_NODE)
			UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
			deltimer(anti_stuck_timer)
