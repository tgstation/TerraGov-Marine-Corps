/turf
	var/tmp/lighting_corners_initialised = FALSE

	var/tmp/list/datum/static_light_source/static_affecting_lights       // List of light sources affecting this turf.
	var/tmp/list/datum/static_lighting_corner/static_lighting_corners

/turf/proc/static_lighting_clear_overlay()
	if (static_lighting_object)
		qdel(static_lighting_object, TRUE)

	var/datum/static_lighting_corner/C
	for (var/thing in static_lighting_corners)
		if(!thing)
			continue
		C = thing
		C.update_active()

/// Builds a lighting object for us, but only if our area is dynamic.
/turf/proc/static_lighting_build_overlay(area/A = loc)
	if(static_lighting_object)
		qdel(static_lighting_object, force=TRUE) //Shitty fix for lighting objects persisting after death

	if(!A.static_lighting && !static_light_sources)
		return

	if (!lighting_corners_initialised)
		static_generate_missing_corners()

	new/atom/movable/static_lighting_object(src)

	var/datum/static_lighting_corner/C
	var/datum/static_light_source/S
	for(var/thing in static_lighting_corners)
		if(!thing)
			continue
		C = thing
		if (!C.active) // We would activate the corner, calculate the lighting for it.
			for (thing in C.affecting)
				S = thing
				S.recalc_corner(C)
			C.active = TRUE

// Used to get a scaled lumcount.
/turf/proc/static_get_lumcount(minlum = 0, maxlum = 1)
	if (!static_lighting_object)
		return 0

	var/totallums = 0
	var/thing
	var/datum/static_lighting_corner/L
	for (thing in static_lighting_corners)
		if(!thing)
			continue
		L = thing
		totallums += L.lum_r + L.lum_b + L.lum_g

	totallums /= 12 // 4 corners, each with 3 channels, get the average.

	totallums = (totallums - minlum) / (maxlum - minlum)

	return CLAMP01(totallums)

// Returns a boolean whether the turf is on soft lighting.
// Soft lighting being the threshold at which point the overlay considers
// itself as too dark to allow sight and see_in_dark becomes useful.
// So basically if this returns true the tile is unlit black.
/turf/proc/static_is_softly_lit()
	if (!static_lighting_object)
		return FALSE

	return !static_lighting_object.luminosity

/turf/proc/change_area(area/old_area, area/new_area)
	if(SSlighting.initialized)
		if (new_area.static_lighting != old_area.static_lighting)
			if (new_area.static_lighting)
				static_lighting_build_overlay(new_area)
			else
				static_lighting_clear_overlay()
	//Inherit overlay of new area
	if(old_area.lighting_effect)
		cut_overlay(old_area.lighting_effect)
	if(new_area.lighting_effect)
		add_overlay(new_area.lighting_effect)

/turf/proc/static_get_corners()
	if (!lighting_corners_initialised)
		static_generate_missing_corners()
	if(opacity)
		return null // Since this proc gets used in a for loop, null won't be looped though.

	return static_lighting_corners

/turf/proc/static_generate_missing_corners()
	var/area/A = loc
	if(!A.static_lighting && !static_light_sources)
		return
	lighting_corners_initialised = TRUE
	if(!static_lighting_corners)
		static_lighting_corners = list(null, null, null, null)

	for(var/i = 1 to 4)
		if(static_lighting_corners[i]) // Already have a corner on this direction.
			continue

		static_lighting_corners[i] = new/datum/static_lighting_corner(src, GLOB.LIGHTING_CORNER_DIAGONAL[i])

