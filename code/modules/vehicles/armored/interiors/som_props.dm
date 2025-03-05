/obj/structure/prop/som_tank/computer
	icon = 'icons/obj/armored/3x4/som_interior_props.dmi'
	icon_state = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	allow_pass_flags = PASSABLE|PASS_LOW_STRUCTURE
	density = TRUE
	light_range = 1
	light_power = 0.5
	light_color = LIGHT_COLOR_EMISSIVE_GREEN

/obj/structure/prop/som_tank/computer/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)
	set_light(initial(light_range))

/obj/structure/prop/som_tank/computer/update_overlays()
	. = ..()
	if(icon_state)
		. += emissive_appearance(icon, "[icon_state]_emissive", src)

/obj/structure/prop/som_tank/computer/gunner_console
	icon_state = "gunner_console"
	pixel_y = -32

/obj/structure/prop/som_tank/computer/front_left
	icon_state = "driver_left"
	pixel_y = -42

/obj/structure/prop/som_tank/computer/front_center
	icon_state = "driver_center"
	pixel_x = 4
	pixel_y = -74

/obj/structure/prop/som_tank/computer/front_right
	icon_state = "driver_right"
	pixel_x = -4
	pixel_y = -42

/obj/structure/prop/som_tank/computer/floating
	icon = 'icons/obj/armored/3x4/som_interior_small_props.dmi'
	icon_state = "computer_overhead"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER
	pixel_x = -11
	pixel_y = -1

/obj/structure/prop/som_tank/computer/floating/alt
	icon_state = "computer_overhead_alt"
	pixel_x = 9
	pixel_y = 3
