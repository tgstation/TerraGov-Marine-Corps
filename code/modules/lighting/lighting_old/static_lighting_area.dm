/area
	///Whether this area allows static lighting and thus loads the lighting objects
	var/static_lighting = TRUE

//Non legacy lighting areas.
//Any lighting area that wont support static legacy lights.
//These areas will not have corners generated.

/area/space
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = LIGHT_COLOR_WHITE
