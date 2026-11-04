/**
 * Checks whether the target turf is in a valid state to accept a directional construction
 * such as windows or railings.
 *
 * Returns FALSE if the target turf cannot accept a directional construction.
 * Returns TRUE otherwise.
 *
 * Arguments:
 * * dest_turf - The destination turf to check for existing directional constructions
 * * test_dir - The prospective dir of some atom you'd like to put on this turf.
 * * is_fulltile - Whether the thing you're attempting to move to this turf takes up the entire tile or whether it supports multiple movable atoms on its tile.
 */
/proc/valid_build_direction(turf/dest_turf, test_dir, is_fulltile = FALSE)
	if(!dest_turf)
		return FALSE
	for(var/obj/turf_content in dest_turf)
		if(turf_content.obj_flags & BLOCKS_CONSTRUCTION_DIR)
			if(is_fulltile)  // for making it so fulltile things can't be built over directional things--a special case
				return FALSE
			if(turf_content.dir == test_dir)
				return FALSE
	return TRUE

/**
 * Converts mouse-pos control coordinates to a specific turf location on the map.
 *
 * Handles the conversion between control-space mouse coordinates and screen-space map coordinates,
 * accounting for various BYOND quirks and display scaling factors.
 *
 * @param mousepos_x	The x-coordinate of the mouse click (in control pixels, top-left origin)
 * @param mousepos_y	The y-coordinate of the mouse click (in control pixels, top-left origin)
 * @param sizex			x control width of the map
 * @param sizey			y control width of the map
 * @param viewing_client The client whose view perspective to use for the conversion
 *
 * @return The turf at the calculated map position, or the closest one if out of bounds, as well as the residual x and y map offsets
 *
 * Important Notes:
 * - This WILL be incorrect when client pixel_wxyz is animating, and it WILL be incorrect if the user is gliding, because we don't have a good way to compensate this on the serverside. Yay!!!
 * - Mouse coordinates originate from the top-left corner because we can't have consistency in this engine
 * - Coordinate systems are inconsistent between control pixels and screen pixels
 * - Something on the byond side (icon size likely? needs debugging) affects the control pixels
 * - This uses the ratios between them rather than absolute values for reliable results
 * - For absolute value comparisons, dividing by 2 may work as a temporary hack,
 *   but using ratios (as implemented in the proc) is the recommended approach
 */
/proc/get_loc_from_mousepos(mousepos_x, mousepos_y, sizex, sizey, client/viewing_client)
	if(sizex == 0 || sizey == 0) //contexts where this information is not availible should return 0 in size, aka tgui passthrough
		return list(null, 0, 0)
	var/turf/baseloc = get_turf(viewing_client.eye)
	var/list/actual_view = getviewsize(viewing_client ? viewing_client.view : world.view)

	var/screen_width = actual_view[1] * ICON_SIZE_X
	var/screen_height = actual_view[2] * ICON_SIZE_Y

	//handle letterboxing to get the right sizes and mouseposes
	var/size_ratio = sizex/sizey
	var/screen_ratio = screen_width/screen_height
	if(size_ratio < screen_ratio) //sizex too high, y has black banners
		var/effective_height = sizex / screen_ratio
		var/banner_height = (sizey - effective_height) / 2
		mousepos_y -= banner_height
		sizey -= (banner_height*2)
	else if (size_ratio > screen_ratio) //sizey too high, x has black banners
		var/effective_width = sizey * screen_ratio
		var/banner_width = (sizex - effective_width) / 2
		mousepos_x -= banner_width
		sizex -= (banner_width*2)

	// if its a black banner, just assume we clicked the turf
	mousepos_x = max(mousepos_x, 0)
	mousepos_y = max(mousepos_y, 0)

	//fix ratios being off due to screen width/height
	var/x_ratio = sizex/screen_width
	var/y_ratio = sizey/screen_height
	mousepos_x /= x_ratio
	mousepos_y /= y_ratio

	//relative to bottom left corner of turf in the middle of the screen
	var/relative_x = mousepos_x - (screen_width / 2) + (ICON_SIZE_X/2) + viewing_client.pixel_x + viewing_client.pixel_w
	var/relative_y = -(mousepos_y - (screen_height / 2))+ (ICON_SIZE_Y/2) - 1 + viewing_client.pixel_y + viewing_client.pixel_z
	var/turf_x_diff = FLOOR(relative_x / ICON_SIZE_X, 1)
	var/turf_y_diff = FLOOR(relative_y / ICON_SIZE_Y, 1)

	var/click_turf_x = baseloc.x + turf_x_diff
	var/click_turf_y = baseloc.y + turf_y_diff
	var/click_turf_z = baseloc.z

	var/turf/click_turf = locate(clamp(click_turf_x, 1, world.maxx), clamp(click_turf_y, 1, world.maxy), click_turf_z)

	var/x_residual = relative_x % ICON_SIZE_X
	var/y_residual = relative_y % ICON_SIZE_Y
	return list(click_turf, x_residual, y_residual)
