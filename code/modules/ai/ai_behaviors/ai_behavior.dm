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
	///The node goal of this ai
	var/obj/effect/ai_node/goal_node
	///A list of nodes the ai should go to in order to go to goal_node
	var/list/obj/effect/ai_node/goal_nodes
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
	///Minimum health percentage before the ai tries to run away
	var/minimum_health = 0.4

/datum/ai_behavior/New(loc, mob/parent_to_assign, atom/escorted_atom)
	..()
	if(isnull(parent_to_assign))
		stack_trace("An ai behavior was initialized without a parent to assign it to; destroying mind. Mind type: [type]")
		qdel(src)
		return
	//We always use the escorted atom as our reference point for looking for target. So if we don't have any escorted atom, we take ourselve as the reference
	if(escorted_atom)
		src.escorted_atom = escorted_atom
	else
		src.escorted_atom = parent_to_assign
		RegisterSignal(SSdcs, COMSIG_GLOB_AI_MINION_RALLY, .proc/set_escorted_atom)
	RegisterSignal(escorted_atom, COMSIG_PARENT_QDELETING, .proc/clean_escorted_atom)
	mob_parent = parent_to_assign
	RegisterSignal(SSdcs, COMSIG_GLOB_AI_GOAL_SET, .proc/set_goal_node)
	goal_node = GLOB.goal_nodes[identifier]
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
	mob_parent.RemoveElement(/datum/element/pathfinder, atom_to_walk_to, distance_to_maintain, sidestep_prob)

///Cleanup old state vars, start the movement towards our new target
/datum/ai_behavior/proc/change_action(next_action, atom/next_target, special_distance_to_maintain)
	cleanup_current_action(next_action)
	#ifdef TESTING
	switch(next_action)
		if(MOVING_TO_NODE)
			message_admins("[mob_parent] goes to a new node")
			flick("x2_animate", next_target)
		if(MOVING_TO_ATOM)
			message_admins("[mob_parent] moves toward [next_target]")
		if(MOVING_TO_SAFETY)
			message_admins("[mob_parent] wants to escape from [next_target]")
		if(ESCORTING_ATOM)
			message_admins("[mob_parent] escorts [next_target]")
	#endif
	if(next_action)
		current_action = next_action
	if(current_action == ESCORTING_ATOM)
		distance_to_maintain = 2 //Don't stay too close
	else
		distance_to_maintain = isnull(special_distance_to_maintain) ? initial(distance_to_maintain) : special_distance_to_maintain
	if(next_target)
		atom_to_walk_to = next_target
		mob_parent.AddElement(/datum/element/pathfinder, atom_to_walk_to, distance_to_maintain, sidestep_prob)
	register_action_signals(current_action)
	if(current_action == MOVING_TO_SAFETY)
		mob_parent.a_intent = INTENT_HELP
	else
		mob_parent.a_intent = INTENT_HARM

///Try to find a node to go to. If ignore_current_node is true, we will just find the closest current_node, and not the current_node best adjacent node
/datum/ai_behavior/proc/look_for_next_node(ignore_current_node = TRUE, should_reset_goal_nodes = FALSE)
	if(should_reset_goal_nodes)
		goal_nodes = null
	if(ignore_current_node || !current_node) //We don't have a current node, let's find the closest in our LOS
		var/closest_distance = MAX_NODE_RANGE //squared because we are using the cheap get dist
		var/avoid_node = current_node
		current_node = null
		for(var/obj/effect/ai_node/ai_node AS in GLOB.allnodes)
			if(ai_node == avoid_node)
				continue
			if(ai_node.z != mob_parent.z || get_dist(ai_node, mob_parent) >= closest_distance)
				continue
			current_node = ai_node
			closest_distance = get_dist(ai_node, mob_parent) //Probably not needed to cache the get_dist
		if(current_node)
			change_action(MOVING_TO_NODE, current_node)
		return
	if(goal_node)
		if(!length(goal_nodes))
			goal_nodes = get_node_path(current_node, goal_node)
		if(!length(goal_nodes))
			current_node = null
			look_for_next_node()
			return
		current_node = goal_nodes[length(goal_nodes)]
		goal_nodes.len--
	else
		current_node = current_node.get_best_adj_node(list(NODE_LAST_VISITED = -1), identifier)
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

///Set the goal node
/datum/ai_behavior/proc/set_goal_node(datum/source, identifier, obj/effect/ai_node/new_goal_node)
	SIGNAL_HANDLER
	if(src.identifier != identifier)
		return
	goal_node = new_goal_node
	goal_nodes = null
	RegisterSignal(goal_node, COMSIG_PARENT_QDELETING, .proc/clean_goal_node)

///Set the escorted atom
/datum/ai_behavior/proc/set_escorted_atom(datum/source, atom/atom_to_escort)
	SIGNAL_HANDLER
	if(atom_to_escort.get_xeno_hivenumber() != mob_parent.get_xeno_hivenumber())
		return
	if(get_dist(atom_to_escort, mob_parent) > target_distance)
		return
	INVOKE_ASYNC(mob_parent, /mob/living.proc/emote, "roar")
	escorted_atom = atom_to_escort
	change_action(ESCORTING_ATOM, escorted_atom)
	UnregisterSignal(SSdcs, COMSIG_GLOB_AI_MINION_RALLY)

///clean the escorted atom var to avoid harddels
/datum/ai_behavior/proc/clean_escorted_atom()
	SIGNAL_HANDLER
	escorted_atom = null
	RegisterSignal(SSdcs, COMSIG_GLOB_AI_MINION_RALLY, .proc/set_escorted_atom)
	if(current_action == ESCORTING_ATOM)
		look_for_next_node()

///Clean the goal node
/datum/ai_behavior/proc/clean_goal_node()
	SIGNAL_HANDLER
	goal_node = null
	goal_nodes = null
	if(current_action == MOVING_TO_NODE)
		look_for_next_node()

/*
Registering and unregistering signals related to a particular current_action
These are parameter based so the ai behavior can choose to (un)register the signals it wants to rather than based off of current_action
*/
/datum/ai_behavior/proc/register_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_NODE)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/finished_node_move)
			anti_stuck_timer = addtimer(CALLBACK(src, .proc/look_for_next_node, TRUE, TRUE), 8 SECONDS, TIMER_STOPPABLE)

/datum/ai_behavior/proc/unregister_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_NODE)
			UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
			deltimer(anti_stuck_timer)
