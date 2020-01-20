//The node with a physical presence on the map; mainly exists as a actual object to be able to be highlighted easily for easy debugging and viewing purposes
//It also holds the datum ai_node, containing getter procs and handle info like weights

/obj/effect/ai_node //A effect that has a ai_node datum in it, used by AIs to pathfind over long distances as well as knowing what's happening at it
	name = "AI Node"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "6x" //Pure white 'X' with black borders
	var/datum/ai_node/datumnode = new/datum/ai_node() //Stores things about the AI node
	anchored = TRUE //No pulling those nodes yo
	invisibility = INVISIBILITY_OBSERVER //Not visible at all

/obj/effect/ai_node/Initialize() //Add ourselve to the global list of nodes
	. = ..()
	datumnode.parentnode = src
	GLOB.allnodes += src

/obj/effect_ai_node/Destroy()
	GLOB.allnodes -= src
	. = ..()

//Current weights are nothing, wait for more ai updates
//Parameter call example
//GetBestAdjNode(list(ENEMY_PRESENCE = -100, DANGER_SCALE = -1)) if these were defined
//This means that the proc will pick out the *best* node

/obj/effect/ai_node/proc/GetBestAdjNode(list/weight_modifiers)
	//No weight modifier, return a adjacent random node
	if(!weight_modifiers)
		return pick(shuffle(datumnode.adjacent_nodes))

	var/obj/effect/ai_node/node_to_return = datumnode.adjacent_nodes[1]
	var/current_best_node = 0
	for(var/n in shuffle(datumnode.adjacent_nodes)) //We keep a score for the nodes and see which one is best
		var/obj/effect/ai_node/node = n
		var/current_score = 0
		for(var/i in 1 to length(weight_modifiers))
			current_score += (node.datumnode.get_weight(i) * weight_modifiers[i])

		if(current_score >= current_best_node)
			current_best_node = current_score
			node_to_return = node
		current_score = 0

	if(node_to_return)
		return node_to_return

/obj/effect/ai_node/proc/MakeAdjacents()
	datumnode.adjacent_nodes = list()
	for(var/obj/effect/ai_node/node in GLOB.allnodes)
		if(node == src)
			continue
		if(!get_dist(src, node) < 16)
			continue
		if(!ISDIAGONALDIR(get_dir(src, node)))
			continue
		datumnode.adjacent_nodes += node

/obj/effect/ai_node/debug //A debug version of the AINode; makes it visible to allow for easy var editing
	icon_state = "x6" //Pure white 'X' with black borders
	color = "#ffffff"
	invisibility = 0 //Visible for easy var editing and noticing
