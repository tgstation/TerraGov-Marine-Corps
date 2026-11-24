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

///Returns the turf above or below from_turf if a projectile can pass between them
/proc/get_multiz_shot_step(turf/from_turf, direction)
	var/turf/next_turf = get_step_multiz(from_turf, direction)
	if(next_turf && from_turf.zPassOut(direction) && next_turf.zPassIn(direction))
		return next_turf

/**
 * Returns the turf on the target's z level that a projectile fired from source will start from.
 * Returns source's turf if they are on the same z level, or null if the projectile can't reach the target's z level.
 * Arguments
 * * source - The atom firing the projectile
 * * target - The atom being fired at
 */
/proc/get_multiz_shot_origin(atom/source, atom/target)
	var/turf/source_turf = get_turf(source)
	var/turf/target_turf = get_turf(target)
	if(!source_turf || !target_turf)
		return null
	if(source_turf.z == target_turf.z)
		return source_turf
	if(!(target_turf.z in SSmapping.get_connected_levels(source_turf.z)))
		return null
	var/direction = target_turf.z > source_turf.z ? UP : DOWN
	var/turf/origin = get_multiz_shot_step(source_turf, direction)
	if(!origin && direction == DOWN)
		var/direction_ahead = get_dir(source_turf, target_turf) //get_dir ignores z level
		var/turf/turf_ahead = direction_ahead ? get_step(source_turf, direction_ahead) : null
		if(turf_ahead)
			origin = get_multiz_shot_step(turf_ahead, DOWN)
	while(origin && origin.z != target_turf.z)
		origin = get_multiz_shot_step(origin, direction)
	return origin
