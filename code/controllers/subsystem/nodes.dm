SUBSYSTEM_DEF(nodes)
	name = "Nodes"
	init_order = INIT_ORDER_NODES
	wait = 1 SECONDS
	var/list/current_run

/datum/controller/subsystem/nodes/Initialize()
	InitAllAdjacent()
	return ..()

//Call this to manually make adjacencies
/datum/controller/subsystem/nodes/proc/InitAllAdjacent()
	for(var/obj/effect/AINode/nodes in GLOB.allnodes)
		nodes.MakeAdjacents()

/datum/controller/subsystem/nodes/fire(resume = FALSE)
	if(!resume)
		current_run = GLOB.allnodes.Copy()
	while(current_run.len)
		var/obj/effect/AINode/node = current_run[current_run.len]
		if(node.datumnode.get_weight(DANGER_SCALE) > 0)
			node.datumnode.increment_weight(DANGER_SCALE, -1)

		current_run.len--
		if(TICK_CHECK)
			return
