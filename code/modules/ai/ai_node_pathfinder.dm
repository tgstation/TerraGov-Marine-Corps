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
		for(var/direction in current_node.adjacent_nodes)
			var/obj/effect/ai_node/node_to_check = current_node.adjacent_nodes[direction]
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
	///The identifier of this ai goal
	var/identifier = IDENTIFIER_XENO
	///Who made that ai_node
	var/mob/creator
	///The image added to the creator screen
	var/image/goal_image

/obj/effect/ai_node/goal/Initialize(loc, mob/creator)
	. = ..()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_AI_GOAL_SET, identifier, src)
	RegisterSignal(SSdcs, COMSIG_GLOB_AI_GOAL_SET, .proc/clean_goal_node)
	GLOB.goal_nodes[identifier] = src
	if(creator)
		src.creator = creator
		RegisterSignal(creator, COMSIG_PARENT_QDELETING, .proc/clean_creator)
		goal_image = image('icons/mob/actions.dmi', src, "minion_rendez_vous")
		goal_image.layer = HUD_PLANE
		goal_image.alpha = 180
		goal_image.pixel_y += 10
		animate(goal_image, pixel_y = pixel_y - 3, time = 7, loop = -1, easing = EASE_OUT)
		animate(pixel_y = pixel_y + 3, time = 7, loop = -1, easing = EASE_OUT)
		creator.client.images += goal_image

/obj/effect/ai_node/goal/LateInitialize()
	make_adjacents(TRUE)

/obj/effect/ai_node/goal/Destroy()
	. = ..()
	GLOB.goal_nodes -= identifier
	if(creator)
		creator.client.images -= goal_image

///Null creator to prevent harddel
/obj/effect/ai_node/goal/proc/clean_creator()
	SIGNAL_HANDLER
	creator.client.images -= goal_image
	creator = null

///Delete this ai_node goal
/obj/effect/ai_node/goal/proc/clean_goal_node()
	SIGNAL_HANDLER
	qdel(src)

/obj/effect/ai_node/goal/husk
	name = "Ai husk goal"
	identifier = IDENTIFIER_HUSK
