///Estimates the light power based on the alpha of the light and the range.
///Assumes a linear fallout at (0, alpha/255) to (range, 0)
///Used for lightig mask lumcount calculations
#define LIGHT_POWER_ESTIMATION(alpha, range, distance) max((alpha * (range - distance)) / (255 * range), 0)

/turf
	///hybrid lights affecting this turf
	var/tmp/list/atom/movable/lighting_mask/hybrid_lights_affecting

/turf/Destroy(force)
	if(hybrid_lights_affecting)
		for(var/atom/movable/lighting_mask/mask AS in hybrid_lights_affecting)
			LAZYREMOVE(mask.affecting_turfs, src)
		hybrid_lights_affecting.Cut()
	return ..()

/// Causes any affecting light sources to be queued for a visibility update, for example a door got opened.
/turf/proc/reconsider_lights()
	//Consider static lights
	lighting_corner_NE?.vis_update()
	lighting_corner_SE?.vis_update()
	lighting_corner_SW?.vis_update()
	lighting_corner_NW?.vis_update()

	//consider dynamic lights
	for(var/atom/movable/lighting_mask/mask AS in hybrid_lights_affecting)
		mask.queue_mask_update()

// Used to get a scaled lumcount.
/turf/proc/get_lumcount(minlum = 0, maxlum = 1)
	var/totallums = 0
	if (static_lighting_object)
		var/datum/static_lighting_corner/L
		L = lighting_corner_NE
		if (L)
			totallums += L.lum_r + L.lum_b + L.lum_g
		L = lighting_corner_SE
		if (L)
			totallums += L.lum_r + L.lum_b + L.lum_g
		L = lighting_corner_SW
		if (L)
			totallums += L.lum_r + L.lum_b + L.lum_g
		L = lighting_corner_NW
		if (L)
			totallums += L.lum_r + L.lum_b + L.lum_g

		totallums /= 12 // 4 corners, each with 3 channels, get the average.

		totallums = (totallums - minlum) / (maxlum - minlum)

		totallums = CLAMP01(totallums)
	else
		totallums = 1

	for(var/atom/movable/lighting_mask/mask AS in hybrid_lights_affecting)
		if(mask.blend_mode == BLEND_ADD)
			totallums += LIGHT_POWER_ESTIMATION(mask.alpha, mask.radius, get_dist(src, get_turf(mask.attached_atom)))
		else
			totallums -= LIGHT_POWER_ESTIMATION(mask.alpha, mask.radius, get_dist(src, get_turf(mask.attached_atom)))
	return clamp(totallums, 0.0, 1.0)

///Proc to add movable sources of opacity on the turf and let it handle lighting code.
/turf/proc/add_opacity_source(atom/movable/new_source)
	LAZYADD(opacity_sources, new_source)
	if(opacity)
		return
	recalculate_directional_opacity()


///Proc to remove movable sources of opacity on the turf and let it handle lighting code.
/turf/proc/remove_opacity_source(atom/movable/old_source)
	LAZYREMOVE(opacity_sources, old_source)
	if(opacity) //Still opaque, no need to worry on updating.
		return
	recalculate_directional_opacity()


///Calculate on which directions this turfs block view.
/turf/proc/recalculate_directional_opacity()
	. = directional_opacity
	if(opacity)
		directional_opacity = ALL_CARDINALS
		if(. != directional_opacity)
			reconsider_lights()
		return
	directional_opacity = NONE
	for(var/atom/movable/opacity_source AS in opacity_sources)
		if(opacity_source.atom_flags & ON_BORDER)
			directional_opacity |= opacity_source.dir
		else //If fulltile and opaque, then the whole tile blocks view, no need to continue checking.
			directional_opacity = ALL_CARDINALS
			break
	if(. != directional_opacity && (. == ALL_CARDINALS || directional_opacity == ALL_CARDINALS))
		reconsider_lights() //The lighting system only cares whether the tile is fully concealed from all directions or not.

///Transfer the lighting of one area to another
/turf/proc/transfer_area_lighting(area/old_area, area/new_area)
	if(SSlighting.initialized)
		if (new_area.static_lighting != old_area.static_lighting)
			if (new_area.static_lighting)
				static_lighting_build_overlay()
			else
				static_lighting_clear_overlay()

	// We will only run this logic on turfs off the prime z layer
	// Since on the prime z layer, we use an overlay on the area instead, to save time
	if(SSmapping.z_level_to_plane_offset[z])
		var/index = SSmapping.z_level_to_plane_offset[z] + 1
		//Inherit overlay of new area
		if(old_area.lighting_effects)
			cut_overlay(old_area.lighting_effects[index])
		if(new_area.lighting_effects)
			add_overlay(new_area.lighting_effects[index])
/*
	// Manage removing/adding starlight overlays, we'll inherit from the area so we can drop it if the area has it already
	if(space_lit)
		if(!new_area.lighting_effects && old_area.lighting_effects)
			overlays += GLOB.starlight_overlays[GET_TURF_PLANE_OFFSET(src) + 1]
		else if (new_area.lighting_effects && !old_area.lighting_effects)
			overlays -= GLOB.starlight_overlays[GET_TURF_PLANE_OFFSET(src) + 1]
*/
