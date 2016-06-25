/*
Taking a hint from goon, I thought I'd start our own animation library. These are stock animations you can use for anything.
Just make sure to add animations that you make here so that they may be re-used. Please document how the animation
functions so that other people won't have to wonder what it actually does.
*/

//This animation spins the icon left or right, and can be used for anything.
//Change the looping number for a repeat of the animation. 1 for two loops.
/proc/animation_spin(var/atom/A, var/direction = "left", var/time = 1, var/looping = -1)
	if (!istype(A))
		return

	var/matrix/M = A.transform
	var/turn = -90
	if (direction != "left")
		turn = 90

	animate(A, transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = time, loop = looping)
	animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = time, loop = looping)
	animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = time, loop = looping)
	animate(transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = time, loop = looping)
	return

/proc/animation_flick(var/atom/A, var/direction = 1)
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

/proc/animation_flick_spin(var/atom/A, var/direction = 1, var/turn = 360, var/looping = 0)
	var/matrix/M = A.transform
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

	animate(A, transform = matrix(M, turn, MATRIX_ROTATE | MATRIX_MODIFY), time = 3, loop = looping)
	animate(A, alpha = 175, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3)

/proc/animate_float(var/atom/A, var/loopnum = -1, floatspeed = 20, random_side = 1)
	if (!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = 1
	if(random_side) side = pick(-1, 1)

	spawn(rand(1,10))
		animate(A, pixel_y = 32, transform = matrix(floatdegrees * (side == 1 ? 1:-1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)
		animate(pixel_y = 0, transform = matrix(floatdegrees * (side == 1 ? -1:1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)
	return

/proc/animate_levitate(var/atom/A, var/loopnum = -1, floatspeed = 20, random_side = 1)
	if (!istype(A))
		return
	var/floatdegrees = rand(5, 20)
	var/side = 1
	if(random_side) side = pick(-1, 1)

	spawn(rand(1,10))
		animate(A, pixel_y = 8, transform = matrix(floatdegrees * (side == 1 ? 1:-1), MATRIX_ROTATE), time = floatspeed, loop = loopnum, easing = SINE_EASING)
		animate(pixel_y = 0, transform = null, time = floatspeed, loop = loopnum, easing = SINE_EASING)
	return

/proc/animate_fading_leap_up(var/atom/A)
	if (!istype(A))
		return
	var/matrix/M = matrix()
	var/do_loops = 15
	while (do_loops > 0)
		do_loops--
		animate(A, transform = M, pixel_z = A.pixel_z + 12, alpha = A.alpha - 17, time = 1, loop = 1, easing = LINEAR_EASING)
		M.Scale(1.2,1.2)
		sleep(1)
	A.alpha = 0

/proc/animate_fading_leap_down(var/atom/A)
	if (!istype(A))
		return
	var/matrix/M = matrix()
	var/do_loops = 15
	M.Scale(18,18)
	while (do_loops > 0)
		do_loops--
		animate(A, transform = M, pixel_z = A.pixel_z - 12, alpha = A.alpha + 17, time = 1, loop = 1, easing = LINEAR_EASING)
		M.Scale(0.8,0.8)
		sleep(1)
	animate(A, transform = M, pixel_z = 0, alpha = 255, time = 1, loop = 1, easing = LINEAR_EASING)