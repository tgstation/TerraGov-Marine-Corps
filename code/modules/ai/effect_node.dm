//The node with a physical presence on the map; mainly exists as a actual object to be able to be highlighted easily for easy debugging and viewing purposes
//It also holds the datum ai_node, containing getter procs and handle info like weights

/obj/effect/ai_node //A effect that has a ai_node datum in it, used by AIs to pathfind over long distances as well as knowing what's happening at it
	name = "AI Node"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x6" //Pure white 'X' with black borders
	anchored = TRUE //No pulling those nodes yo
	invisibility = INVISIBILITY_OBSERVER //Visible towards ghosts
	///list of adjacent landmark nodes
	var/list/adjacent_nodes

	///List of weights for scoring stuff happening here; ultilizes "identifiers" to differentiate different kinds of AI types looking at the same node.
	var/list/weights = list(
		IDENTIFIER_XENO = list(NODE_LAST_VISITED = 0),
		)

/obj/effect/ai_node/Initialize()
	. = ..()
	GLOB.allnodes += src

/obj/effect/ai_node/LateInitialize()
	make_adjacents()

///Adds to the specific weight of a specific identifier of this node
/obj/effect/ai_node/proc/increment_weight(identifier, name, amount)
	weights[identifier][name] += amount

///Sets the specific weight of a specific identifier of this node
/obj/effect/ai_node/proc/set_weight(identifier, name, amount)
	weights[identifier][name] = amount

/obj/effect/ai_node/Destroy()
	GLOB.allnodes -= src
	//Remove our reference to self from nearby adjacent node's adjacent nodes
	for(var/nodes in adjacent_nodes)
		var/obj/effect/ai_node/node = nodes
		node.adjacent_nodes -= src
	return ..()

///Returns a node that is in the direction of this node; must be in the src's adjacent node list
/obj/effect/ai_node/proc/get_node_in_dir_in_adj(dir)
	if(!length(adjacent_nodes))
		return

	for(var/i in adjacent_nodes)
		var/obj/effect/ai_node/node = i
		if(get_dir(src, node) != dir)
			continue
		return node

/**
 * A proc that gets the "best" adjacent node in src based on score
 * The score is calculated by what weights are inside of the list/weight_modifiers
 * The highest number after multiplying each list/weight by the ones in the above parameter will be the node that's chosen; any nodes that have the same score won't override that node
 * Generally the number that the weight has before being multiplied by weight modifiers is the "user friendly" edition; NODE_LAST_VISITED represents in deciseconds the time before
 * the node has been visited by a particular thing, while something like NODE_ENEMY_COUNT represents the amount of enemies
 * Parameter call example
 * GetBestAdjNode(list(NODE_LAST_VISITED = -1), IDENTIFIER_XENO)
 * Returns an adjacent node that was last visited; when a AI visits a node, it will set NODE_LAST_VISITED to world.time
 */
/obj/effect/ai_node/proc/get_best_adj_node(list/weight_modifiers, identifier)
	//No weight modifiers, return a adjacent random node
	if(!length(weight_modifiers) || !identifier)
		return pick(adjacent_nodes)

	var/obj/effect/ai_node/node_to_return
	var/current_best_node_score = -INFINITY
	var/current_score
	for(var/thing in shuffle_inplace(adjacent_nodes)) //We keep a score for the nodes and see which one is best
		var/obj/effect/ai_node/node = thing
		current_score = 0
		for(var/weight in weight_modifiers)
			current_score += NODE_GET_VALUE_OF_WEIGHT(identifier, node, weight) * weight_modifiers[weight]

		if(current_score >= current_best_node_score)
			current_best_node_score = current_score
			node_to_return = node

	if(node_to_return)
		return node_to_return
	else //Just in case no applicable scores are located
		return pick(adjacent_nodes)

///Clears the adjacencies of src and repopulates it, it will consider nodes "adjacent" to src should it be less 15 turfs away and get_dir(src, potential_adjacent_node) returns a cardinal direction
/obj/effect/ai_node/proc/make_adjacents()
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
		message_admins("[ADMIN_VERBOSEJMP(loc)] was unable to connect to any considered-adjacent nodes; place them correctly if you were spawning these in, otherwise report this.")
		CRASH("An ai node was repopulating it's node adjacencies but there were no considered-adjacent nodes nearby; this can be because of a mapping/admin spawning issue. Location: AREACOORD(src)")

/obj/effect/ai_node/debug //A debug version of the AINode; makes it visible to allow for easy var editing
	icon_state = "x6" //Pure white 'X' with black borders
	color = "#ffffff"
	invisibility = 0
