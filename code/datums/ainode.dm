/datum/ai_node
    var/turf/location // tile the node is on
    var/list/adjacent_nodes // list of adjacent landmark nodes, list(/datum/ai_node/node1 = cost to node, /datum/ai_node/node2 = cost to node, etc)
    var/last_visit = -1
    var/list/safety_list // last x safety values   list(world.time = safetyvalue)
    var/list/target_list // last x target values
    var/safety // current safety value
    var/target // current target value

/proc/pathfindtonode(var/obj/effect/landmark/AINode/startingnode, var/obj/effect/landmark/AINode/destinationmark)
	var/list/travelpath = list(startingnode)
	var/obj/effect/landmark/AINode/currentnode //Current landmark node were at, defined for simplicity
	while(travelpath[length(travelpath)] != destinationmark)
		currentnode = travelpath[length(travelpath)]
		if(destinationmark.ai_node in currentnode.ai_node.adjacent_nodes)
			world << "Found destination landmark node for travel path" //It's an adjacent node, we can move to it
			travelpath |= destinationmark
		else //Time to randomly pick a node that's adjacent to currentnode to travel to and pray to rngod
			world << "Adding randomly chosen node for travel path"
			travelpath |= pick(currentnode.ai_node.adjacent_nodes)

	world << "Last node in travel path is destination, returning list of travel path."
	travelpath -= startingnode //Oh yeah remove first index
	return travelpath

/mob/living/carbon/Xenomorph/AI/Runner/nodefinder //A xenomorph for node finding; doesn't move at all besides teleports
	trueidle = TRUE
	var/list/nodepathing = list() //Lists of nodes to travel to
	var/obj/effect/landmark/AINode/currentnode //Current node at
	var/obj/effect/landmark/AINode/destinationnode //Node it wants to go to
	move_to_delay = 4
	var/list/currentpath //Current path this should take; isn't refreshed sadly

/mob/living/carbon/Xenomorph/AI/Runner/nodefinder/New()
	..()
	currentnode = pick(AINodes)
	forceMove(get_turf(currentnode))

/mob/living/carbon/Xenomorph/AI/Runner/nodefinder/ConsiderMovement()
	..()
	if(!destinationnode || destinationnode == currentnode)
		destinationnode = pick(AINodes)
	if((destinationnode != currentnode) && !currentpath)
		currentpath = pathfindtonode(currentnode, destinationnode)
	if(currentpath) //Let's get moving
		forceMove(get_turf(currentpath[1]))
		currentnode = currentpath[1]
		currentpath -= currentpath[1]