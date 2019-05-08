SUBSYSTEM_DEF(weeds)
	name = "Weed"
	priority = FIRE_PRIORITY_WEED
	runlevels = RUNLEVEL_LOBBY|RUNLEVEL_SETUP|RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 5 SECONDS

	// This is a list of nodes on the map.
	var/list/creating = list()
	var/list/pending = list()
	var/list/currentrun

/datum/controller/subsystem/weeds/stat_entry()
	return ..("Nodes: [length(pending)]")

/datum/controller/subsystem/weeds/fire(resumed = FALSE)
	if(!resumed)
		currentrun = pending.Copy()
		creating = list()

	for(var/A in currentrun)
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

		if(MC_TICK_CHECK)
			return

	// We create weeds outside of the loop to not influence new weeds within the loop
	for(var/A in creating)
		var/turf/T = A
		var/obj/effect/alien/weeds/node/N = creating[T]
		creating -= T
		// Adds a bit of jitter to the spawning weeds.
		addtimer(CALLBACK(src, .proc/create_weed, T, N), rand(0,10))
		pending -= T

		if(MC_TICK_CHECK)
			return
		

/datum/controller/subsystem/weeds/proc/add_node(obj/effect/alien/weeds/node/N)
	if(!N)
		stack_trace("SSweed.add_node called with a null obj")
		return FALSE

	for(var/X in N.node_turfs)
		var/turf/T = X

		// Skip if there is a node there
		if(locate(/obj/effect/alien/weeds/node) in T)
			continue

		pending[T] = N

/datum/controller/subsystem/weeds/proc/add_weed(obj/effect/alien/weeds/W)
	if(!W)
		stack_trace("SSweed.add_turf called with a null obj")
		return FALSE

	var/turf/T = get_turf(W)
	pending[T] = W.parent_node


/datum/controller/subsystem/weeds/proc/create_weed(turf/T, obj/effect/alien/weeds/node/N)
	if(iswallturf(T))
		var/obj/effect/alien/weeds/weedwall/WW = new (T)
		N.transfer_fingerprints_to(WW)
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

