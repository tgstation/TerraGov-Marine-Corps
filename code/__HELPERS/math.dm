/**
 * Get a list of turfs in a line from `starting_atom` to `ending_atom`.
 *
 * Uses the ultra-fast [Bresenham Line-Drawing Algorithm](https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm).
 */
/proc/get_line(atom/starting_atom, atom/ending_atom)
	var/px = starting_atom.x //starting x
	var/py = starting_atom.y
	var/list/line = list(locate(px, py, starting_atom.z))
	var/dx = ending_atom.x - px //x distance
	var/dy = ending_atom.y - py
	var/dxabs = abs(dx)//Absolute value of x distance
	var/dyabs = abs(dy)
	var/sdx = SIGN(dx) //Sign of x distance (+ or -)
	var/sdy = SIGN(dy)
	var/x = dxabs >> 1 //Counters for steps taken, setting to distance/2
	var/y = dyabs >> 1 //Bit-shifting makes me l33t.  It also makes get_line() unnessecarrily fast.
	var/j //Generic integer for counting
	if(dxabs >= dyabs) //x distance is greater than y
		for(j = 0; j < dxabs; j++)//It'll take dxabs steps to get there
			y += dyabs
			if(y >= dxabs) //Every dyabs steps, step once in y direction
				y -= dxabs
				py += sdy
			px += sdx //Step on in x direction
			line += locate(px, py, starting_atom.z)//Add the turf to the list
	else
		for(j=0 ;j < dyabs; j++)
			x += dxabs
			if(x >= dyabs)
				x -= dyabs
				px += sdx
			py += sdy
			line += locate(px, py, starting_atom.z)
	return line

/proc/can_see_through(turf/from_turf, turf/to_turf)
	if(IS_OPAQUE_TURF(to_turf))
		return FALSE
	for(var/obj/stuff_in_turf in to_turf)
		if(!stuff_in_turf.opacity)
			continue
		if(!CHECK_BITFIELD(stuff_in_turf.flags_atom, ON_BORDER))
			return FALSE
		if(ISDIAGONALDIR(stuff_in_turf.dir))
			return FALSE
		if(CHECK_BITFIELD(stuff_in_turf.dir, get_dir(to_turf, from_turf)))
			return FALSE
	return TRUE


//Checks if ending atom is viewable by starting atom, uses bresenham line algorithm but checks some extra tiles on a diagonal next tile
/proc/line_of_sight(atom/starting_atom, atom/ending_atom, maximum_dist = 7)
	if(get_dist(starting_atom, ending_atom) > maximum_dist)
		return FALSE
	var/px = starting_atom.x //starting x
	var/py = starting_atom.y
	var/dx = ending_atom.x - px //x distance
	var/dy = ending_atom.y - py
	var/dxabs = abs(dx)//Absolute value of x distance
	var/dyabs = abs(dy)
	var/sdx = SIGN(dx) //Sign of x distance (+ or -)
	var/sdy = SIGN(dy)
	var/x = dxabs >> 1 //Counters for steps taken, setting to distance/2
	var/y = dyabs >> 1 //Bit-shifting makes me l33t.  It also makes get_line() unnessecarrily fast.
	var/j //Generic integer for counting
	var/turf/last_turf = get_turf(starting_atom)
	if(dxabs >= dyabs) //x distance is greater than y
		for(j = 0; j < dxabs; j++)//It'll take dxabs steps to get there
			y += dyabs
			if(y >= dxabs) //Every dyabs steps, step once in y direction
				y -= dxabs
				py += sdy
			px += sdx //Step on in x direction
			var/turf/turf_to_check = locate(px, py, starting_atom.z)//find the new turf
			var/old_turf_dir_to_us = get_dir(last_turf, turf_to_check)
			if(ISDIAGONALDIR(old_turf_dir_to_us))
				for(var/i=0, i<2, i++)
					var/between_turf = get_step(last_turf, turn(old_turf_dir_to_us, i == 1 ? 45 : -45))
					if(can_see_through(last_turf, between_turf))
						break
					if(i==2)
						return FALSE
			if(!can_see_through(last_turf, turf_to_check))
				return FALSE
	else
		for(j=0 ;j < dyabs; j++)
			x += dxabs
			if(x >= dyabs)
				x -= dyabs
				px += sdx
			py += sdy
			var/turf/turf_to_check = locate(px, py, starting_atom.z)//find the new turf
			var/old_turf_dir_to_us = get_dir(last_turf, turf_to_check)
			if(ISDIAGONALDIR(old_turf_dir_to_us))
				for(var/i=0, i<2, i++)
					var/between_turf = get_step(last_turf, turn(old_turf_dir_to_us, i == 1 ? 45 : -45))
					if(can_see_through(last_turf, between_turf))
						break
					if(i==2)
						return FALSE
			if(!can_see_through(last_turf, turf_to_check))
				return FALSE
	return TRUE



