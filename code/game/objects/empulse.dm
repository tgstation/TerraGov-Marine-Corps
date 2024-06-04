///EMP's everything in a specified radius, similar to an explosion
/proc/empulse(turf/epicenter, devastate_range, heavy_range, light_range, weak_range, log = FALSE)
	epicenter = get_turf(epicenter)
	if(!epicenter)
		return FALSE

	var/max_range = max(devastate_range, heavy_range, light_range, weak_range, 0)
	if(!max_range)
		return FALSE

	if(log)
		log_game("EMP with size ([devastate_range], [heavy_range], [light_range], [weak_range]) in area [AREACOORD(epicenter.loc)].")

	playsound(epicenter, 'sound/effects/EMPulse.ogg', 50, FALSE, max_range * 2)
	if(heavy_range || devastate_range)
		new /obj/effect/overlay/temp/emp_pulse (epicenter)

	var/list/turfs_in_range = filled_circle_turfs(epicenter, max_range)
	for(var/turf/affected_turf AS in turfs_in_range)
		var/distance = get_dist(epicenter, affected_turf)
		var/effective_severity
		if(distance <= devastate_range)
			effective_severity = EMP_DEVASTATE
		else if(distance <= heavy_range)
			effective_severity = EMP_HEAVY
		else if(distance <= light_range)
			effective_severity = EMP_LIGHT
		else
			effective_severity = EMP_WEAK

		for(var/atom/affected_atom AS in affected_turf)
			affected_atom.emp_act(effective_severity)

	return TRUE
