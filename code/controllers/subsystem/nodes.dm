SUBSYSTEM_DEF(nodes)
	name = "Nodes"
	init_order = INIT_ORDER_NODES
	wait = 1 SECONDS
	flags = SS_NO_FIRE //For now
	var/list/current_run

/datum/controller/subsystem/nodes/Initialize()
	InitAllAdjacent()
	return ..()

//Call this to manually make adjacencies
/datum/controller/subsystem/nodes/proc/InitAllAdjacent()
	for(var/obj/effect/AINode/nodes in GLOB.allnodes)
		nodes.MakeAdjacents()

