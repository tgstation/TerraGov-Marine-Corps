SUBSYSTEM_DEF(nodes)
	name = "Nodes"
	init_order = INIT_ORDER_AI_NODES
	flags = SS_NO_FIRE //For now

/datum/controller/subsystem/nodes/Initialize()
	repopulate_node_adjacencies()
	return ..()

//Call this to manually make adjacencies
/datum/controller/subsystem/nodes/proc/repopulate_node_adjacencies()
	for(var/nodes in GLOB.allnodes)
		var/atom/movable/effect/ai_node/node = nodes
		node.make_adjacents()
