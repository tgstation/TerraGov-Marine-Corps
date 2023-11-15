/obj/machinery/computer/som
	name = "\improper SOM computer"
	desc = "A fancy touch screen computer terminal."
	density = TRUE
	icon_state = "som_computer"
	screen_overlay = "som_computer_emissive"
	light_color = LIGHT_COLOR_FLARE
	layer = ABOVE_MOB_LAYER

/obj/machinery/computer/som/Initialize(mapload)
	. = ..()
	if(dir == SOUTH || dir == NORTH)
		pixel_y = 10

/obj/machinery/computer/som/update_icon_state()
	if(machine_stat & (BROKEN|DISABLED))
		icon_state = "[initial(icon_state)]_broken"
	else if(machine_stat & NOPOWER)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_on"

/obj/machinery/computer/som_two
	name = "\improper SOM console"
	desc = "A computer console of some description."
	density = TRUE
	icon_state = "som_console"
	screen_overlay = "som_console_screen"
	light_color = LIGHT_COLOR_FLARE
