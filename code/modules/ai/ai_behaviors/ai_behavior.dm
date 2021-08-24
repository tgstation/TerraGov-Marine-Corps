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
	//We always use the escorted atom as our reference point for looking for target. So if we don't have any escorted atom, we take ourselve as the reference
	src.escorted_atom = escorted_atom ? escorted_atom : parent_to_assign
	mob_parent = parent_to_assign
	START_PROCESSING(SSprocessing, src)

/datum/ai_behavior/Destroy(force, ...)
	. = ..()
	current_node = null
	escorted_atom = null
	mob_parent = null
	atom_to_walk_to = null

///Initiate our base behavior
/datum/ai_behavior/proc/late_initialize()
	switch(base_action)
		if(MOVING_TO_NODE)
			look_for_next_node()
		if(ESCORTING_ATOM)
			change_action(ESCORTING_ATOM, escorted_atom)

//We finished moving to a node, let's pick a random nearby one to travel to
/datum/ai_behavior/proc/finished_node_move()
	SIGNAL_HANDLER
	look_for_next_node(FALSE)

//Cleans up signals related to the action and element(s)
/datum/ai_behavior/proc/cleanup_current_action(next_action)
	if(current_action == MOVING_TO_NODE && next_action != MOVING_TO_NODE)
		current_node = null
	unregister_action_signals(current_action)
	RemoveElement(/datum/element/pathfinder)

///Cleanup old state vars, start the movement towards our new target
/datum/ai_behavior/proc/change_action(next_action, atom/next_target)
	cleanup_current_action(next_action)
	if(next_action)
		current_action = next_action
	if(next_target)
		atom_to_walk_to = next_target
		mob_parent.AddElement(/datum/element/pathfinder, atom_to_walk_to, distance_to_maintain, sidestep_prob)
	register_action_signals(current_action)

///Try to find a node to go to. If ignore_current_node is true, we will just find the closest current_node, and not the current_node best adjacent node
/datum/ai_behavior/proc/look_for_next_node(ignore_current_node = TRUE)
	if(ignore_current_node || !current_node) //We don't have a current node, let's find the closest in our LOS
		var/closest_distance = MAX_NODE_RANGE_SQUARED //squared because we are using the cheap get dist
		var/avoid_node = current_node
		current_node = null
		for(var/obj/effect/ai_node/ai_node AS in GLOB.allnodes)
			if(ai_node == avoid_node)
				continue
			if(get_dist_euclide_square(ai_node, mob_parent) >= closest_distance)
				continue
			/*THIS PART OF THE CODE IS DEALT WITH IN ANOTHER PR
			if(!ai_node.is_in_LOS(get_turf(mob_parent)))
				continue
			*/
			current_node = ai_node
			closest_distance = get_dist_euclide_square(ai_node, mob_parent) //Probably not needed to cache the get_dist
		if(current_node)
			change_action(MOVING_TO_NODE, current_node)
		return
	if(identifier)
		current_node = current_node.get_best_adj_node(list(NODE_LAST_VISITED = -1))
	else
		current_node = pick(current_node.adjacent_nodes)
	current_node.set_weight(identifier, NODE_LAST_VISITED, world.time)
	change_action(MOVING_TO_NODE, current_node)

///Signal handler when the ai is blocked by an obstacle
/datum/ai_behavior/proc/deal_with_obstacle(datum/source, direction)
	SIGNAL_HANDLER

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
			anti_stuck_timer = addtimer(CALLBACK(src, .proc/look_for_next_node), 8 SECONDS, TIMER_STOPPABLE)

/datum/ai_behavior/proc/unregister_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_NODE)
			UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
			deltimer(anti_stuck_timer)
