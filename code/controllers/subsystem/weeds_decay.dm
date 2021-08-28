SUBSYSTEM_DEF(weeds_decay)
	name = "Weed Decay"
	priority = FIRE_PRIORITY_WEED
	runlevels = RUNLEVEL_LOBBY|RUNLEVEL_SETUP|RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 5 SECONDS

	/// List of decaying nodes on the map
	var/list/decaying = list()

/datum/controller/subsystem/weeds_decay/stat_entry()
	return ..("Decay Nodes: [length(decaying)]")

/datum/controller/subsystem/weeds_decay/fire(resumed = FALSE)

	for(var/A in decaying)
		if(MC_TICK_CHECK)
			return

		var/turf/T = A
		if(QDELETED(T))
			decaying -= T
			continue

		var/obj/effect/alien/weeds/W = locate() in T
		if(QDELETED(W) || W.parent_node || istype(W, /obj/effect/alien/weeds/node))
			decaying -= T
			continue

		var/decay_chance = 100
		for(var/direction in GLOB.cardinals)
			var/turf/adj = get_step(T, direction)
			if(locate(/obj/effect/alien/weeds) in adj)
				decay_chance -= rand(15, 20)

		if(prob(decay_chance))
			W.parent_node = null // So it wont try to regrow
			addtimer(CALLBACK(GLOBAL_PROC, .proc/qdel, W), rand(3, 10 SECONDS))
			decaying -= T

/datum/controller/subsystem/weeds_decay/proc/decay_weeds(obj/effect/alien/weeds/node/node)
	for(var/X in node.node_turfs)
		var/turf/T = X

		// Skip if there is not a weed there
		var/obj/effect/alien/weeds/W = locate() in T
		if(!W || W.parent_node != node)
			continue

		W.parent_node = null // mark this null otherwise the weed regrows
		decaying += T

