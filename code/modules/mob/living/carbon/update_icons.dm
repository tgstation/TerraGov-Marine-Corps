
/mob/living/carbon/proc/apply_overlay(cache_index)
	return

/mob/living/carbon/proc/remove_overlay(cache_index)
	return

/mob/living/carbon/proc/apply_temp_overlay(cache_index, var/duration)
	apply_overlay(cache_index)
	addtimer(CALLBACK(src, .remove_overlay, cache_index), duration)

/mob/living/carbon/proc/apply_underlay(cache_index)
	return

/mob/living/carbon/proc/remove_underlay(cache_index)
	return

///IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
/mob/living/carbon/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_pixel_y = pixel_y
	var/final_dir = dir
	var/changed = 0
	if(lying != lying_prev && rotate_on_lying)
		changed++
		ntransform.TurnTo(lying_prev,lying)
		if(lying == 0) //Lying to standing
			final_pixel_y = lying ? -6 : initial(pixel_y)
		else //if(lying != 0)
			if(lying_prev == 0) //Standing to lying
				pixel_y = lying ? -6 : initial(pixel_y)
				final_pixel_y = lying ? -6 : initial(pixel_y)
				if(dir & (EAST|WEST)) //Facing east or west
					final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass

	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2, pixel_y = final_pixel_y, dir = final_dir, easing = EASE_IN|EASE_OUT)