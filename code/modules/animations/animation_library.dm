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
/proc/animation_wrist_flick(var/atom/A, direction = 1, loop_num = 0) //-1 for a left spin.
	animate(A, transform = turn(matrix(), 120 * direction), time = 1, loop = loop_num, easing = SINE_EASING | EASE_IN)
	animate(transform = turn(matrix(), 240 * direction), time = 1)
	animate(transform = null, time = 2, easing = SINE_EASING | EASE_OUT)

//Makes it look like the user threw something in the air (north) and then caught it.
/proc/animation_toss_snatch(var/atom/A)
	A.transform *= 0.75
	animate(A, alpha = 185, pixel_x = rand(-4,4), pixel_y = 18, pixel_z = 0, time = 3)
	animate(alpha = 185, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3)

//Combines the flick and the toss to have the item spin in the air.
/proc/animation_toss_flick(var/atom/A, direction = 1)
	A.transform *= 0.75
	animate(A, transform = turn(matrix(), 120 * direction), alpha = 185, pixel_x = rand(-4,4), pixel_y = 18, time = 3, easing = SINE_EASING | EASE_IN)
	animate(transform = turn(matrix(), 240 * direction), alpha = 185, pixel_x = 0, pixel_y = 0, time = 2)

//This does a fade out drop from a direction, like a hit of some kind.
/proc/animation_strike(var/atom/A, var/direction = 1)
	A.transform *= 0.75
	switch(direction)
		if(1)
			A.pixel_y += 18
		if(2)
			A.pixel_y -= 18
		if(4)
			A.pixel_x += 18
		if(8)
			A.pixel_x -= 18

	animate(A, alpha = 175, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3)

/proc/animation_flash_color(var/atom/A, var/flash_color = "#FF0000", var/speed = 3) //Flashes red on default.
	animate(A, color = flash_color, time = speed)
	animate(color = "#FFFFFF", time = speed)

/proc/animatation_displace_reset(var/atom/A, var/x_n = 2, var/y_n = 2, var/speed = 3)
	var/x_o = initial(A.pixel_x)
	var/y_o = initial(A.pixel_y)
	animate(A, pixel_x = x_o+rand(-x_n, x_n), pixel_y = y_o+rand(-y_n, y_n), time = speed, easing = ELASTIC_EASING | EASE_IN)
	animate(pixel_x = x_o, pixel_y = y_o, time = speed, easing = CIRCULAR_EASING | EASE_OUT)