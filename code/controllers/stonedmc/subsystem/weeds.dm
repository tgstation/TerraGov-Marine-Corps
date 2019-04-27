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

	while(length(currentrun))
		var/obj/effect/alien/weeds/node/N
		N = currentrun[currentrun.len]
		currentrun.len--
		if(QDELETED(N))
			remove_node(N)
			continue

		var/list/to_create = list()

		// nodes in reverse order in reverse order
		for(var/X in N.node_turfs)
			var/turf/T = X
			if (locate(/obj/effect/alien/weeds) in T)
				continue

			for(var/direction in GLOB.cardinals) 
				var/turf/AdjT = get_step(T, direction)
				if (!(AdjT in N.node_turfs)) // only count our weed graph as eligble
					continue
				if (!(locate(/obj/effect/alien/weeds) in AdjT))
					continue

				to_create.Add(T)
				break

		// We create weeds outside of the loop to not influence new weeds within the loop
		for(var/X in to_create)
			var/turf/T = X
			create_weed(T, N)

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


/datum/controller/subsystem/weeds/proc/create_weed(turf/T, obj/effect/alien/weeds/node/N)

	if (!T.is_weedable())
		N.node_turfs -= T 
		return

	var/obj/effect/alien/weeds/W = locate() in T
	if (W)
		return

	if(iswallturf(T))
		var/obj/effect/alien/weeds/weedwall/WW = new (T)
		N.transfer_fingerprints_to(WW)
		return

	if (istype(T.loc, /area/arrival))
		return

	for (var/obj/O in T)
		if(istype(O, /obj/structure/window/framed))
			var/obj/effect/alien/weeds/weedwall/window/WN = new (T)
			N.transfer_fingerprints_to(WN)
			return
		else if(istype(O, /obj/structure/window_frame))
			var/obj/effect/alien/weeds/weedwall/frame/F = new (T)
			N.transfer_fingerprints_to(F)
			return
		else if(istype(O, /obj/machinery/door) && O.density /*&& (!(O.flags_atom & ON_BORDER) || O.dir != dirn)*/)
			return

	var/obj/effect/alien/weeds/S = new (T, N)
	N.transfer_fingerprints_to(S)

