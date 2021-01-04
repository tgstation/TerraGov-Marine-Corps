//Andres-based again
/proc/filled_circle_turfs(atom/center, radius = 3)
	var/turf/center_turf = get_turf(center)
	if(radius < 0 || !center_turf)
		return
	if(radius == 0)
		return list(center_turf)

	var/x_0 = center_turf.x
	var/y_0 = center_turf.y
	var/z_0 = center_turf.z

	var/dx = 0
	var/dy = radius
	var/d = radius - 1

	//draw vertical diameter
	. = block(locate(x_0, y_0 - radius, z_0), locate(x_0, y_0 + radius, z_0))

	do
		//a step left/right, draw a vertical column
		if(d >= 2*dx)
			d -= 2*dx + 1;
			dx++;
			. += block(locate(x_0 + dx, y_0 - dy , z_0), locate(x_0 + dx, y_0 + dy, z_0))
			. += block(locate(x_0 - dx, y_0 - dy, z_0), locate(x_0 - dx, y_0 + dy, z_0))

		else if(d < 2*(radius-dy))
			//a step down/up, so draw by symmetry on the other axis
			d += 2*dy - 1;
			. += block(locate(x_0 + dy, y_0 - dx , z_0), locate(x_0 + dy, y_0 + dx, z_0))
			. += block(locate(x_0 - dy, y_0 - dx, z_0), locate(x_0 - dy, y_0 + dx, z_0))
			dy--;
		else
			//diagonal step, draw on both axis, checking for possible overlap
			d += 2*(dy-dx-1);
			dx++;
			. += block(locate(x_0 + dx, y_0 - dy + 1 , z_0), locate(x_0 + dx, y_0 + dy - 1, z_0))
			. += block(locate(x_0 - dx, y_0 - dy + 1, z_0), locate(x_0 - dx, y_0 + dy - 1, z_0))
			if(dy - 1 <  dx) //we're about to overlap, bail out
				break
			. += block(locate(x_0 + dy, y_0 - dx + 1 , z_0), locate(x_0 + dy, y_0 + dx - 1, z_0))
			. += block(locate(x_0 - dy, y_0 - dx + 1, z_0), locate(x_0 - dy, y_0 + dx - 1, z_0))
			dy--;
	while(dy > dx)


/proc/filled_turfs(atom/center, radius = 3, type = "circle", include_edge = TRUE)
	var/turf/center_turf = get_turf(center)
	if(radius < 0 || !center)
		return
	if(radius == 0)
		return list(center_turf)

	var/list/directions
	switch(type)
		if("square")
			directions = GLOB.alldirs
		if("circle")
			directions = GLOB.cardinals

	var/list/results = list(center_turf)
	var/list/turfs_to_check = list()
	turfs_to_check += center_turf
	for(var/i = radius; i > 0; i--)
		for(var/X in turfs_to_check)
			var/turf/T = X
			for(var/direction in directions)
				var/turf/AdjT = get_step(T, direction)
				if(!AdjT)
					continue
				if (AdjT in results) // Ignore existing turfs
					continue
				if(AdjT.density || LinkBlocked(T, AdjT) || TurfBlockedNonWindow(AdjT))
					if(include_edge)
						results += AdjT
					continue

				turfs_to_check += AdjT
				results += AdjT
	return results

///Generates a cone shape. Any other checks should be handled with the resulting list. Can work with up to 359 degrees
/proc/generate_cone(atom/center, outer_range = 10, inner_range = 1, cone_width = 60, cone_direction = 0, blocked = TRUE)
	var/right_angle = cone_direction + cone_width/2
	var/left_angle = cone_direction - cone_width/2

	//These are needed because degrees need to be from 0 to 359 for the checks to function
	if(right_angle >= 360)
		right_angle -= 360

	if(left_angle < 0)
		left_angle += 360

	var/list/turfs_to_check = list(get_turf(center))
	var/list/cone_turfs = list()
	for(var/r in 1 to outer_range)
		for(var/turf/C in turfs_to_check)
			for(var/direction in GLOB.cardinals)
				var/turf/T = get_step(C, direction)
				if(cone_turfs.Find(T))
					continue
				if(get_dist(center, T) > outer_range || get_dist(center, T) < inner_range)
					continue
				var/turf_angle = Get_Angle(center, T)
				if(right_angle > left_angle && (turf_angle > right_angle || turf_angle < left_angle))
					continue
				if(turf_angle > right_angle && turf_angle < left_angle)
					continue
				if(blocked)
					if(T.density || LinkBlocked(C, T) || TurfBlockedNonWindow(T))
						continue
				cone_turfs += T
				turfs_to_check += T
			turfs_to_check -= C
	return	cone_turfs
