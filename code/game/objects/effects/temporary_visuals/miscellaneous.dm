/obj/effect/temp_visual/telekinesis
	name = "telekinetic force"
	icon_state = "empdisable"
	duration = 0.5 SECONDS

//unsorted miscellaneous temporary visuals
/obj/effect/temp_visual/dir_setting/bloodsplatter
	icon = 'icons/effects/blood.dmi'
	duration = 0.5 SECONDS
	randomdir = FALSE
	layer = BELOW_MOB_LAYER
	var/splatter_type = "splatter"

/obj/effect/temp_visual/dir_setting/bloodsplatter/Initialize(mapload, set_dir, blood_color)
	if(!blood_color)
		CRASH("Tried to create a blood splatter without a blood_color")

	color = blood_color
	if(ISDIAGONALDIR(set_dir))
		icon_state = "[splatter_type][pick(1, 2, 6)]"
	else
		icon_state = "[splatter_type][pick(3, 4, 5)]"
	. = ..()
	var/target_pixel_x = 0
	var/target_pixel_y = 0
	switch(set_dir)
		if(NORTH)
			target_pixel_y = 16
		if(SOUTH)
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
		if(EAST)
			target_pixel_x = 16
		if(WEST)
			target_pixel_x = -16
		if(NORTHEAST)
			target_pixel_x = 16
			target_pixel_y = 16
		if(NORTHWEST)
			target_pixel_x = -16
			target_pixel_y = 16
		if(SOUTHEAST)
			target_pixel_x = 16
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
		if(SOUTHWEST)
			target_pixel_x = -16
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
	animate(src, pixel_x = target_pixel_x, pixel_y = target_pixel_y, alpha = 0, time = duration)
