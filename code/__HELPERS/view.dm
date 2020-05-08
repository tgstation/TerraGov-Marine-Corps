/proc/getviewsize(view, offsetX, offsetY)
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

	viewX = CEILING(viewX * 0.5, 1)
	viewY = CEILING(viewY * 0.5, 1)
	var/viewXpos = viewX
	var/viewXneg = viewX
	var/viewYpos = viewY
	var/viewYneg = viewY
	if (offsetX)
		viewXpos += (offsetX/32)
		viewXneg -= (offsetX/32)
	if (offsetY)
		viewYpos += (offsetY/32)
		viewYneg -= (offsetY/32)

	return list(viewXneg, viewXpos, viewYneg, viewYpos)


/proc/in_view_range(mob/user, atom/A)
	var/list/view_range = getviewsize(user.client.view, user.client.pixel_x, user.client.pixel_y)
	var/turf/source = get_turf(user)
	var/turf/target = get_turf(A)
	return ISINRANGE(target.x, source.x - view_range[1], source.x + view_range[2]) && ISINRANGE(target.y, source.y - view_range[3], source.y + view_range[4])
