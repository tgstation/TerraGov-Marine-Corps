

turf
	var/lighting_lumcount = 0
	var/lighting_changed = 0
	var/color_lighting_lumcount = 0
	var/atom/movable/light_object/lighting_object //null for space turfs and anything in a static lighting area
	var/list/affecting_lights

	var/lumcount_r = 0
	var/lumcount_g = 0
	var/lumcount_b = 0



//Turfs with opacity when they are constructed will trigger nearby lights to update
//Turfs and atoms with luminosity when they are constructed will create a light_source automatically
turf/New()
	..()
	if(luminosity)
		if(light)	WARNING("[type] - Don't set lights up manually during New(), We do it automatically.")
		light = new(src)

/turf/ChangeTurf(var/path)
	if(!path || path == type) //Sucks this is here but it would cause problems otherwise.
		return ..()

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)

	if(light)
		cdel(light)
		light = null

	var/list/our_lights //reset affecting_lights if needed
	var/list/our_sources

	if(opacity != initial(path:opacity) && old_lumcount)
		UpdateAffectingLights()

	if(affecting_lights)
		our_lights = affecting_lights.Copy()

	if(light_sources)
		our_sources = light_sources.Copy()

	. = ..() //At this point the turf has changed

	affecting_lights = our_lights
	light_sources = our_sources

	lighting_changed = 1 //Don't add ourself to SSlighting.changed_turfs
	update_lumcount(old_lumcount)
	lighting_object = locate() in src
	init_lighting()


turf/space
	lighting_lumcount = 4		//starlight

turf/proc/update_lumcount(amount, col_r, col_g, col_b, removing = 0)
	lighting_lumcount += amount

	if(removing)
		lumcount_r -= col_r
		lumcount_g -= col_g
		lumcount_b -= col_b
	else
		lumcount_r += col_r
		lumcount_g += col_g
		lumcount_b += col_b

	if(affecting_lights && affecting_lights.len)
		var/r_avg = Clamp(round((lumcount_r / affecting_lights.len) * min(lighting_lumcount,LIGHTING_CAP) / LIGHTING_CAP), 0, 255)
		var/g_avg = Clamp(round((lumcount_g / affecting_lights.len) * min(lighting_lumcount,LIGHTING_CAP) / LIGHTING_CAP), 0, 255)
		var/b_avg = Clamp(round((lumcount_b / affecting_lights.len)* min(lighting_lumcount,LIGHTING_CAP) / LIGHTING_CAP), 0, 255)

		color_lighting_lumcount = round(max(r_avg, g_avg, b_avg)*0.5)

		l_color = rgb(r_avg, g_avg, b_avg)
	else
		l_color = null

	if(!lighting_changed)
		lighting_controller.changed_turfs += src
		lighting_changed = 1

/turf/space/update_lumcount(amount, col_r, col_g, col_b, removing = 0)
	lighting_lumcount += amount //Keep track in case the turf becomes a floor at some point, but don't process.


/turf/proc/init_lighting()
	var/area/A = loc
	if(!A.lighting_use_dynamic)
		lighting_changed = 0
		if(lighting_object)
			lighting_object.alpha = 0
			lighting_object = null
	else
		if(!lighting_object)
			lighting_object = new (src)
		redraw_lighting()

/turf/space/init_lighting()
	lighting_changed = 0
	if(lighting_object)
		lighting_object.alpha = 0
		lighting_object = null


/turf/proc/redraw_lighting()
	if(lighting_object)
		var/newalpha
		if(lighting_lumcount <= 0)
			newalpha = 255
		else
			lighting_object.luminosity = 1
			if(lighting_lumcount < LIGHTING_CAP)
				var/num = Clamp(lighting_lumcount * LIGHTING_CAP_FRAC, 0, 255)
				newalpha = 255-num
			else
				newalpha = 0

		if(color_lighting_lumcount)
			if(newalpha < color_lighting_lumcount)
				newalpha = color_lighting_lumcount

		if(l_color)
			lighting_object.color = l_color
		else
			lighting_object.color = "#000000"

		lighting_object.alpha = newalpha

	lighting_changed = 0
