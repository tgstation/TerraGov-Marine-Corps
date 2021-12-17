//This is intended to be a full wrapper. DO NOT directly modify its values
///Container for client viewsize
/datum/view_data
	///width ratio of the owneing clients view
	var/width = 0
	///height ratio of the owneing clients view
	var/height = 0
	///Default view size, formatted as a string
	var/default = ""

	///Bool that determines whether we want it to ignore any other changes after we applied some changes
	var/supress_changes = FALSE
	///the owner of this view data
	var/client/chief = null

/datum/view_data/New(client/owner, view_string)
	default = view_string
	chief = owner
	apply()

///sets the default view size froma  string
/datum/view_data/proc/set_default(string)
	default = string
	apply()

///Updates formatting while considering zoom
/datum/view_data/proc/safe_apply_formatting()
	if(is_zooming())
		assert_format()
		return
	update_pixel_format()

///Resets the format type
/datum/view_data/proc/assert_format()
	winset(chief, "mapwindow.map", "zoom=0")

///applies the current clients preferred pixel size setting
/datum/view_data/proc/update_pixel_format()
	winset(chief, "mapwindow.map", "zoom=[chief.prefs.pixel_size]")

///applies the preferred clients scaling method
/datum/view_data/proc/update_zoom_mode()
	winset(chief, "mapwindow.map", "zoom-mode=[chief.prefs.scaling_method]")

///Returns a boolean if the client has any form of zoom
/datum/view_data/proc/is_zooming()
	return (width || height)

///Resets the zoom to the default string
/datum/view_data/proc/reset_to_default()
	width = 0
	height = 0
	apply()

///adds the number inputted to the zoom and applies it
/datum/view_data/proc/add(num_to_add)
	width += num_to_add
	height += num_to_add
	apply()

///adds the size, which can also be a string, to the default and applies it
/datum/view_data/proc/add_size(toAdd)
	var/list/new_size = getviewsize(toAdd)
	width += new_size[1]
	height += new_size[2]
	apply()

///INCREASES the view radius by this.
/datum/view_data/proc/set_view_radius_to(toAdd)
	var/list/new_size = getviewsize(toAdd)  //Backward compatability to account
	width = new_size[1] //for a change in how sizes get calculated. we used to include world.view in
	height = new_size[2] //this, but it was jank, so I had to move it
	apply()

///sets width and height as numbers
/datum/view_data/proc/set_width_and_height(new_width, new_height)
	width = new_width
	height = new_height
	apply()

///sets the width of the view
/datum/view_data/proc/set_width(new_width)
	width = new_width
	apply()

///sets the height of the view
/datum/view_data/proc/set_height(new_height)
	height = new_height
	apply()

///adds the inputted width to the view
/datum/view_data/proc/add_to_width(width_to_add)
	width += width_to_add
	apply()

///adds the inputted height to the view
/datum/view_data/proc/add_to_height(height_to_add)
	height += height_to_add
	apply()

///applies all current outstanding changes to the client
/datum/view_data/proc/apply()
	chief.change_view(get_client_view_size())
	safe_apply_formatting()

///supresses any further view changes until it is unsupressed
/datum/view_data/proc/supress()
	supress_changes = TRUE
	apply()

///unsupresses to allow further view changes
/datum/view_data/proc/unsupress()
	supress_changes = FALSE
	apply()

///returns the client view size in string format
/datum/view_data/proc/get_client_view_size()
	var/list/temp = getviewsize(default)
	if(supress_changes)
		return "[temp[1]]x[temp[2]]"
	return "[width + temp[1]]x[height + temp[2]]"

///Zooms the client back in with an animate pretty simple
/datum/view_data/proc/zoom_in()
	reset_to_default()
	animate(chief, pixel_x = 0, pixel_y = 0, 0, FALSE, LINEAR_EASING, ANIMATION_END_NOW)

///zooms out the client with a given radius and offset as well as a direction
/datum/view_data/proc/zoom_out(radius = 0, offset = 0, direction = NONE)
	if(direction)
		var/_x = 0
		var/_y = 0
		switch(direction)
			if(NORTH)
				_y = offset
			if(EAST)
				_x = offset
			if(SOUTH)
				_y = -offset
			if(WEST)
				_x = -offset
		animate(chief, pixel_x = world.icon_size*_x, pixel_y = world.icon_size*_y, 0, FALSE, LINEAR_EASING, ANIMATION_END_NOW)

	set_view_radius_to(radius)

///gets the current screen size as defined in config
/proc/get_screen_size(widescreen)
	if(widescreen)
		return CONFIG_GET(string/default_view)
	return CONFIG_GET(string/default_view_square)
