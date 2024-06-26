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

/turf/proc/static_generate_missing_corners()
	if (!lighting_corner_NE)
		lighting_corner_NE = new/datum/static_lighting_corner(src, NORTH|EAST)

	if (!lighting_corner_SE)
		lighting_corner_SE = new/datum/static_lighting_corner(src, SOUTH|EAST)

	if (!lighting_corner_SW)
		lighting_corner_SW = new/datum/static_lighting_corner(src, SOUTH|WEST)

	if (!lighting_corner_NW)
		lighting_corner_NW = new/datum/static_lighting_corner(src, NORTH|WEST)

	lighting_corners_initialised = TRUE

