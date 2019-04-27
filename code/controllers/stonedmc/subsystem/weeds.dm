SUBSYSTEM_DEF(weeds)
	name = "Weed"
	priority = FIRE_PRIORITY_WEED
	runlevels = RUNLEVEL_GAME
	wait = 5 SECONDS

	// This is a list of nodes on the map.
	var/list/weed_nodes = list()
	var/list/currentrun

/datum/controller/subsystem/weeds/Initialize(start_timeofday)
	return ..()

/datum/controller/subsystem/weeds/stat_entry()
	return ..("Nodes: [length(weed_nodes)]")

/datum/controller/subsystem/weeds/fire(resumed = FALSE)
	if(!resumed)
		currentrun = deepCopyList(weed_nodes)

	var/obj/effect/alien/weeds/node/N
	while(length(currentrun))
		N = currentrun[currentrun.len]
		currentrun.len--
		if(QDELETED(N))
			weed_nodes.Remove(N)
			continue

		// PROCESS N in reverse order
		for(var/X in N.node_turfs)
			var/turf/T = X
			if (locate(/obj/effect/alien/weeds) in T)
				continue

			for(var/direction in GLOB.cardinals) 
				var/turf/AdjT = get_step(T, direction)

				if (locate(/obj/effect/alien/weeds) in AdjT)
					new /obj/effect/alien/weeds(T)
					break

		if(MC_TICK_CHECK)
			return
		
/datum/controller/subsystem/weeds/proc/add_node(obj/effect/alien/weeds/node/N)
	if(!N)
		stack_trace("SSweed.add_node called with a null obj")
		return FALSE
	weed_nodes.Add(N)

/datum/controller/subsystem/weeds/proc/remove_node(obj/effect/alien/weeds/node/N)
	if(!N)
		stack_trace("SSweed.remove_node called with a null obj")
		return FALSE
	weed_nodes.Remove(N)

/datum/controller/subsystem/weeds/proc/generate_weed_graph(obj/effect/alien/weeds/node/N, node_size)
	var/list/node_turfs = list()
	var/list/turfs_to_check = list()
	turfs_to_check += get_turf(N)
	while (node_size > 0)
		node_size--
		for(var/X in turfs_to_check)
			var/turf/T = X

			for(var/direction in GLOB.cardinals) 
				var/turf/AdjT = get_step(T, direction)

				if (AdjT == N) // Ignore the node
					continue
				if (AdjT in node_turfs) // Ignore existing weeds
					continue

				turfs_to_check += AdjT
				node_turfs += AdjT


	for(var/turf/smallT in node_turfs) 
		new /obj/effect/alien/weeds(smallT)

