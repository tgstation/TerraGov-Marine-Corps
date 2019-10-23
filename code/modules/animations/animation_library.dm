/*
Taking a hint from goon, I thought I'd start our own animation library. These are stock animations you can use for anything.
Just make sure to add animations that you make here so that they may be re-used. Please document how the animation
functions so that other people won't have to wonder what it actually does.
*/

/*
This is something like a gun spin, where the user spins it in the hand.
Instead of being uniform, it starts out a littler slower, goes fast in the middle, then slows down again.
4 ticks * 5 = 2.0 seconds. Doesn't loop on default, and spins right.
*/
/proc/animation_wrist_flick(atom/A, direction = 1, loop_num = 0) //-1 for a left spin.
	animate(A, transform = matrix(120 * direction, MATRIX_ROTATE), time = 1, loop = loop_num, easing = SINE_EASING|EASE_IN)
	animate(transform = matrix(240 * direction, MATRIX_ROTATE), time = 1)
	animate(transform = null, time = 2, easing = SINE_EASING|EASE_OUT)

//Makes it look like the user threw something in the air (north) and then caught it.
/proc/animation_toss_snatch(atom/A)
	A.transform *= 0.75
	animate(A, alpha = 185, pixel_x = rand(-4,4), pixel_y = 18, pixel_z = 0, time = 3)
	animate(pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3)

//Combines the flick and the toss to have the item spin in the air.
/proc/animation_toss_flick(atom/A, direction = 1)
	A.transform *= 0.75
	animate(A, transform = matrix(120 * direction, MATRIX_ROTATE), alpha = 185, pixel_x = rand(-4,4), pixel_y = 18, time = 3, easing = SINE_EASING|EASE_IN)
	animate(transform = matrix(240 * direction, MATRIX_ROTATE), pixel_x = 0, pixel_y = 0, time = 2)


//Flashes a color, then goes back to regular.
/proc/animation_flash_color(atom/A, flash_color = "#FF0000", speed = 3) //Flashes red on default.
	var/oldcolor = A.color
	animate(A, color = flash_color, time = speed)
	animate(color = oldcolor, time = speed)

//Gives it a spooky overlay and animation. Same as above, mostly, only adds a cool overlay effect.
/proc/animation_horror_flick(atom/A, flash_color = "#000000", speed = 4)
	animate(A, color = flash_color, time = speed)
	animate(color = "#FFFFFF", time = speed)
	var/image/I = image('icons/mob/mob.dmi',A,"spook")
	flick_overlay_view(I, A, 7)


/proc/animatation_displace_reset(atom/A, x_n = 2, y_n = 2, speed = 3)
	var/x_o = initial(A.pixel_x)
	var/y_o = initial(A.pixel_y)
	animate(A, pixel_x = x_o+rand(-x_n, x_n), pixel_y = y_o+rand(-y_n, y_n), time = speed, easing = ELASTIC_EASING|EASE_IN)
	animate(pixel_x = x_o, pixel_y = y_o, time = speed, easing = CIRCULAR_EASING|EASE_OUT)

//Basic megaman-like animation. No bells or whistles, but looks nice.
/proc/animation_teleport_quick_out(atom/A, speed = 10)
	animate(A, transform = matrix(0, 4, MATRIX_SCALE), alpha = 0, time = speed, easing = BACK_EASING)
	return speed

//We want to make sure to reset color here as it can be changed by other animations.
/proc/animation_teleport_quick_in(atom/A, speed = 10)
	A.transform = matrix(0, 4, MATRIX_SCALE)
	A.alpha = 0 //Start with transparency, just in case.
	animate(A, alpha = 255, transform = null, color = "#FFFFFF", time = speed, easing = BACK_EASING)

/*A magical teleport animation, for when the person is transported with some magic. Good for Halloween type events.
Can look good elsewhere as well.*/
/proc/animation_teleport_magic_out(atom/A, speed = 6)
	animate(A, transform = matrix(1.5, 0, MATRIX_SCALE), time = speed, easing = BACK_EASING)
	animate(transform = matrix(0, 4, MATRIX_SCALE) * matrix(0, 6, MATRIX_TRANSLATE), color = "#FFFF00", time = speed, alpha = 100, easing = BOUNCE_EASING|EASE_IN)
	animate(alpha = 0, time = speed)
	var/image/I = image('icons/effects/effects.dmi',A,"sparkle")
	flick_overlay_view(I, A, 9)
	return speed*3

/proc/animation_teleport_magic_in(atom/A, speed = 6)
	A.transform = matrix(0,3.5, MATRIX_SCALE)
	A.alpha = 0
	animate(A, alpha = 255, color = "#FFFF00", time = speed, easing = BACK_EASING)
	animate(transform = matrix(1.5, 0, MATRIX_SCALE), color = "#FFFFFF", time = speed, easing = CIRCULAR_EASING|EASE_OUT)
	animate(transform = null, time = speed-1)
	var/image/I = image('icons/effects/effects.dmi',A,"sparkle")
	flick_overlay_view(I, A, 10)

//A spooky teleport for evil dolls, horrors, and whatever else. Halloween type stuff.
/proc/animation_teleport_spooky_out(atom/A, speed = 6, sleep_duration = 0)
	animate(A, transform = matrix() * 1.5, color = "#551a8b", time = speed, easing = BACK_EASING)
	animate(transform = matrix() * 0.2, alpha = 100, color = "#000000", time = speed, easing = BACK_EASING)
	animate(alpha = 0, time = speed)
	var/image/I = image('icons/effects/effects.dmi',A,"spooky")
	flick_overlay_view(I, A, 9)
	return speed*3

/proc/animation_teleport_spooky_in(atom/A, speed = 4)
	A.transform *= 1.2
	A.alpha = 0
	animate(A, alpha = 255, color = "#551a8b", time = speed)
	animate(transform = null, color = "#FFFFFF", time = speed, easing = QUAD_EASING|EASE_OUT)
	var/image/I = image('icons/effects/effects.dmi',A,"spooky")
	flick_overlay_view(I, A, 10)

//Regular fadeout disappear, for most objects.
/proc/animation_destruction_fade(atom/A, speed = 12)
	A.flags_atom |= NOINTERACT
	A.mouse_opacity = 0 //We don't want them to click this while the animation is still playing.
	A.density = FALSE //So it doesn't block anything.
	var/i = 1 + (0.1 * rand(1,5))
	animate(A, transform = matrix() * i, color = "#808080", time = speed, easing = SINE_EASING)
	animate(alpha = 0, time = speed)
	return speed

//Fadeout when something gets hit. Not completely done yet, as offset doesn't want to cooperate.
proc/animation_destruction_knock_fade(atom/A, speed = 7, x_n = rand(10,18), y_n = rand(10,18))
	A.flags_atom |= NOINTERACT
	A.mouse_opacity = 0
	A.density = FALSE
	var/x_o = initial(A.pixel_x)
	var/y_o = initial(A.pixel_y)
	animate(A, transform = matrix() * 1.2,  alpha = 100, pixel_x = x_o + pick(x_n,-x_n), pixel_y = y_o + pick(y_n,-y_n), time = speed, easing = QUAD_EASING|EASE_IN)
	animate(transform = matrix(rand(45,90) * pick(1,-1), MATRIX_ROTATE), alpha = 0, time = speed, easing = SINE_EASING|EASE_OUT)
	return speed*2


/atom/proc/animation_spin(speed = 5, loop_amount = -1, clockwise = TRUE, sections = 3)
	if(!sections)
		return
	var/section = 360/sections
	if(!clockwise)
		section = -section
	var/list/matrix_list = list()
	for(var/i in 1 to sections-1)
		var/matrix/M = matrix(transform)
		M.Turn(section*i)
		matrix_list += M
	var/matrix/last = matrix(transform)
	matrix_list += last
	speed /= sections
	animate(src, transform = matrix_list[1], time = speed, loop_amount)
	for(var/i in 2 to sections)
		animate(transform = matrix_list[i], time = speed)
