//Various macros
#define GET_WEIGHT(NODE, NAME) NODE.weights[NAME]

//Returns a node that is in the direction of this node; must be in the src's adjacent node list
/obj/effect/ai_node/proc/GetNodeInDirInAdj(dir)

	if(!length(datumnode.adjacent_nodes))
		return

	for(var/i in datumnode.adjacent_nodes)
		var/obj/effect/ai_node/node = i
		if(get_dir(src, node) != dir)
			continue
		return node

//The equivalent of get_step_towards but now for nodes; will NOT intelligently pathfind based on node weights or anything else
//Returns nothing if a suitable node in a direction isn't found, otherwise returns a node
/proc/get_node_towards(obj/effect/ai_node/startnode, obj/effect/ai_node/destination)
    if(startnode == destination)
        return startnode
    //Null value returned means no node in that direction
    return startnode.GetNodeInDirInAdj(get_dir(startnode, destination))

//Returns a list of humans via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_humans_near(atom/movable/source, distance)
	. = list()
	for(var/human in GLOB.alive_human_list)
		var/mob/living/carbon/human/nearby_human = human
		if(source.z != nearby_human.z)
			continue
		if(get_dist(source, nearby_human) > distance)
			continue
		. += nearby_human
	return .
