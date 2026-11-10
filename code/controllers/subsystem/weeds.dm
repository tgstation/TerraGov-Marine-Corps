SUBSYSTEM_DEF(weeds)
	name = "Weed"
	priority = FIRE_PRIORITY_WEED
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY|RUNLEVEL_SETUP|RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	wait = 5 SECONDS
	/// All turfs that are going to have weeds created ontop of them this run.
	/// Associative list of [/turf] = [/obj/alien/weeds/node]
	var/list/creating = list()
	/// All turfs that are within a weed node's range, but are pending as they haven't been checked to be weedable yet.
	/// Associative list of [/turf] = [/obj/alien/weeds/node]
	var/list/pending = list()
	/// A copy of the [pending] list in case the subsystem gets paused.
	var/list/current_run
	/// The amount of times each turf will be checked if it is weedable.
	var/list/spawn_attempts_by_node = list()

/datum/controller/subsystem/weeds/stat_entry()
	return ..("Nodes: [length(pending)]")

/datum/controller/subsystem/weeds/fire(resumed = FALSE)
	if(!resumed)
		current_run = pending.Copy()
		creating = list()

	for(var/turf/current_turf AS in current_run)
		if(MC_TICK_CHECK)
			return

		var/obj/alien/weeds/node/current_node = current_run[current_turf]
		current_run -= current_turf

		// Orphaned weed that we can take over as the new parent node (or should be deleted).
		var/obj/alien/weeds/found_weed = locate(/obj/alien/weeds) in current_turf
		if(found_weed && !QDELETED(current_node) && !found_weed.parent_node && !istype(found_weed, /obj/alien/weeds/node))
			if(!found_weed.set_parent_node(current_node))
				qdel(found_weed)
			SSweeds_decay.decaying_list -= found_weed

		// Something broke while we were waiting.
		if(QDELETED(current_node) || QDELETED(current_turf) || !current_turf.is_weedable())
			pending -= current_turf
			spawn_attempts_by_node -= current_turf
			continue

		// We only want to expand if we have weeds adjacent to us.
		for(var/cardinal_direction in GLOB.cardinals)
			var/turf/adjacent_turf = get_step(current_turf, cardinal_direction)
			if(!(locate(/obj/alien/weeds) in adjacent_turf))
				continue
			creating[current_turf] = current_node
			pending -= current_turf
			break

		// Try again later since we don't have any weeds near us.
		spawn_attempts_by_node[current_turf]--
		if(spawn_attempts_by_node[current_turf] <= 0)
			pending -= current_turf
			spawn_attempts_by_node -= current_turf

	// We create weeds outside of the loop to not influence new weeds within the loop.
	for(var/turf/current_turf AS in creating)
		if(MC_TICK_CHECK)
			return
		// Adds a bit of jitter to the spawning weeds.
		addtimer(CALLBACK(src, PROC_REF(create_weed), current_turf, creating[current_turf]), rand(0.1 SECONDS, 3 SECONDS))
		pending -= current_turf
		spawn_attempts_by_node -= current_turf
		creating -= current_turf

/// Where applicable, adds each turf from a weed node's [node_turfs] to the [pending] list.
/datum/controller/subsystem/weeds/proc/add_node(obj/alien/weeds/node/node)
	if(!node)
		stack_trace("SSweeds.add_node called with a null obj!")
		return FALSE

	for(var/turf/node_turf AS in node.node_turfs)
		if(pending[node_turf] && (get_dist_euclidean_square(node, node_turf) >= get_dist_euclidean_square(get_step(pending[node_turf], 0), node_turf)))
			continue
		pending[node_turf] = node
		spawn_attempts_by_node[node_turf] = (node.node_range * 2) + 1 // 2x of range is required as the corner of their range needs that amount. Not all attempts will be used if there are pre-existing weeds.

/// Creates various weed types on a turf based on the turf and its contents.
/datum/controller/subsystem/weeds/proc/create_weed(turf/chosen_turf, obj/alien/weeds/node/chosen_node)
	if(QDELETED(chosen_node))
		return
	var/obj/alien/weeds/weed_to_spawn = chosen_node.weed_type
	if(iswallturf(chosen_turf))
		weed_to_spawn = /obj/alien/weeds/weedwall

	var/are_we_swapping = FALSE
	for(var/obj/found_obj AS in chosen_turf)
		if(istype(found_obj, /obj/structure/window/framed))
			weed_to_spawn = /obj/alien/weeds/weedwall/window
			continue
		if(istype(found_obj, /obj/structure/window_frame))
			weed_to_spawn = /obj/alien/weeds/weedwall/window/frame
			continue
		if(istype(found_obj, /obj/machinery/door) && found_obj.density)
			return
		if(istype(found_obj, /obj/alien/weeds))
			if(istype(found_obj, /obj/alien/weeds/node))
				return
			var/obj/alien/weeds/found_weed = found_obj
			// Do not take ownership of nearby weeds if they're closer to their parent than us.
			if(found_weed.parent_node && found_weed.parent_node != chosen_node && get_dist_euclidean_square(chosen_node, found_weed) >= get_dist_euclidean_square(found_weed.parent_node, found_weed))
				return
			// Similar enough? Just become the new parent.
			if((found_weed.type == weed_to_spawn) && (found_weed.color_variant == found_weed.color_variant))
				found_weed.set_parent_node(chosen_node)
				return
			// Otherwise, fully replace it.
			found_weed.replace_weed(weed_to_spawn, chosen_node)
			return
	new weed_to_spawn(chosen_turf, chosen_node, are_we_swapping)
