GLOBAL_LIST_EMPTY(goal_nodes)

///Basic implementation of A* using nodes. Very cheap, at max it will do about 50-100 distance check for a whole path, but typically it will do 10-20


/datum/node_path
	///Euclidian distance to the goal node
	var/distance_to_goal
	///Sum of euclidian distances to get from the starting node to this node, if you follow the current optimal path
	var/distance_walked
	///What node this node path reached
	var/obj/effect/ai_node/current_node
	///What node was right before current node in the node path
	var/obj/effect/ai_node/previous_node

/datum/node_path/New(obj/effect/ai_node/previous_node, obj/effect/ai_node/current_node, obj/effect/ai_node/goal_node, old_distance_walked)
	..()
	distance_to_goal = get_dist_euclide_square(current_node, goal_node)
	distance_walked = old_distance_walked + get_dist_euclide_square(current_node, previous_node)
	src.current_node = current_node
	src.previous_node = previous_node

///Returns the most optimal nodes path to get from starting node to goal node
/proc/get_node_path(obj/effect/ai_node/starting_node, obj/effect/ai_node/goal_node)
	if(starting_node.z != goal_node.z)
		CRASH("Start node and goal node were not on the same z level")
	if(starting_node == goal_node)
		CRASH("Start node and goal node were identical")
	var/list/datum/node_path/paths_to_check = list()
	var/obj/effect/ai_node/current_node = starting_node
	var/list/datum/node_path/paths_checked = list()
	var/datum/node_path/current_path
	//Have we reached our goal node yet?
	while(current_node != goal_node)
		//Check all node, create node path for all of them
		for(var/obj/effect/ai_node/node_to_check AS in current_node.adjacent_nodes)
			if(paths_to_check[node_to_check] || paths_checked[node_to_check]) //We already found a better path to get to this node
				continue
			paths_to_check[node_to_check] = new/datum/node_path(current_node, node_to_check, goal_node, current_path?.distance_walked)
		paths_checked[current_node] = current_path
		paths_to_check -= current_node
		//We looked through all nodes, we didn't find a way to get to our end points
		if(!length(paths_to_check))
			CRASH("Node pathfinder was unable to find a path to goal node, the network of nodes is not fully connected")
		//We created a node path for each adjacent node, we sort every nodes by their heuristic score
		sortTim(paths_to_check, /proc/cmp_node_path, TRUE) //Very cheap cause almost sorted
		current_path = paths_to_check[paths_to_check[1]] //We take the node with the smaller heuristic score (distance to goal + distance already made)
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
