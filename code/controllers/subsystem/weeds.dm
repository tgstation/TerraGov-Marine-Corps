SUBSYSTEM_DEF(weeds)
	name = "Weed"
	priority = FIRE_PRIORITY_WEED
	runlevels = RUNLEVEL_LOBBY|RUNLEVEL_SETUP|RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 5 SECONDS

	// This is a list of nodes on the map.
	var/list/creating = list()
	var/list/pending = list()
	var/list/currentrun
	/// The amount of time a weed will try to spawn on a given tile
	var/list/attempt = list()

/datum/controller/subsystem/weeds/stat_entry()
	return ..("Nodes: [length(pending)]")

/datum/controller/subsystem/weeds/fire(resumed = FALSE)
	if(!resumed)
		currentrun = pending.Copy()
		creating = list()

	for(var/turf/T AS in currentrun)
		if(MC_TICK_CHECK)
			return

		var/obj/effect/alien/weeds/node/node = currentrun[T]
		currentrun -= T

		if(QDELETED(node) || QDELETED(T))
			pending -= T
			attempt -= T
			continue

		if (locate(/obj/effect/alien/weeds/node) in T)
			pending -= T
			attempt -= T
			continue

		if (!T.is_weedable())
			pending -= T
			attempt -= T
			continue

		for(var/direction in GLOB.cardinals)
			var/turf/AdjT = get_step(T, direction)
			if (!(locate(/obj/effect/alien/weeds) in AdjT))
				continue

			creating[T] = node
			pending -= T
			break
		attempt[T]--
		if(attempt[T] <= 0)
			pending -= T
			attempt -= T


	// We create weeds outside of the loop to not influence new weeds within the loop
	for(var/turf/T AS in creating)
		if(MC_TICK_CHECK)
			return
		// Adds a bit of jitter to the spawning weeds.
		addtimer(CALLBACK(src, .proc/create_weed, T, creating[T]), rand(1, 3 SECONDS))
		pending -= T
		attempt -= T
		creating -= T



/datum/controller/subsystem/weeds/proc/add_node(obj/effect/alien/weeds/node/node)
	if(!node)
		stack_trace("SSweed.add_node called with a null obj")
		return FALSE

	for(var/turf/T AS in node.node_turfs)
		if(pending[T] && (get_dist_euclide_square(node, T) >= get_dist_euclide_square(get_step(pending[T], 0), T)))
			continue
		pending[T] = node
		attempt[T] = 5 //5 attempts maximum

/datum/controller/subsystem/weeds/proc/create_weed(turf/T, obj/effect/alien/weeds/node/node)
	if(QDELETED(node))
		return

	if(iswallturf(T))
		new /obj/effect/alien/weeds/weedwall(T, node)
		return

	for (var/obj/O in T)
		if(istype(O, /obj/structure/window/framed))
			new /obj/effect/alien/weeds/weedwall/window(T, node)
			return
		else if(istype(O, /obj/structure/window_frame))
			new /obj/effect/alien/weeds/weedwall/frame(T, node)
			return
		else if(istype(O, /obj/machinery/door) && O.density)
			return
		else if(istype(O, /obj/effect/alien/weeds))
			if(istype(O, /obj/effect/alien/weeds/node))
				return
			var/obj/effect/alien/weeds/weed = O
			if(get_dist_euclide_square(node, weed) >= get_dist_euclide_square(weed.parent_node, weed))
				return
			if(weed.type == node.weed_type)
				weed.parent_node = node
				return
			qdel(O)
	new node.weed_type(T, node)
