/// Produces a mutable appearance glued to the [EMISSIVE_PLANE] dyed to be the [EMISSIVE_COLOR].
/proc/emissive_appearance(icon, icon_state = "", layer = FLOAT_LAYER, alpha = 255, appearance_flags = NONE)
	var/mutable_appearance/appearance = mutable_appearance(icon, icon_state, layer, EMISSIVE_PLANE, alpha, appearance_flags | EMISSIVE_APPEARANCE_FLAGS)
	if(alpha == 255)
		appearance.color = GLOB.emissive_color
	else
		var/alpha_ratio = alpha/255
		appearance.color = _EMISSIVE_COLOR(alpha_ratio)
	return appearance

/// Produces a mutable appearance glued to the [EMISSIVE_PLANE] dyed to be the [EM_BLOCK_COLOR].
/proc/emissive_blocker(icon, icon_state = "", layer = FLOAT_LAYER, alpha = 255, appearance_flags = NONE)
	var/mutable_appearance/appearance = mutable_appearance(icon, icon_state, layer, EMISSIVE_PLANE, alpha, appearance_flags | EMISSIVE_APPEARANCE_FLAGS)
	appearance.color = GLOB.em_block_color
	return appearance

///Modifies the lighting for a z_level
/proc/set_z_lighting(z_level_num, outside_colour = COLOR_WHITE, outside_lvl = 200, inside_colour = COLOR_WHITE, inside_lvl = 100, cave_colour = COLOR_WHITE, cave_lvl = 75, deep_cave_colour = COLOR_WHITE, deep_cave_lvl = 50)
	for(var/area/area_to_lit AS in SSmapping.areas_in_z["[z_level_num]"])
		switch(area_to_lit.ceiling)
			if(CEILING_NONE to CEILING_GLASS)
				area_to_lit.set_base_lighting(outside_colour, outside_lvl)
			if(CEILING_METAL to CEILING_OBSTRUCTED)
				area_to_lit.set_base_lighting(inside_colour, inside_lvl)
			if(CEILING_UNDERGROUND to CEILING_UNDERGROUND_METAL)
				area_to_lit.set_base_lighting(cave_colour, cave_lvl)
			if(CEILING_DEEP_UNDERGROUND to CEILING_DEEP_UNDERGROUND_METAL)
				area_to_lit.set_base_lighting(deep_cave_colour, deep_cave_lvl)
