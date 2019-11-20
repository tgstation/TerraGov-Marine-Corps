//The actual node; really only to hold the ai_node datum that stores all the information

/obj/effect/ai_node //A effect that has a ai_node datum in it, used by AIs to pathfind over long distances as well as knowing what's happening at it
	name = "AI Node"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x6" //Pure white 'X' with black borders
	var/datum/ai_node/datumnode = new/datum/ai_node() //Stores things about the AI node
	var/turf/srcturf //The turf this is on
	anchored = TRUE //No pulling those nodes yo
	alpha = 255

/obj/effect/ai_node/Initialize() //Add ourselve to the global list of nodes
	. = ..()
	srcturf = loc
	datumnode.parentnode = src
	GLOB.allnodes += src

//Current weights are nothing, wait for more ai updates
//Parameter call example
//GetBestAdjNode(list(ENEMY_PRESENCE = -100, DANGER_SCALE = -1)) if these were defined
//This means that the proc will pick out the *best* node

/obj/effect/ai_node/proc/GetBestAdjNode(list/weight_modifiers)
	if(weight_modifiers)
		var/obj/effect/ai_node/node_to_return = datumnode.adjacent_nodes[1]
		var/current_best_node = 0
		var/current_score = 0
		for(var/obj/effect/ai_node/node in shuffle(datumnode.adjacent_nodes)) //We keep a score for the nodes and see which one is best
			for(var/i = 1 to length(weight_modifiers))
				current_score += (node.datumnode.get_weight(i) * weight_modifiers[i])

			if(current_score >= current_best_node)
				current_best_node = current_score
				node_to_return = node
			current_score = 0

		if(node_to_return)
			return node_to_return

	else //No weight modifier, return a adjacent random node
		return pick(shuffle(datumnode.adjacent_nodes))

/obj/effect/ai_node/proc/MakeAdjacents()
	datumnode.adjacent_nodes = list()
	for(var/obj/effect/ai_node/node in GLOB.allnodes)
		if(node && (node != src) && (get_dist(src, node) < 16) && (get_dir(src, node) in CARDINAL_DIRS))
			datumnode.adjacent_nodes += node

/obj/effect/ai_node/proc/add_to_notable_nodes(weight) //For later:tm:

/obj/effect/ai_node/proc/remove_from_notable_nodes(weight)

/obj/effect/ai_node/debug //A debug version of the AINode; makes it visible to allow for easy var editing

/obj/effect/ai_node/debug/Initialize()
	. = ..()
	alpha = 127
	color = "#ffffff" //Color coding yo; white is 'unkonwn', green is 'safe' and red is 'danger'
