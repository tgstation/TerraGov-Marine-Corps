//Various macros
#define GET_WEIGHT(NODE, NAME) NODE.weights[NAME]

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

//Ditto above but xenomorphs
/proc/cheap_get_xenos_near(atom/movable/source, distance)
	. = list()
	for(var/xeno in GLOB.alive_xeno_list)
		var/mob/living/carbon/xenomorph/nearby_xeno = xeno
		if(source.z != nearby_xeno.z)
			continue
		if(get_dist(source, nearby_xeno) > distance)
			continue
		. += nearby_xeno
