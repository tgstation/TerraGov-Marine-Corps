var/list/global/AINodes = list() //A list of all landmarks with AI nodes; should probably be sorted by z level

/obj/effect/landmark/AINode //A effect that has a ai_node datum in it, used by AIs to pathfind over long distances as well as knowing what's happening at it
	name = "AI Node"
	var/datum/ai_node/ai_node = new/datum/ai_node() //Stores things about the AI node

/obj/effect/landmark/AINode/New() //Build the list of adjacent_nodes nearby in cardinal directions
	..()
	spawn(100)
		world << "Initializing AI nodes"
		AINodes += src
		ai_node.location = loc
		var/list/card = list(NORTH, SOUTH, WEST, EAST)
		for(var/obj/effect/landmark/AINode/node in AINodes)
			if(get_dist(src, node) < 5 && (get_dir(src, node) in card))
				ai_node.adjacent_nodes += node
				world << "added node to adjacent_node from direction [get_dir(src, node)] at [loc.x] x and [loc.y] y"

/obj/effect/landmark/AINode/debug //A debug version of the AINode; makes it visible to allow for easy var editing

/obj/effect/landmark/AINode/debug/New()
	..()
	invisibility = 0
