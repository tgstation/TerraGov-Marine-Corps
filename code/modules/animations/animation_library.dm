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