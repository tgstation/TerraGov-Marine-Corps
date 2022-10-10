SUBSYSTEM_DEF(weeds)
	name = "Weed"
	priority = FIRE_PRIORITY_WEED
	runlevels = RUNLEVEL_LOBBY|RUNLEVEL_SETUP|RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 5 SECONDS

	// This is a list of nodes on the map.
	var/list/creating = list()
	var/list/pending = list()
	var/list/currentrun
	/// How many time each turf will check if it is weedable.
	var/list/spawn_attempts_by_node = list()

/datum/controller/subsystem/weeds/stat_entry()
	return ..("Nodes: [length(pending)]")

/datum/controller/subsystem/weeds/fire(resumed = FALSE)
	if(!resumed)
		currentrun = pending.Copy()
		creating = list()

	for(var/turf/T AS in currentrun)
		if(MC_TICK_CHECK)
			return

		var/obj/alien/weeds/node/node = currentrun[T]
		currentrun -= T

		var/obj/alien/weeds/weed = locate(/obj/alien/weeds) in T
		if(weed && !weed.parent_node && !istype(weed, /obj/alien/weeds/node))
			weed.set_parent_node(node)
			SSweeds_decay.decaying_list -= weed

		if(QDELETED(node) || QDELETED(T) || !T.is_weedable())
			pending -= T
			spawn_attempts_by_node -= T
			continue

		for(var/direction in GLOB.cardinals)
			var/turf/AdjT = get_step(T, direction)
			if (!(locate(/obj/alien/weeds) in AdjT))
				continue

			creating[T] = node
			pending -= T
			break
		spawn_attempts_by_node[T]--
		if(spawn_attempts_by_node[T] <= 0)
			pending -= T
			spawn_attempts_by_node -= T


	// We create weeds outside of the loop to not influence new weeds within the loop
	for(var/turf/T AS in creating)
		if(MC_TICK_CHECK)
			return
		// Adds a bit of jitter to the spawning weeds.
		addtimer(CALLBACK(src, .proc/create_weed, T, creating[T]), rand(1, 3 SECONDS))
		pending -= T
		spawn_attempts_by_node -= T
		creating -= T



/datum/controller/subsystem/weeds/proc/add_node(obj/alien/weeds/node/node)
	if(!node)
		stack_trace("SSweed.add_node called with a null obj")
		return FALSE

	for(var/turf/T AS in node.node_turfs)
		if(pending[T] && (get_dist_euclide_square(node, T) >= get_dist_euclide_square(get_step(pending[T], 0), T)))
			continue
		pending[T] = node
		spawn_attempts_by_node[T] = 5 //5 attempts maximum

/datum/controller/subsystem/weeds/proc/create_weed(turf/T, obj/alien/weeds/node/node)
	if(QDELETED(node))
		return

	if(iswallturf(T))
		new /obj/alien/weeds/weedwall(T, node)
		return
	var/swapped = FALSE
	for (var/obj/O in T)
		if(istype(O, /obj/structure/window/framed))
			new /obj/alien/weeds/weedwall/window(T, node)
			return
		else if(istype(O, /obj/structure/window_frame))
			new /obj/alien/weeds/weedwall/frame(T, node)
			return
		else if(istype(O, /obj/machinery/door) && O.density)
			return
		else if(istype(O, /obj/alien/weeds))
			if(istype(O, /obj/alien/weeds/node))
				return
			var/obj/alien/weeds/weed = O
			if(weed.parent_node && weed.parent_node != node && get_dist_euclide_square(node, weed) >= get_dist_euclide_square(weed.parent_node, weed))
				return
			if(weed.type == node.weed_type)
				weed.set_parent_node(node)
				return
			weed.swapped = TRUE
			swapped = TRUE
			qdel(O)
	new node.weed_type(T, node, swapped)
