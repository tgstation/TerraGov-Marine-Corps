//Returns a node that is in the direction of this node; must be in the src's adjacent node list
/obj/effect/ai_node/proc/GetNodeInDirInAdj(dir)

	if(!length(datumnode.adjacent_nodes))
		return

	for(var/i in datumnode.adjacent_nodes)
		var/obj/effect/ai_node/node = i
		if(get_dir(src, node) == dir)
			return node

//The equivalent of get_step_towards but now for nodes; will NOT intelligently pathfind based on node weights or anything else
//Returns nothing if a suitable node in a direction isn't found, otherwise returns a node
/proc/get_node_towards(obj/effect/ai_node/startnode, obj/effect/ai_node/destination)
	if(startnode == destination)
		return startnode
	var/list/possibledir = DiagonalToCardinal(get_dir(startnode, destination))
	var/list/possiblenodes = list(startnode.GetNodeInDirInAdj(possibledir[1]), startnode.GetNodeInDirInAdj(possibledir[2]))
	if(possiblenodes[1]) //See if the first index will give us a node
		return possiblenodes[1]
	if(possiblenodes[2]) //Try the other index; return FALSE if neither direction produces a node
		return possiblenodes[2]

//Returns a list of humans via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_humans_near(source, distance)
	var/list/listofhuman = list() //All humans in range
	for(var/human in GLOB.alive_human_list)
		if(get_dist(source, human) <= distance)
			listofhuman += human
	return listofhuman
