
/mob/living/carbon/proc/apply_overlay(cache_index)
	return

/mob/living/carbon/proc/remove_overlay(cache_index)
	return

/mob/living/carbon/proc/apply_temp_overlay(cache_index, duration)
	apply_overlay(cache_index)
	addtimer(CALLBACK(src, .proc/remove_overlay, cache_index), duration)

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
	if(lying_angle != lying_prev && rotate_on_lying)
		changed++
		ntransform.TurnTo(lying_prev, lying_angle)
		if(!lying_angle) //Lying to standing
			final_pixel_y = lying_angle ? -6 : initial(pixel_y)
		else //if(lying_angle != 0)
			if(lying_prev == 0) //Standing to lying down
				pixel_y = lying_angle ? -6 : initial(pixel_y)
				final_pixel_y = lying_angle ? -6 : initial(pixel_y)
				if(dir & (EAST|WEST)) //Facing east or west
					final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass

	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = (lying_prev == 0 || lying_angle == 0) ? 0.2 SECONDS : 0, pixel_y = final_pixel_y, dir = final_dir, easing = (EASE_IN|EASE_OUT))
