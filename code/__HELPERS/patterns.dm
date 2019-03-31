//common figures with reasonably fast drawing methods

/proc/diamond_turfs(atom/center, radius)
	var/turf/center_turf = get_turf(center)
	if(radius < 0 || !center_turf)
		return

	if(radius == 0)
		return list(center_turf)

	var/x_0 = center_turf.x
	var/y_0 = center_turf.y
	var/z_0 = center_turf.z
	var/dx = 0

	. = list(locate(x_0 + radius, y_0, z_0),
			 locate(x_0 - radius, y_0, z_0),
			 locate(x_0, y_0 + radius, z_0),
			 locate(x_0, y_0 - radius, z_0))

	for(var/dy=radius-1 ; dy > 0 ; dy--)
		dx++
		. += locate(x_0 + dx, y_0 + dy, z_0)
		. += locate(x_0 + dx, y_0 - dy, z_0)
		. += locate(x_0 - dx, y_0 + dy, z_0)
		. += locate(x_0 - dx, y_0 - dy, z_0)

/proc/filled_diamond_turfs(atom/center, radius)
	var/turf/center_turf = get_turf(center)
	if(radius < 0 || !center_turf)
		return

	if(radius == 0)
		return list(center_turf)

	var/x_0 = center_turf.x
	var/y_0 = center_turf.y
	var/z_0 = center_turf.z
	var/dx = 0

	. = list(locate(x_0 + radius, y_0, z_0), locate(x_0 - radius, y_0, z_0))
	. += block(locate(x_0, y_0 - radius, z_0), locate(x_0, y_0 + radius, z_0))

	for(var/dy=radius-1 ; dy > 0 ; dy--)
		dx++
		. += block(locate(x_0 + dx, y_0 - dy, z_0), locate(x_0 + dx, y_0 + dy, z_0))
		. += block(locate(x_0 - dx, y_0 - dy, z_0), locate(x_0 - dx, y_0 + dy, z_0))

#define ANDRES_NEXT_STEP \
		if(d >= 2*dx) \
			{ \
			d -= 2*dx + 1; \
			dx++; \
			} \
		else if(d < 2*(radius-dy)) \
			{ \
			d += 2*dy - 1; \
			dy--; \
			} \
		else \
			{ \
			d += 2*(dy-dx-1); \
			dy--; \
			dx++; \
			}

//Andres algorithm for plane filling circles, adapted for non-overlapping turfs
/proc/circle_turfs(atom/center, radius=3)
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

	//get rid of the four cardinal that would otherwise overlap
	. = list(locate(x_0 + radius, y_0, z_0), \
			 locate(x_0 - radius, y_0, z_0), \
			 locate(x_0, y_0 + radius, z_0), \
			 locate(x_0, y_0 - radius, z_0))

	ANDRES_NEXT_STEP

	while(dy > dx)
		. += locate(x_0 + dx, y_0 + dy, z_0)
		. += locate(x_0 - dx, y_0 - dy, z_0)
		. += locate(x_0 - dy, y_0 + dx, z_0)
		. += locate(x_0 + dy, y_0 - dx, z_0)
		. += locate(x_0 - dy, y_0 - dx, z_0)
		. += locate(x_0 + dx, y_0 - dy, z_0)
		. += locate(x_0 - dx, y_0 + dy, z_0)
		. += locate(x_0 + dy, y_0 + dx, z_0)

		ANDRES_NEXT_STEP

	//last turfs are on diagonals, don't duplicate them
	if(dx == dy)
		. += locate(x_0 + dx, y_0 + dy, z_0)
		. += locate(x_0 + dx, y_0 - dy, z_0)
		. += locate(x_0 - dx, y_0 + dy, z_0)
		. += locate(x_0 - dx, y_0 - dy, z_0)

#undef ANDRES_NEXT_STEP

//Andres-based again
/proc/filled_circle_turfs(atom/center, radius=3)
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
