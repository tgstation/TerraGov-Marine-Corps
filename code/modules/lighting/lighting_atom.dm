
// The proc you should always use to set the light of this atom.
// Nonesensical value for l_color default, so we can detect if it gets set to null.
#define NONSENSICAL_VALUE -99999
/atom/proc/set_light(l_range, l_power, l_color = NONSENSICAL_VALUE, mask_type = null)
	if(l_range > 0 && l_range < MINIMUM_USEFUL_LIGHT_RANGE)
		l_range = MINIMUM_USEFUL_LIGHT_RANGE	//Brings the range up to 1.4, which is just barely brighter than the soft lighting that surrounds players.

	if(l_power != null)
		light_power = l_power

	if(l_range != null)
		light_range = l_range
		light_on = (light_range>0) ? TRUE : FALSE

	if(l_color != NONSENSICAL_VALUE)
		light_color = l_color

	if(mask_type != null)
		light_mask_type = mask_type

	SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT, l_range, l_power, l_color)

	update_light()

/atom/proc/fade_light(new_colour, time)
	light_color = new_colour
	if(light?.our_mask)
		animate(light.our_mask, color = new_colour, time = time)

/// Will update the light (duh).Creates or destroys it if needed, makes it update values, makes sure it's got the correct source turf...
/atom/proc/update_light()
	set waitfor = FALSE

	if(QDELETED(src))
		return
	if(light_system == STATIC_LIGHT)
		static_update_light()
		return

	if((!light_power || !light_range) && light) // We won't emit light anyways, destroy the light source.
		QDEL_NULL(light)
		return
	if(light && light_mask_type && (light_mask_type != light.mask_type))
		QDEL_NULL(light)
	if(!light) // Update the light or create it if it does not exist.
		light = new /datum/dynamic_light_source(src, light_mask_type)
		return
	light.set_light(light_range, light_power, light_color)
	light.update_position()


/**
 * Updates the atom's opacity value.
 *
 * This exists to act as a hook for associated behavior.
 * It notifies (potentially) affected light sources so they can update (if needed).
 */
/atom/proc/set_opacity(new_opacity)
	if(new_opacity == opacity)
		return
	SEND_SIGNAL(src, COMSIG_ATOM_SET_OPACITY, new_opacity)
	. = opacity

	opacity = new_opacity

/atom/movable/set_opacity(new_opacity)
	. = ..()
	if(isnull(.) || !isturf(loc))
		return

	if(opacity)
		AddElement(/datum/element/light_blocking)
	else
		RemoveElement(/datum/element/light_blocking)


/turf/set_opacity(new_opacity)
	. = ..()
	if(isnull(.))
		return
	recalculate_directional_opacity()

/atom/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("light_range")
			if(light_system != MOVABLE_LIGHT)
				set_light(l_range = var_value)
			else
				set_light_range(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE

		if("light_power")
			if(light_system != MOVABLE_LIGHT)
				set_light(l_power = var_value)
			else
				set_light_power(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE

		if("light_color")
			if(light_system != MOVABLE_LIGHT)
				set_light(l_color = var_value)
			else
				set_light_color(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE
	return ..()


/atom/proc/flash_lighting_fx(
		_range = FLASH_LIGHT_RANGE,
		_power = FLASH_LIGHT_POWER,
		_color = LIGHT_COLOR_WHITE,
		_duration = FLASH_LIGHT_DURATION,
		_reset_lighting = TRUE,
		_flash_times = 1)
	new /obj/effect/light_flash(get_turf(src), _range, _power, _color, _duration, _flash_times)


/obj/effect/light_flash/Initialize(mapload, _range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = LIGHT_COLOR_WHITE, _duration = FLASH_LIGHT_DURATION, _flash_times = 1)
	light_range = _range
	light_power = _power
	light_color = _color
	. = ..()
	do_flashes(_flash_times, _duration)

/obj/effect/light_flash/proc/do_flashes(_flash_times, _duration)
	set waitfor = FALSE
	for(var/i in 1 to _flash_times)
		//Something bad happened
		if(!(light?.our_mask))
			break
		light.our_mask.alpha = 255
		animate(light.our_mask, time = _duration, easing = SINE_EASING, alpha = 0, flags = ANIMATION_END_NOW)
		sleep(_duration) //this is extremely short so it's ok to sleep
	qdel(src)

/atom/proc/set_light_range(new_range)
	if(new_range == light_range)
		return
	SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_RANGE, new_range)
	. = light_range
	light_range = new_range


/atom/proc/set_light_power(new_power)
	if(new_power == light_power)
		return
	SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_POWER, new_power)
	. = light_power
	light_power = new_power


/atom/proc/set_light_color(new_color)
	if(new_color == light_color)
		return
	SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_COLOR, new_color)
	. = light_color
	light_color = new_color


/atom/proc/set_light_on(new_value)
	if(new_value == light_on)
		return
	SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_ON, new_value)
	. = light_on
	light_on = new_value
