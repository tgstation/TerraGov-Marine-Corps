//The node with a physical presence on the map; mainly exists as a actual object to be able to be highlighted easily for easy debugging and viewing purposes
//It also holds the datum ai_node, containing getter procs and handle info like weights

/obj/effect/ai_node //A effect that has a ai_node datum in it, used by AIs to pathfind over long distances as well as knowing what's happening at it
	name = "AI Node"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x6" //Pure white 'X' with black borders
	anchored = TRUE //No pulling those nodes yo
	invisibility = INVISIBILITY_OBSERVER //Not visible at all
	var/list/adjacent_nodes = list() // list of adjacent landmark nodes
	var/list/weights = list(ENEMY_PRESENCE = 0, DANGER_SCALE = 0) //List of weights for the overall things happening at this node

/obj/effect/ai_node/LateInitialize()
	MakeAdjacents()

/obj/effect/ai_node/proc/increment_weight(name, amount)
	weights[name] = max(0, weights[name] + amount)

/obj/effect/ai_node/proc/set_weight(name, amount)
	weights[name] = amount

/obj/effect/ai_node/Initialize() //Add ourselve to the global list of nodes
	. = ..()
	GLOB.allnodes += src

/obj/effect/ai_node/Destroy()
	GLOB.allnodes -= src
	//Remove our reference to self from nearby adjacent node's adjacent nodes
	for(var/nodes in adjacent_nodes)
		var/obj/effect/ai_node/node = nodes
		node.adjacent_nodes -= src
	. = ..()

//Returns a node that is in the direction of this node; must be in the src's adjacent node list
/obj/effect/ai_node/proc/GetNodeInDirInAdj(dir)

	if(!length(adjacent_nodes))
		return

	for(var/i in adjacent_nodes)
		var/obj/effect/ai_node/node = i
		if(get_dir(src, node) != dir)
			continue
		return node

/*
Current weights are nothing, wait for more ai updates
Parameter call example
GetBestAdjNode(list(ENEMY_PRESENCE = -100, DANGER_SCALE = -1)) if these were defined
This means that the proc will pick out the *best* node
*/

/obj/effect/ai_node/proc/GetBestAdjNode(list/weight_modifiers)
	//No weight modifier, return a adjacent random node
	if(!weight_modifiers)
		return pick(adjacent_nodes)

	var/obj/effect/ai_node/node_to_return = adjacent_nodes[1]
	var/current_best_node = 0
	for(var/n in shuffle(adjacent_nodes)) //We keep a score for the nodes and see which one is best
		var/obj/effect/ai_node/node = n
		var/current_score = 0
		for(var/i in 1 to length(weight_modifiers))
			current_score += GET_WEIGHT(src, i)

		if(current_score >= current_best_node)
			current_best_node = current_score
			node_to_return = node
		current_score = 0

	if(node_to_return)
		return node_to_return

/obj/effect/ai_node/proc/MakeAdjacents()
	adjacent_nodes = list()
	for(var/atom/node in GLOB.allnodes)
		if(node == src)
			continue
		if(!(get_dist(src, node) < 16))
			continue
		if(ISDIAGONALDIR(get_dir(src, node)))
			continue
		adjacent_nodes += node

	//If there's no adjacent nodes then let's throw a runtime (for mappers) and at admins (if they by any chance were spawning these in)
	if(!length(adjacent_nodes))
		message_admins("[ADMIN_VERBOSEJMP(src.loc)] was unable to connect to any considered-adjacent nodes; place them correctly if you were spawning these in otherwise report this.")
		stack_trace("An ai node was initialized but no considered-adjacent nodes were nearby; this can be because of a mapping/admin spawning issue.")

/obj/effect/ai_node/debug //A debug version of the AINode; makes it visible to allow for easy var editing
	icon_state = "x6" //Pure white 'X' with black borders
	color = "#ffffff"
	invisibility = 0 //Visible for easy var editing and noticing
