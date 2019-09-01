
//A file containing helpers for nodes and direction related things

GLOBAL_LIST_EMPTY(allnodes)

//Converts input direction to a list of either two same directions if the input is cardinal
//Otherwise will return the two directions that make up the diagonal
/proc/DiagonalToCardinal(direct)
	if(direct in GLOB.cardinals)
		return list(direct, direct)
	return list(NSCOMPONENT(direct), EWCOMPONENT(direct))

	switch(direct)
		if(NORTHEAST)
			return shuffle(list(NORTH, EAST))
		if(NORTHWEST)
			return shuffle(list(NORTH, WEST))
		if(SOUTHEAST)
			return shuffle(list(SOUTH, EAST))
		if(SOUTHWEST)
			return shuffle(list(SOUTH, WEST))

//Returns a node that is in the direction of this node; must be in the src's adjacent node list
/obj/effect/AINode/proc/GetNodeInDirInAdj(dir)

	if(!datumnode.adjacent_nodes || !datumnode.adjacent_nodes.len)
		return null

	for(var/obj/effect/AINode/node in datumnode.adjacent_nodes)
		if(get_dir(src, node) == dir)
			return node
	return null

//Current weights are ENEMY_PRESENCE & DANGER_SCALE
//Parameter call example
//GetBestAdjNode(list(ENEMY_PRESENCE = -100, DANGER_SCALE = -1))
//This means that the proc will pick out the *best* node, score is negatively impacted by amount of enemies and danger scale

/obj/effect/AINode/proc/GetBestAdjNode(list/weight_modifiers)
	if(weight_modifiers)
		var/obj/effect/AINode/node_to_return = datumnode.adjacent_nodes[1]
		var/current_best_node = 0
		var/current_score = 0
		for(var/obj/effect/AINode/node in shuffle(datumnode.adjacent_nodes)) //We keep a score for the nodes and see which one is best
			for(var/i = 1; i != weight_modifiers.len; i++)
				current_score += (node.datumnode.get_weight(i) * weight_modifiers[i])

			if(current_score >= current_best_node)
				current_best_node = current_score
				node_to_return = node
			current_score = 0

		if(node_to_return)
			return node_to_return

	else //No weight modifier, return a adjacent random node
		return pick(shuffle(datumnode.adjacent_nodes))

//The equivalent of get_step_towards but now for nodes; will NOT intelligently pathfind based on node weights or anything else
//Returns nothing if a suitable node in a direction isn't found, otherwise returns a node
/proc/get_node_towards(obj/effect/AINode/startnode, obj/effect/AINode/destination)
	if(startnode == destination)
		return startnode
	var/list/possibledir = DiagonalToCardinal(get_dir(startnode, destination))
	var/list/possiblenodes = list(startnode.GetNodeInDirInAdj(possibledir[1]), startnode.GetNodeInDirInAdj(possibledir[2]))
	if(possiblenodes[1]) //See if the first index will give us a node
		return possiblenodes[1]
	if(possiblenodes[2]) //Try the other index; return FALSE if neither direction produces a node
		return possiblenodes[2]
	return null

//Returns a list of humans via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_humans_near(source, distance)
	var/list/listofhuman = list() //All humans in range
	for(var/human in GLOB.alive_human_list)
		if(get_dist(source, human) <= distance)
			listofhuman += human
	return listofhuman

/proc/GetRandomNode() //Gets a new random destination that isn't it's current node
	return pick(GLOB.allnodes)

/proc/LeftAndRightOfDir(direction) //Returns the left and right dir of the input dir, used for AI stutter step and cade movement
	var/list/somedirs = list()
	switch(direction)
		if(NORTH)
			somedirs = list(WEST, EAST)
		if(SOUTH)
			somedirs = list(EAST, WEST)
		if(WEST)
			somedirs = list(SOUTH, NORTH)
		if(EAST)
			somedirs = list(NORTH, SOUTH)
		if(NORTHEAST)
			somedirs = list(NORTH, EAST)
		if(NORTHWEST)
			somedirs = list(NORTH, WEST)
		if(SOUTHEAST)
			somedirs = list(SOUTH, EAST)
		if(SOUTHWEST)
			somedirs = list(SOUTH, WEST)

	return(somedirs)
