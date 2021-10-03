GLOBAL_LIST_EMPTY(goal_nodes)

/datum/node_path
	var/distance_to_goal
	var/distance_walked
	var/obj/effect/ai_node/current_node
	var/obj/effect/ai_node/previous_node

/datum/node_path/New(obj/effect/ai_node/previous_node, var/obj/effect/ai_node/current_node, obj/effect/ai_node/goal_node, old_distance_walked)
	. = ..()
	distance_to_goal = get_dist_euclide_square(current_node, goal_node)
	distance_walked = old_distance_walked + get_dist_euclide_square(current_node, previous_node)
	src.current_node = current_node
	src.previous_node = previous_node

/proc/get_node_path(obj/effect/ai_node/starting_node, obj/effect/ai_node/goal_node)
	if(starting_node.z != goal_node.z)
		CRASH("Start node and goal node were not on the same z level")
	if(starting_node == goal_node)
		CRASH("Start node and goal node were identical")
	var/list/datum/node_path/paths_to_check = list()
	var/obj/effect/ai_node/current_node = starting_node
	var/list/datum/node_path/paths_checked = list()
	var/datum/node_path/current_path
	while(current_node != goal_node)
		for(var/obj/effect/ai_node/node_to_check AS in current_node.adjacent_nodes)
			if(paths_to_check[node_to_check] || paths_checked[node_to_check]) //We already found a better path to get to this node
				continue
			paths_to_check[node_to_check] = new/datum/node_path(current_node, node_to_check, goal_node, current_path?.distance_walked)
		paths_checked[current_node] = current_path
		paths_to_check -= current_node
		sortTim(paths_to_check, /proc/cmp_node_path, TRUE) //We keep the list sorted, very cheap cause almost sorted
		current_path = paths_to_check[paths_to_check[1]]
		current_node = current_path.current_node
	paths_checked[current_node] = current_path
	var/list/obj/effect/ai_node/nodes_path = list()
	//We can go back our track, making the path along the way
	while(current_node != starting_node)
		nodes_path += current_node
		current_node = paths_checked[current_node].previous_node
	return nodes_path

/obj/effect/ai_node/goal
	name = "AI goal"
	invisibility = INVISIBILITY_OBSERVER
	color = "#1c0bb3"
	///The identifier of this ai goal
	var/identifier = IDENTIFIER_XENO

/obj/effect/ai_node/goal/Initialize()
	. = ..()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_AI_GOAL_SET, identifier, src)
	RegisterSignal(SSdcs, COMSIG_GLOB_AI_GOAL_SET, .proc/clean_goal_node)
	GLOB.goal_nodes[identifier] = src

/obj/effect/ai_node/goal/Destroy()
	. = ..()
	GLOB.goal_nodes -= identifier

///Delete this ai_node goal
/obj/effect/ai_node/goal/proc/clean_goal_node()
	SIGNAL_HANDLER
	qdel(src)

/obj/effect/ai_node/goal/husk
	name = "Ai husk goal"
	identifier = IDENTIFIER_HUSK
