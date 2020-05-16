/proc/getviewsize(view)
	var/viewX
	var/viewY
	if(isnum(view))
		var/totalviewrange = 1 + 2 * view
		viewX = totalviewrange
		viewY = totalviewrange
	else
		var/list/viewrangelist = splittext(view,"x")
		viewX = text2num(viewrangelist[1])
		viewY = text2num(viewrangelist[2])
	return list(viewX, viewY)


/proc/in_view_range(mob/user, atom/A)
	var/list/view_range = getviewsize(user.client.view)
	var/turf/source = get_turf(user)
	var/turf/target = get_turf(A)
	var/view_x = round(view_range[1] * 0.5)
	var/view_y = round(view_range[2] * 0.5)
	var/x_offset = round(user.client.pixel_x / 32)
	var/y_offset = round(user.client.pixel_y / 32)
	return ISINRANGE(target.x, source.x - view_x + x_offset, source.x + view_x + x_offset) && ISINRANGE(target.y, source.y - view_y + y_offset, source.y + view_y + y_offset)
