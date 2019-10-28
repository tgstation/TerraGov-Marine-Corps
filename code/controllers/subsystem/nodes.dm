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

		current_run.len--
		if(TICK_CHECK)
			return
