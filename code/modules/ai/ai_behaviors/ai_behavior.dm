/*
AI BEHAVIOR

The actual thinking brain that determines what it wants the mob to do
Registers signals, handles the pathfinding element addition/removal alongside making the mob do actions
*/

/datum/ai_behavior
	///What atom is the ai moving to
	var/atom/atom_to_walk_to
	///What we will escort
	var/atom/escorted_atom
	///The atom we want to attack at range, separate as we might not be moving in regards to it
	var/atom/combat_target
	///An atom we want to interact with, such as picking it up
	var/atom/interact_target
	///How far should we stay away from atom_to_walk_to. Outer range
	var/upper_maintain_dist = 1
	///How far should we stay away from atom_to_walk_to. Inner range
	var/lower_maintain_dist = 1
	///Range to stay from a hostile target. Outer range
	var/upper_engage_dist = 1
	///Range to stay from a hostile target. Inner range
	var/lower_engage_dist = 1
	///Prob chance of sidestepping (left or right) when distance maintained with target
	var/sidestep_prob = 0
	///Current node to use for calculating action states: this is the mob's node
	var/obj/effect/ai_node/current_node
	///The node goal of this ai
	var/obj/effect/ai_node/goal_node
	///A list of nodes the ai should go to in order to go to goal_node
	var/list/obj/effect/ai_node/goal_nodes
	///A list of turfs the ai should go in order to get to atom_to_walk_to
	var/list/turf/turfs_in_path
	///What the ai is doing right now
	var/current_action
	///The standard ation of the AI, aka what it should do at the init or when going back to "normal" behavior
	var/base_action = MOVING_TO_NODE
	///Ref to the parent associated with this mind
	var/mob/mob_parent //todo: why god is this mob level
	///An identifier associated with this behavior, used for accessing specific values of a node's weights
	var/identifier
	///How far will we look for targets
	var/target_distance = 8
	///When this timer is up, we force a change of node to ensure that the ai will never stay stuck trying to go to a specific node
	var/anti_stuck_timer
	///Minimum health percentage before the ai tries to run away
	var/minimum_health = 0.4
	///If the mob attached to the ai is offered on xeno creation
	var/is_offered_on_creation = FALSE
	///Are we waiting for advanced pathfinding
	var/registered_for_node_pathfinding = FALSE
	///Are we already registered for normal pathfinding
	var/registered_for_move = FALSE
	///Should we lose the escorted atom if we change action
	var/weak_escort = FALSE

/datum/ai_behavior/New(loc, mob/parent_to_assign, atom/escorted_atom)
	..()
	if(isnull(parent_to_assign))
		stack_trace("An ai behavior was initialized without a parent to assign it to; destroying mind. Mind type: [type]")
		qdel(src)
		return
	mob_parent = parent_to_assign
	set_escorted_atom(null, escorted_atom)
	//We always use the escorted atom as our reference point for looking for target. So if we don't have any escorted atom, we take ourselve as the reference
	if(is_offered_on_creation)
		LAZYOR(GLOB.ssd_living_mobs, mob_parent)

/datum/ai_behavior/Destroy(force, ...)
	current_node = null
	escorted_atom = null
	mob_parent = null
	atom_to_walk_to = null
	combat_target = null
	interact_target = null
	return ..()

///Register ai behaviours
/datum/ai_behavior/proc/start_ai()
	START_PROCESSING(SSprocessing, src)
	RegisterSignal(SSdcs, COMSIG_GLOB_AI_GOAL_SET, PROC_REF(set_goal_node))

	late_initialize()
	START_PROCESSING(SSprocessing, src)

///Set behaviour to base behavior
/datum/ai_behavior/proc/late_initialize()
	switch(base_action)
		if(MOVING_TO_NODE)
			look_for_next_node()
		if(ESCORTING_ATOM)
			change_action(ESCORTING_ATOM, escorted_atom)
		if(IDLE)
			change_action(IDLE)
	if(!registered_for_move)
		scheduled_move()

///We finished moving to a node, let's pick a random nearby one to travel to
/datum/ai_behavior/proc/finished_node_move()
	SIGNAL_HANDLER
	look_for_next_node(FALSE)
	return COMSIG_MAINTAIN_POSITION

///Cleans up signals related to the action and element(s)
/datum/ai_behavior/proc/cleanup_current_action(next_action)
	if(current_action == MOVING_TO_NODE && next_action != MOVING_TO_NODE)
		set_current_node(null)
	unregister_action_signals(current_action)

///Clean every signal on the ai_behavior
/datum/ai_behavior/proc/cleanup_signals()
	cleanup_current_action()
	UnregisterSignal(SSdcs, COMSIG_GLOB_AI_MINION_RALLY)
	UnregisterSignal(SSdcs, COMSIG_GLOB_AI_GOAL_SET)

///Cleanup old state vars, start the movement towards our new target
/datum/ai_behavior/proc/change_action(next_action, atom/next_target, list/special_distance_to_maintain)
	if(QDELETED(mob_parent))
		return
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
		if(FOLLOWING_PATH)
			message_admins("[mob_parent] moves toward [next_target] as part of its path")
		if(IDLE)
			message_admins("[mob_parent] is idle")
	#endif
	if(next_action)
		current_action = next_action
	if(current_action == FOLLOWING_PATH)
		upper_maintain_dist = 0
		lower_maintain_dist = 0
	else if(current_action == ESCORTING_ATOM)
		upper_maintain_dist = 3 //Don't stay too close //todo: can make this a var to be adjustable
		lower_maintain_dist = 1
	else if(islist(special_distance_to_maintain))
		upper_maintain_dist = max(special_distance_to_maintain)
		lower_maintain_dist = min(special_distance_to_maintain)
	else
		upper_maintain_dist = initial(upper_maintain_dist)
		lower_maintain_dist = initial(lower_maintain_dist)
	if(next_target)
		set_atom_to_walk_to(next_target)

	register_action_signals(current_action)
	if(current_action == MOVING_TO_SAFETY)
		mob_parent.a_intent = INTENT_HELP
	else
		mob_parent.a_intent = INTENT_HARM
	return TRUE

///Try to find a node to go to. If ignore_current_node is true, we will just find the closest current_node, and not the current_node best adjacent node
/datum/ai_behavior/proc/look_for_next_node(ignore_current_node = TRUE, should_reset_goal_nodes = FALSE)
	if(should_reset_goal_nodes)
		set_current_node(null)
	if(ignore_current_node || QDELETED(current_node)) //We don't have a current node, let's find the closest in our LOS
		var/new_node = find_closest_node(mob_parent, current_node)
		if(!new_node)
			return
		set_current_node(new_node)
		change_action(MOVING_TO_NODE, new_node)
		return
	if(escorted_atom && (escorted_atom != goal_node)) //goal_node can be our escort target, but otherwise escort targets override goal_node
		var/target_node = find_closest_node(escorted_atom)
		if(target_node)
			set_goal_node(new_goal_node = target_node)
	if(goal_node && goal_node != current_node)
		if(!length(goal_nodes))
			if(!registered_for_node_pathfinding)
				SSadvanced_pathfinding.node_pathfinding_to_do += src
				registered_for_node_pathfinding = TRUE
			return
		set_current_node(GLOB.all_nodes[goal_nodes[length(goal_nodes)] + 1])
		goal_nodes.len--
	else
		set_current_node(current_node.get_best_adj_node(list(NODE_LAST_VISITED = -1), identifier))
	if(!current_node)
		addtimer(CALLBACK(src, PROC_REF(look_for_next_node)), 1 SECONDS)// Shouldn't happen unless you spam goal nodes
		return
	current_node.set_weight(identifier, NODE_LAST_VISITED, world.time)
	change_action(MOVING_TO_NODE, current_node)

///Finds the closest node to an atom
/datum/ai_behavior/proc/find_closest_node(atom/target, avoid_node)
	var/closest_distance = MAX_NODE_RANGE //squared because we are using the cheap get dist
	var/current_closest
	for(var/obj/effect/ai_node/ai_node AS in GLOB.all_nodes)
		if(!ai_node)
			continue
		if(ai_node == avoid_node)
			continue
		if(ai_node.z != target.z || get_dist(ai_node, target) >= closest_distance)
			continue
		current_closest = ai_node
		closest_distance = get_dist(ai_node, target)
	return current_closest

///Set the current node to next_node
/datum/ai_behavior/proc/set_current_node(obj/effect/ai_node/next_node)
	if(current_node)
		UnregisterSignal(current_node, COMSIG_QDELETING)
	if(next_node)
		RegisterSignal(current_node, COMSIG_QDELETING, PROC_REF(unset_target), TRUE)
	current_node = next_node

///Signal handler when the ai is blocked by an obstacle
/datum/ai_behavior/proc/deal_with_obstacle(datum/source, direction)
	SIGNAL_HANDLER

///Register on advanced pathfinding subsytem to get a tile pathfinding
/datum/ai_behavior/proc/ask_for_pathfinding()
	SSadvanced_pathfinding.tile_pathfinding_to_do += src

///Look for the a* tile path to get to atom_to_walk_to
/datum/ai_behavior/proc/look_for_tile_path()
	if(QDELETED(current_node))
		return
	turfs_in_path = get_path(get_turf(mob_parent), get_turf(current_node), TILE_PATHING)
	if(!length(turfs_in_path))
		cleanup_current_action()
		late_initialize()
		return
	change_action(FOLLOWING_PATH, turfs_in_path[length(turfs_in_path)])
	turfs_in_path.len--

///Look for the a* node path to get to goal_node
/datum/ai_behavior/proc/look_for_node_path()
	if(QDELETED(goal_node) || QDELETED(current_node))
		return
	var/goal_nodes_serialized = rustg_generate_path_astar("[current_node.unique_id]", "[goal_node.unique_id]")
	if(rustg_json_is_valid(goal_nodes_serialized))
		goal_nodes = json_decode(goal_nodes_serialized)
	else
		goal_nodes = list()
		set_current_node(null)
	look_for_next_node()

///Signal handler when we reached our current tile goal
/datum/ai_behavior/proc/finished_path_move()
	SIGNAL_HANDLER
	if(!length(turfs_in_path))//We supposedly found our goal
		cleanup_current_action()
		late_initialize()
		return
	set_atom_to_walk_to(turfs_in_path[length(turfs_in_path)])
	turfs_in_path.len--
	return COMSIG_MAINTAIN_POSITION

//Generic process(), this is used for mainly looking at the world around the AI and determining if a new action must be considered and executed
/datum/ai_behavior/process()
	if(!escorted_atom || (get_dist(mob_parent, escorted_atom) > AI_ESCORTING_BREAK_DISTANCE) || mob_parent.z != escorted_atom.z)
		set_escort()
	var/atom/next_target = get_nearest_target(mob_parent, target_distance, TARGET_HOSTILE, mob_parent.faction, mob_parent.get_xeno_hivenumber(), TRUE)
	look_for_new_state(next_target)
	state_process(next_target)
	return

///Check if we need to adopt a new state
/datum/ai_behavior/proc/look_for_new_state()
	SIGNAL_HANDLER
	return

///Any state specific process behavior
/datum/ai_behavior/proc/state_process()
	return

///Set the goal node
/datum/ai_behavior/proc/set_goal_node(datum/source, obj/effect/ai_node/new_goal_node)
	SIGNAL_HANDLER
	if(!new_goal_node)
		return
	if(new_goal_node.faction != mob_parent.faction)
		return
	if(goal_node)
		do_unset_target(goal_node)
	goal_node = new_goal_node
	RegisterSignal(goal_node, COMSIG_QDELETING, PROC_REF(unset_target), TRUE)
	return TRUE

/*
Registering and unregistering signals related to a particular current_action
These are parameter based so the ai behavior can choose to (un)register the signals it wants to rather than based off of current_action
*/
/datum/ai_behavior/proc/register_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_NODE)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, PROC_REF(finished_node_move))
			if(SStime_track.time_dilation_avg > CONFIG_GET(number/ai_anti_stuck_lag_time_dilation_threshold))
				anti_stuck_timer = addtimer(CALLBACK(src, PROC_REF(look_for_next_node), TRUE, TRUE), 10 SECONDS, TIMER_STOPPABLE)
				return
			anti_stuck_timer = addtimer(CALLBACK(src, PROC_REF(ask_for_pathfinding), TRUE, TRUE), 10 SECONDS, TIMER_STOPPABLE)
		if(FOLLOWING_PATH)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, PROC_REF(finished_path_move))
			anti_stuck_timer = addtimer(CALLBACK(src, PROC_REF(look_for_next_node), TRUE, TRUE), 10 SECONDS, TIMER_STOPPABLE)

///Cleans up sigs for the current action
/datum/ai_behavior/proc/unregister_action_signals(action_type)
	UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
	deltimer(anti_stuck_timer)

/// Move the ai and schedule the next move
/datum/ai_behavior/proc/scheduled_move()
	if(QDELETED(mob_parent))
		return
	if(!atom_to_walk_to)
		registered_for_move = FALSE
		return
	ai_do_move()
	var/next_move = mob_parent.cached_multiplicative_slowdown + mob_parent.next_move_slowdown
	if(next_move <= 0)
		next_move = 1
	addtimer(CALLBACK(src, PROC_REF(scheduled_move)), next_move, NONE, SSpathfinder)
	registered_for_move = TRUE

///Returns true if the mob should not move for some reason
/datum/ai_behavior/proc/should_hold()
	if(mob_parent?.do_actions) //todo: shift xenos over to logic used by humans
		return TRUE
	return FALSE

///Tries to move the ai toward its atom_to_walk_to
/datum/ai_behavior/proc/ai_do_move()
	if(!mob_parent?.canmove)
		return
	if(should_hold())
		return
	//This allows minions to be buckled to their atom_to_escort without disrupting the movement of atom_to_escort
	if(current_action == ESCORTING_ATOM && (get_dist(mob_parent, atom_to_walk_to) <= 0)) //todo: Entirely remove this shitcode snowflake check for one specific interaction that doesn't specifically relate to ai_behavior
		return
	mob_parent.next_move_slowdown = 0
	var/list/dir_options = find_next_dirs()
	if(!length(dir_options))
		return
	ai_complete_move(pick(dir_options))

///Find our movement options
/datum/ai_behavior/proc/find_next_dirs()
	var/dist_to_target = get_dist(mob_parent, atom_to_walk_to)

	var/max_range = upper_maintain_dist
	var/min_range = lower_maintain_dist
	if(current_action == MOVING_TO_ATOM && (atom_to_walk_to == combat_target))
		max_range = upper_engage_dist
		min_range = lower_engage_dist
	var/list/dir_options = list()

	if((dist_to_target >= min_range) && (dist_to_target <= max_range)) //in optimal range
		if((SEND_SIGNAL(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE) & COMSIG_MAINTAIN_POSITION))
			return
		if(!get_dir(mob_parent, atom_to_walk_to)) //We're right on top, move out of it
			return CARDINAL_ALL_DIRS
		if(prob(50)) //placeholder number, will probs be a var like sidestep prob, so they're not just constantly wiggling about
			return
		if(prob(sidestep_prob)) //shuffle about
			dir_options += LeftAndRightOfDir(get_dir(mob_parent, atom_to_walk_to))
	if(dist_to_target > min_range) //above min range, its valid to come closer
		dir_options += get_dir(mob_parent, atom_to_walk_to)
	if(dist_to_target < max_range) //less than max range, its valid to walk away
		dir_options += get_dir(atom_to_walk_to, mob_parent)

	return dir_options

///Makes a move in a given direction
/datum/ai_behavior/proc/ai_complete_move(move_dir, try_sidestep = TRUE)
	var/turf/new_loc = get_step(mob_parent, move_dir)
	if(new_loc?.atom_flags & AI_BLOCKED)
		move_dir = pick(LeftAndRightOfDir(move_dir))
		new_loc = get_step(mob_parent, move_dir)
		if(new_loc?.atom_flags & AI_BLOCKED)
			return
	if(!mob_parent.Move(new_loc, move_dir))
		if(!(SEND_SIGNAL(mob_parent, COMSIG_OBSTRUCTED_MOVE, move_dir) & COMSIG_OBSTACLE_DEALT_WITH) && try_sidestep)
			ai_complete_move(pick(LeftAndRightOfDir(move_dir)), FALSE)
		return
	if(ISDIAGONALDIR(move_dir))
		mob_parent.next_move_slowdown += (DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER - 1) * mob_parent.cached_multiplicative_slowdown
	mob_parent.set_glide_size(DELAY_TO_GLIDE_SIZE(mob_parent.cached_multiplicative_slowdown + mob_parent.next_move_slowdown * ( ISDIAGONALDIR(move_dir) ? DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER : 1 ) )) //todo: probs dont even need this

///Finds and sets the most suitable escort candidate, if possible
/datum/ai_behavior/proc/set_escort()
	var/new_escort = get_atom_to_escort()
	if(!new_escort)
		return FALSE
	set_escorted_atom(null, new_escort)
	return TRUE

///Finds the most suitable thing to escort
/datum/ai_behavior/proc/get_atom_to_escort()
	var/list/goal_list = list()
	if(GLOB.goal_nodes[mob_parent.faction])
		goal_list[GLOB.goal_nodes[mob_parent.faction]] = AI_ESCORT_RATING_FACTION_GOAL
	var/mob/living/escorted_mob = escorted_atom
	if(ismob(escorted_mob) && !QDELETED(escorted_mob) && (escorted_mob.stat != DEAD) && (escorted_mob.z == mob_parent.z) && (get_dist(mob_parent, escorted_mob) <= (AI_ESCORTING_BREAK_DISTANCE)))
		goal_list[escorted_atom] = AI_ESCORT_RATING_BUDDY
	else
		var/atom/mob_to_follow = get_nearest_target(mob_parent, AI_ESCORTING_MAX_DISTANCE, TARGET_FRIENDLY_MOB, mob_parent.faction, need_los = TRUE)
		if(mob_to_follow)
			goal_list[mob_to_follow] = AI_ESCORT_RATING_CLOSE_FRIENDLY

	SEND_SIGNAL(mob_parent, COMSIG_NPC_FIND_NEW_ESCORT, goal_list)
	goal_list = sortTim(goal_list, /proc/cmp_numeric_dsc, TRUE)
	if(!length(goal_list))
		return
	for(var/atom/candidate AS in goal_list)
		if(QDELETED(candidate))
			continue
		if(candidate.z != mob_parent.z)
			continue
		return candidate

///Set the escorted atom.
/datum/ai_behavior/proc/set_escorted_atom(datum/source, atom/atom_to_escort, new_escort_is_weak)
	SIGNAL_HANDLER
	if(escorted_atom == atom_to_escort)
		return
	if(escorted_atom)
		do_unset_target(escorted_atom, FALSE, FALSE)
	escorted_atom = atom_to_escort
	weak_escort = new_escort_is_weak
	if(!weak_escort)
		base_action = ESCORTING_ATOM
	RegisterSignals(escorted_atom, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_OBJ_DECONSTRUCT, COMSIG_MOVABLE_Z_CHANGED), PROC_REF(unset_target), TRUE)
	RegisterSignal(escorted_atom, COMSIG_ESCORTING_ATOM_BEHAVIOUR_CHANGED, PROC_REF(set_agressivity))
	change_action(ESCORTING_ATOM, escorted_atom)
	return TRUE

///Change atom to walk to if the order comes from a corresponding commander
/datum/ai_behavior/proc/global_set_escorted_atom(datum/source, atom/atom_to_escort)
	SIGNAL_HANDLER
	if(QDELETED(atom_to_escort))
		return
	if(get_dist(atom_to_escort, mob_parent) > target_distance)
		return
	set_escorted_atom(source, atom_to_escort)

///clean the escorted atom var to avoid harddels
/datum/ai_behavior/proc/clean_escorted_atom()
	if(!escorted_atom)
		return
	UnregisterSignal(escorted_atom, list(COMSIG_ESCORTING_ATOM_BEHAVIOUR_CHANGED))
	escorted_atom = null
	base_action = initial(base_action)

///Set the target distance to be normal (initial) or very low (almost passive)
/datum/ai_behavior/proc/set_agressivity(datum/source, should_be_agressive = TRUE)
	SIGNAL_HANDLER
	target_distance = should_be_agressive ? initial(target_distance) : 2

///Sets our direct movement target
/datum/ai_behavior/proc/set_atom_to_walk_to(atom/new_target)
	if(atom_to_walk_to == new_target)
		return
	if(atom_to_walk_to)
		do_unset_target(atom_to_walk_to, FALSE)
	atom_to_walk_to = new_target
	RegisterSignals(atom_to_walk_to, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_OBJ_DECONSTRUCT, COMSIG_MOVABLE_Z_CHANGED), PROC_REF(unset_target), TRUE)
	if(!registered_for_move)
		INVOKE_ASYNC(src, PROC_REF(scheduled_move))
	return TRUE

///Sets our active combat target
/datum/ai_behavior/proc/set_combat_target(atom/new_target)
	if(combat_target == new_target)
		return
	if(combat_target)
		do_unset_target(combat_target, FALSE)
	combat_target = new_target
	RegisterSignals(combat_target, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_OBJ_DECONSTRUCT, COMSIG_MOVABLE_Z_CHANGED), PROC_REF(unset_target), TRUE)
	return TRUE

///Sets an interaction target
/datum/ai_behavior/proc/set_interact_target(atom/new_target)
	if(interact_target == new_target)
		return
	if(interact_target)
		do_unset_target(interact_target, FALSE)
	interact_target = new_target
	RegisterSignals(interact_target, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_OBJ_DECONSTRUCT, COMSIG_MOVABLE_Z_CHANGED), PROC_REF(unset_target), TRUE)
	change_action(MOVING_TO_ATOM, interact_target, list(0, 1))
	return TRUE

///Sig handler for unsetting a target
/datum/ai_behavior/proc/unset_target(atom/source)
	SIGNAL_HANDLER
	do_unset_target(source)

///Unsets a target from any target vars its in
/datum/ai_behavior/proc/do_unset_target(atom/old_target, need_new_state = TRUE, need_new_escort = TRUE)
	UnregisterSignal(old_target, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_OBJ_DECONSTRUCT, COMSIG_MOVABLE_MOVED, COMSIG_MOB_STAT_CHANGED, COMSIG_MOVABLE_Z_CHANGED))
	if(goal_node == old_target)
		goal_node = null
		goal_nodes = null
		if(current_action == MOVING_TO_NODE && need_new_state)
			look_for_next_node(should_reset_goal_nodes = TRUE)
	if(current_node == old_target)
		look_for_next_node()
	if(escorted_atom == old_target)
		if(!need_new_escort || !set_escort())
			clean_escorted_atom()
	if(combat_target == old_target)
		combat_target = null
	if(interact_target == old_target)
		interact_target = null
	if(atom_to_walk_to == old_target)
		atom_to_walk_to = null
		if(current_action == MOVING_TO_ATOM && need_new_state)
			look_for_new_state()

