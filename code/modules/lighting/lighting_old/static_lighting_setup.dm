/proc/create_all_lighting_objects()
	for(var/area/A in world)

		if(!A.static_lighting)
			continue

		for(var/turf/T in A)
			new/datum/static_lighting_object(T)
			CHECK_TICK
		CHECK_TICK

//tivi todo list
//remove area lighting replace with static underlay lighting
//Instead of using overlays, replace the mutable appearance with  filters += filter(type="layer", icon = icon(LIGHTING_ICON_BIG, "triangle"), color = "#000", transform = M)
//get people to test eet
//change lava and co to static
///datum/static_light_source DELETE AFFECTING TURFS
