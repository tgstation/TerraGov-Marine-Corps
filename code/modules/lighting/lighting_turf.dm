//Estimates the light power based on the alpha of the light and the range.
//Assumes a linear fallout at (0, alpha/255) to (range, 0)
#define LIGHT_POWER_ESTIMATION(alpha, range, distance) max((alpha * (range - distance)) / (255 * range), 0)

/turf
	var/tmp/list/atom/movable/lighting_mask/lights_affecting

/turf/Destroy(force)
	if(lights_affecting)
		for(var/atom/movable/lighting_mask/mask AS in lights_affecting)
			LAZYREMOVE(mask.affecting_turfs, src)
		lights_affecting.Cut()
	return ..()

/// Causes any affecting light sources to be queued for a visibility update, for example a door got opened.
/turf/proc/reconsider_lights()
	//Consider static lights
	for(var/datum/static_light_source/light AS in legacy_affecting_lights)
		light.vis_update()

	//consider dynamic lights
	for(var/atom/movable/lighting_mask/mask AS in lights_affecting)
		mask.calculate_lighting_shadows()

// Used to get a scaled lumcount. //tivi todo
/turf/proc/get_lumcount()
	var/lums = legacy_get_lumcount()
	for(var/atom/movable/lighting_mask/mask AS in lights_affecting)
		if(mask.blend_mode == BLEND_ADD)
			lums += LIGHT_POWER_ESTIMATION(mask.alpha, mask.radius, get_dist(src, get_turf(mask.attached_atom)))
		else
			lums -= LIGHT_POWER_ESTIMATION(mask.alpha, mask.radius, get_dist(src, get_turf(mask.attached_atom)))
	return clamp(lums, 0.0, 1.0)

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
		if(opacity_source.flags_atom & ON_BORDER)
			directional_opacity |= opacity_source.dir
		else //If fulltile and opaque, then the whole tile blocks view, no need to continue checking.
			directional_opacity = ALL_CARDINALS
			break
	if(. != directional_opacity && (. == ALL_CARDINALS || directional_opacity == ALL_CARDINALS))
		reconsider_lights() //The lighting system only cares whether the tile is fully concealed from all directions or not.
