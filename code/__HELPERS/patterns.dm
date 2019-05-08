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