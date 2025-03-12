/**
 * Get a list of turfs in a line from `starting_atom` to `ending_atom`.
 *
 * Uses the ultra-fast [Bresenham Line-Drawing Algorithm](https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm).
 */
/proc/get_line(atom/starting_atom, atom/ending_atom, cardinal_moves = FALSE)
	var/current_x = starting_atom.x //start at x and y, then add 1 or -1 to these to get every turf from starting_atom to ending_atom
	var/current_y = starting_atom.y

	var/list/line = list(get_turf(starting_atom)) //get_turf(atom) is faster than locate(x, y, z)

	var/x_distance = ending_atom.x - current_x //x distance
	var/y_distance = ending_atom.y - current_y

	var/abs_x_distance = abs(x_distance) //Absolute value of x distance
	var/abs_y_distance = abs(y_distance)

	var/x_step = SIGN(x_distance) //Sign of x distance (+ or -)
	var/y_step = SIGN(y_distance)

	var/error = abs_x_distance - abs_y_distance // The Bresenham error term

	while(current_x != ending_atom.x || current_y != ending_atom.y)
		var/double_error = error * 2

		// Adjust X and/or Y based on error term
		if(double_error > -abs_y_distance)
			error -= abs_y_distance
			current_x += x_step

		if(double_error < abs_x_distance)
			error += abs_x_distance
			current_y += y_step

		line += locate(current_x, current_y, starting_atom.z)

	return line

/**
 * Get a list of turfs in a line from `starting_atom` to `ending_atom`.
 * Unlike get_line, this only takes cardinal steps, useful for checking movement or LOS
 * Uses the ultra-fast [Bresenham Line-Drawing Algorithm](https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm).
 */
/proc/get_traversal_line(atom/starting_atom, atom/ending_atom)
	var/current_x = starting_atom.x //start at x and y, then add 1 or -1 to these to get every turf from starting_atom to ending_atom
	var/current_y = starting_atom.y

	var/list/line = list(get_turf(starting_atom)) //get_turf(atom) is faster than locate(x, y, z)

	var/x_distance = ending_atom.x - current_x //x distance
	var/y_distance = ending_atom.y - current_y

	var/abs_x_distance = abs(x_distance) //Absolute value of x distance
	var/abs_y_distance = abs(y_distance)

	var/x_step = SIGN(x_distance) //Sign of x distance (+ or -)
	var/y_step = SIGN(y_distance)

	var/error = abs_x_distance - abs_y_distance // The Bresenham error term

	while(current_x != ending_atom.x || current_y != ending_atom.y)
		var/double_error = error * 2

		// Adjust X and/or Y based on error term
		if(double_error > -abs_y_distance)
			error -= abs_y_distance
			current_x += x_step
			line += locate(current_x, current_y, starting_atom.z) // Record X step

		if(double_error < abs_x_distance)
			error += abs_x_distance
			current_y += y_step
			line += locate(current_x, current_y, starting_atom.z) // Record Y step

	return line

///Returns if a turf can be seen from another turf.
/proc/can_see_through(turf/from_turf, turf/to_turf)
	if(IS_OPAQUE_TURF(to_turf))
		return FALSE
	for(var/obj/stuff_in_turf in to_turf)
		if(!stuff_in_turf.opacity)
			continue
		if(!CHECK_BITFIELD(stuff_in_turf.atom_flags, ON_BORDER))
			return FALSE
		if(ISDIAGONALDIR(stuff_in_turf.dir))
			return FALSE
		if(CHECK_BITFIELD(stuff_in_turf.dir, get_dir(to_turf, from_turf)))
			return FALSE
	return TRUE


///Checks if ending atom is viewable by starting atom, uses bresenham line algorithm but checks some extra tiles on a diagonal next tile
/proc/line_of_sight(atom/starting_atom, atom/ending_atom, maximum_dist = 7, ignore_target_opacity = FALSE)
	if(get_dist(starting_atom, ending_atom) > maximum_dist)
		return FALSE
	var/current_x_step = starting_atom.x//start at x and y, then add 1 or -1 to these to get every turf from starting_atom to ending_atom
	var/current_y_step = starting_atom.y

	var/x_distance = ending_atom.x - current_x_step //x distance
	var/y_distance = ending_atom.y - current_y_step

	var/abs_x_distance = abs(x_distance)//Absolute value of x distance
	var/abs_y_distance = abs(y_distance)

	var/x_distance_sign = SIGN(x_distance) //Sign of x distance (+ or -)
	var/y_distance_sign = SIGN(y_distance)

	var/x = abs_x_distance >> 1 //Counters for steps taken, setting to distance/2
	var/y = abs_y_distance >> 1 //Bit-shifting makes me l33t.  It also makes get_line() unnessecarrily fast.
	var/turf/final_turf = get_turf(ending_atom) //The goal
	var/turf/last_turf = get_turf(starting_atom)
	if(abs_x_distance >= abs_y_distance) //x distance is greater than y
		for(var/distance_counter in 0 to (abs_x_distance - 1))//It'll take abs_x_distance steps to get there
			y += abs_y_distance

			if(y >= abs_x_distance) //Every abs_y_distance steps, step once in y direction
				y -= abs_x_distance
				current_y_step += y_distance_sign

			current_x_step += x_distance_sign //Step on in x direction

			var/turf/turf_to_check = locate(current_x_step, current_y_step, starting_atom.z)//find the new turf
			var/old_turf_dir_to_us = get_dir(last_turf, turf_to_check)
			if(ISDIAGONALDIR(old_turf_dir_to_us))
				for(var/i in 0 to 2)
					var/between_turf = get_step(last_turf, turn(old_turf_dir_to_us, i == 1 ? 45 : -45))
					if(can_see_through(last_turf, between_turf))
						break
					if(i==2)
						return FALSE
			if(!can_see_through(last_turf, turf_to_check))
				if(!(ignore_target_opacity && turf_to_check == final_turf)) //ignore_target_opacity chooses to ignore that for the final turf
					return FALSE
	else
		for(var/distance_counter in 0 to (abs_y_distance - 1))
			x += abs_x_distance

			if(x >= abs_y_distance)
				x -= abs_y_distance
				current_x_step += x_distance_sign

			current_y_step += y_distance_sign

			var/turf/turf_to_check = locate(current_x_step, current_y_step, starting_atom.z)//find the new turf
			var/old_turf_dir_to_us = get_dir(last_turf, turf_to_check)
			if(ISDIAGONALDIR(old_turf_dir_to_us))
				for(var/i in 0 to 2)
					var/between_turf = get_step(last_turf, turn(old_turf_dir_to_us, i == 1 ? 45 : -45))
					if(can_see_through(last_turf, between_turf))
						break
					if(i==2)
						return FALSE
			if(!can_see_through(last_turf, turf_to_check))
				if(!(ignore_target_opacity && turf_to_check == final_turf)) //ignore_target_opacity chooses to ignore that for the final turf
					return FALSE
	return TRUE

/// Returns the manhattan distance between two atoms. Returns INFINITY if either are not on a turf, for BYOND get_dist() parity.
/proc/get_dist_manhattan(atom/A, atom/B)
	if(!A.z || !B.z)
		return INFINITY

	return abs(A.x - B.x) + abs(A.y - B.y) + abs(A.z - B.z)
