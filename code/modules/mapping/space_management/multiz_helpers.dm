/proc/get_step_multiz(ref, dir)
	var/turf/us = get_turf(ref)
	if(dir & UP)
		dir &= ~UP
		return get_step(GET_TURF_ABOVE(us), dir)
	if(dir & DOWN)
		dir &= ~DOWN
		return get_step(GET_TURF_BELOW(us), dir)
	return get_step(ref, dir)

/proc/get_dir_multiz(turf/us, turf/them)
	us = get_turf(us)
	them = get_turf(them)
	if(!us || !them)
		return NONE
	if(us.z == them.z)
		return get_dir(us, them)
	else
		var/turf/T = GET_TURF_ABOVE(us)
		var/dir = NONE
		if(T && (T.z == them.z))
			dir = UP
		else
			T = GET_TURF_BELOW(us)
			if(T && (T.z == them.z))
				dir = DOWN
			else
				return get_dir(us, them)
		return (dir | get_dir(us, them))

///Whether two atoms are on the same z-level, or on related stacked z-levels
/proc/is_on_connected_level(atom/first, atom/second)
	var/turf/first_turf = get_turf(first)
	var/turf/second_turf = get_turf(second)
	if(!first_turf || !second_turf)
		return FALSE
	return first_turf.z == second_turf.z || (second_turf.z in SSmapping.get_connected_levels(first_turf.z))

/proc/get_lowest_turf(atom/ref)
	var/turf/us = get_turf(ref)
	var/turf/next = GET_TURF_BELOW(us)
	while(next)
		us = next
		next = GET_TURF_BELOW(us)
	return us

// I wish this was lisp
/proc/get_highest_turf(atom/ref)
	var/turf/us = get_turf(ref)
	var/turf/next = GET_TURF_ABOVE(us)
	while(next)
		us = next
		next = GET_TURF_ABOVE(us)
	return us
