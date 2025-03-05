/turf
	var/tmp/lighting_corners_initialised = FALSE
	var/tmp/datum/static_lighting_object/static_lighting_object

	///Lighting Corner datums.
	var/tmp/datum/static_lighting_corner/lighting_corner_NE
	var/tmp/datum/static_lighting_corner/lighting_corner_SE
	var/tmp/datum/static_lighting_corner/lighting_corner_SW
	var/tmp/datum/static_lighting_corner/lighting_corner_NW

/turf/proc/static_lighting_clear_overlay()
	if (static_lighting_object)
		qdel(static_lighting_object, TRUE)

/// Builds a lighting object for us, but only if our area is dynamic.
/turf/proc/static_lighting_build_overlay(area/our_area = loc)
	if(static_lighting_object)
		qdel(static_lighting_object, force=TRUE) //Shitty fix for lighting objects persisting after death

	new/datum/static_lighting_object(src)



// Returns a boolean whether the turf is on soft lighting.
// Soft lighting being the threshold at which point the overlay considers
// itself as too dark to allow sight and see_in_dark becomes useful.
// So basically if this returns true the tile is unlit black.
/turf/proc/static_is_softly_lit()
	if (!static_lighting_object)
		return FALSE

	return !(luminosity || dynamic_lumcount)

/turf/proc/change_area(area/old_area, area/new_area)
	LISTASSERTLEN(old_area.turfs_to_uncontain_by_zlevel, z, list())
	LISTASSERTLEN(new_area.turfs_by_zlevel, z, list())
	old_area.turfs_to_uncontain_by_zlevel[z] += src
	new_area.turfs_by_zlevel[z] += src
	new_area.contents += src
	if(SSlighting.initialized)
		if (new_area.static_lighting != old_area.static_lighting)
			if (new_area.static_lighting)
				static_lighting_build_overlay(new_area)
			else
				static_lighting_clear_overlay()

	//changes to make after turf has moved
	on_change_area(old_area, new_area)

/// Allows for reactions to an area change without inherently requiring change_area() be called (I hate maploading)
/turf/proc/on_change_area(area/old_area, area/new_area)
	transfer_area_lighting(old_area, new_area)
