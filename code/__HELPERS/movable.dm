/atom/movable/proc/line_of_sight(atom/target, view_dist = world.view)
	if(QDELETED(target))
		return FALSE

	if(z != target.z) //No multi-z.
		return FALSE

	var/total_distance = get_dist(src, target)

	if(total_distance > view_dist)
		return FALSE

	switch(total_distance)
		if(-1)
			if(target == src) //We can see ourselves alright.
				return TRUE
			else //Standard get_dist() error condition.
				return FALSE
		if(null) //Error, does not compute.
			CRASH("get_dist returned null on line_of_sight() with [src] as src and [target] as target")
		if(0, 1) //We can see our own tile and the next one regardless.
			return TRUE

	var/turf/turf_to_check = get_turf(src)
	var/turf/target_turf = get_turf(target)

	for(var/i in 1 to total_distance - 1)
		turf_to_check = get_step(turf_to_check, get_dir(turf_to_check, target_turf))
		if(turf_to_check.opacity)
			return FALSE //First and last turfs' opacity don't matter, but the ones in-between do.
		for(var/obj/stuff_in_turf in turf_to_check)
			if(!stuff_in_turf.opacity)
				continue //Transparent, we can see through it.
			if(!CHECK_BITFIELD(stuff_in_turf.flags_atom, ON_BORDER))
				return FALSE //Opaque and not on border. We can't see through this tile, it's over.
			if(ISDIAGONALDIR(stuff_in_turf.dir))
				return FALSE //Opaque fulltile window.
			if(CHECK_BITFIELD(dir, stuff_in_turf.dir))
				return FALSE //Same direction and opaque, blocks our view.
			if(CHECK_BITFIELD(dir, reverse_direction(stuff_in_turf.dir)))
				return FALSE //Doesn't block this tile, but it does block the next, and this is not the last pass.

	return TRUE