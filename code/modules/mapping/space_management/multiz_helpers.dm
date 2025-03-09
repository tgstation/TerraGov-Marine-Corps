/proc/get_lowest_turf(atom/ref)
	var/turf/us = get_turf(ref)
	return us
	/*
	var/turf/next = GET_TURF_BELOW(us)
	while(next)
		us = next
		next = GET_TURF_BELOW(us)
	return us*/

// I wish this was lisp
/proc/get_highest_turf(atom/ref)
	var/turf/us = get_turf(ref)
	return us /*
	var/turf/next = GET_TURF_ABOVE(us)
	while(next)
		us = next
		next = GET_TURF_ABOVE(us)
	return us*/
