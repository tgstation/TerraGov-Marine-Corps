/proc/create_all_lighting_objects()
	for(var/area/A in world)

		if(!A.static_lighting)
			continue

		// I hate this so much dude. why do areas not track their turfs lummyyyyyyy
		for(var/turf/T in A)
			new/datum/static_lighting_object(T)
			CHECK_TICK
		CHECK_TICK
