
/area
	var/lighting_use_dynamic = 1	//Turn this flag off to prevent sd_DynamicAreaLighting from affecting this area

/area/New()
	. = ..()
	if(!lighting_use_dynamic)
		luminosity = 1

/*
/area/proc/SetDynamicLighting()
	lighting_use_dynamic = 1
	luminosity = 0
	for(var/turf/T in src.contents)
		T.init_lighting()
		T.update_lumcount(0)
*/

/area/SetLuminosity(new_luminosity)			//we don't want dynamic lighting for areas
	luminosity = !!new_luminosity


