SUBSYSTEM_DEF(weeds)
	name = "Weed"
	priority = FIRE_PRIORITY_WEED
	runlevels = RUNLEVEL_LOBBY|RUNLEVEL_SETUP|RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 5 SECONDS

	// This is a list of nodes on the map.
	var/list/creating = list()
	var/list/pending = list()
	var/list/decaying = list()
	var/list/currentrun

	var/decay_tick = 1

/datum/controller/subsystem/weeds/stat_entry()
	return ..("Nodes: [length(pending)]")

/datum/controller/subsystem/weeds/fire(resumed = FALSE)
	if(!resumed)
		currentrun = pending.Copy()
		creating = list()

	// Decay weeds first, but only ever 3rd tick (x3 slower than growing weeds)
	if ((decay_tick % 4) == 0)
		decay_tick = 1
		for(var/A in decaying)
			if(MC_TICK_CHECK)
				return

			var/turf/T = A
			if(QDELETED(T))
				decaying -= T
				continue

			var/obj/effect/alien/weeds/W = locate() in T
			if(QDELETED(W) || W.parent_node)
				decaying -= T
				continue

			var/decay_chance = 100
			for(var/direction in GLOB.cardinals) 
				var/turf/adj = get_step(T, direction)
				if(locate(/obj/effect/alien/weeds) in adj)
					decay_chance -= rand(25, 40)

			if(decay_chance > 0 && prob(decay_chance))
				W.parent_node = null // So it wont try to regrow
				addtimer(CALLBACK(GLOBAL_PROC, .proc/qdel, W), rand(0, 7 SECONDS))
				decaying -= T
	else
		decay_tick++


	for(var/A in currentrun)
		if(MC_TICK_CHECK)
			return

		var/obj/effect/alien/weeds/node/N = currentrun[A]
		currentrun -= A
		var/turf/T = A

		if(QDELETED(N) || QDELETED(T))
			pending -= T
			continue

		if (!T.is_weedable() || istype(T.loc, /area/arrival))
			pending -= T
			continue

		if ((locate(/obj/effect/alien/weeds) in T) || (locate(/obj/effect/alien/weeds/node) in T))
			pending -= T
			continue

		for(var/direction in GLOB.cardinals) 
			var/turf/AdjT = get_step(T, direction)
			if (!(AdjT in N.node_turfs)) // only count our weed graph as eligble
				continue
			if (!(locate(/obj/effect/alien/weeds) in AdjT))
				continue

			creating[T] = N
			break

		
	// We create weeds outside of the loop to not influence new weeds within the loop
	for(var/A in creating)
		if(MC_TICK_CHECK)
			return
		var/turf/T = A
		var/obj/effect/alien/weeds/node/N = creating[T]
		creating -= T
		// Adds a bit of jitter to the spawning weeds.
		addtimer(CALLBACK(src, .proc/create_weed, T, N), rand(0, 3 SECONDS))
		pending -= T



/datum/controller/subsystem/weeds/proc/add_node(obj/effect/alien/weeds/node/N)
	if(!N)
		stack_trace("SSweed.add_node called with a null obj")
		return FALSE

	for(var/X in N.node_turfs)
		var/turf/T = X

		// Skip if there is a node there
		var/obj/effect/alien/weeds/W = locate() in T
		if(W)
			W.parent_node = N // new parent
			continue

		pending[T] = N

/datum/controller/subsystem/weeds/proc/add_weed(obj/effect/alien/weeds/W)
	if(!W)
		stack_trace("SSweed.add_turf called with a null obj")
		return FALSE

	var/turf/T = get_turf(W)
	pending[T] = W.parent_node


/datum/controller/subsystem/weeds/proc/decay_weeds(list/obj/effect/alien/weeds/node_turfs)
	for(var/X in node_turfs)
		var/turf/T = X

		// Skip if there is not a weed there
		var/obj/effect/alien/weeds/W = locate() in T
		if(!W)
			continue

		W.parent_node = null // otherwise the weed regrows
		decaying += T


/datum/controller/subsystem/weeds/proc/create_weed(turf/T, obj/effect/alien/weeds/node/N)
	if(iswallturf(T))
		new /obj/effect/alien/weeds/weedwall(T)
		return

	for (var/obj/O in T)
		if(istype(O, /obj/structure/window/framed))
			new /obj/effect/alien/weeds/weedwall/window(T)
			return
		else if(istype(O, /obj/structure/window_frame))
			new /obj/effect/alien/weeds/weedwall/frame(T)
			return
		else if(istype(O, /obj/machinery/door) && O.density /*&& (!(O.flags_atom & ON_BORDER) || O.dir != dirn)*/)
			return

	new /obj/effect/alien/weeds(T, N)