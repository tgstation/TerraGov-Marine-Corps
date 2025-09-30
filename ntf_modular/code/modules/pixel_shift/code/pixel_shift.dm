//PORTED FROM SKYRAT #870 AND #15175
#define MAXIMUM_PIXEL_SHIFT 16
#define PASSABLE_SHIFT_THRESHOLD 8

/mob
/// Whether the mob is pixel shifted or not
	var/is_shifted = FALSE
	/// If we are in the shifting setting.
	var/shifting = FALSE

	/// Takes the four cardinal direction defines. Any atoms moving into this atom's tile will be allowed to from the added directions.
	var/passthroughable = FALSE

/datum/keybinding/mob/pixel_shift
	hotkey_keys = list("V")
	name = "pixel_shift"
	full_name = "Pixel Shift"
	description = "Shift your characters offset."
	category = CATEGORY_MOVEMENT
	keybind_signal = COMSIG_KB_MOB_PIXELSHIFT

/datum/keybinding/mob/pixel_shift/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.shifting = TRUE
	return TRUE

/datum/keybinding/mob/pixel_shift/up(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.shifting = FALSE
	return TRUE

/mob/proc/unpixel_shift()
	return

/mob/living/unpixel_shift()
	. = ..()
	passthroughable = FALSE
	if(is_shifted)
		is_shifted = FALSE
		pixel_x = initial(pixel_x)
		pixel_y = initial(pixel_y)

/mob/proc/pixel_shift(direction)
	return

/mob/living/set_pull_offsets(mob/living/pull_target, grab_state)
	pull_target.unpixel_shift()
	return ..()

/mob/living/reset_pull_offsets(mob/living/pull_target, override)
	pull_target.unpixel_shift()
	return ..()

/mob/living/pixel_shift(direction)
	passthroughable = FALSE
	switch(direction)
		if(NORTH)
			if(!canface())
				return FALSE
			if(pixel_y <= MAXIMUM_PIXEL_SHIFT + initial(pixel_y))
				pixel_y++
				is_shifted = TRUE
		if(EAST)
			if(!canface())
				return FALSE
			if(pixel_x <= MAXIMUM_PIXEL_SHIFT + initial(pixel_x))
				pixel_x++
				is_shifted = TRUE
		if(SOUTH)
			if(!canface())
				return FALSE
			if(pixel_y >= -MAXIMUM_PIXEL_SHIFT + initial(pixel_y))
				pixel_y--
				is_shifted = TRUE
		if(WEST)
			if(!canface())
				return FALSE
			if(pixel_x >= -MAXIMUM_PIXEL_SHIFT + initial(pixel_x))
				pixel_x--
				is_shifted = TRUE

	// Yes, I know this lets players pass through in every direction if they've shifted above the threshold.
	// I couldn't get it to work properly, sorry.
	if(pixel_y > PASSABLE_SHIFT_THRESHOLD)
		passthroughable = TRUE
	if(pixel_x > PASSABLE_SHIFT_THRESHOLD)
		passthroughable = TRUE
	if(pixel_y < -PASSABLE_SHIFT_THRESHOLD)
		passthroughable = TRUE
	if(pixel_x < -PASSABLE_SHIFT_THRESHOLD)
		passthroughable = TRUE

/mob/living/CanAllowThrough(atom/movable/mover, border_dir)
	// Make sure to not allow projectiles of any kind past where they normally wouldn't.
	if(!istype(mover, /atom/movable/projectile) && !mover.throwing && passthroughable)
		return TRUE
	return ..()

#undef MAXIMUM_PIXEL_SHIFT
#undef PASSABLE_SHIFT_THRESHOLD
