// Simple Pipe
// The regular pipe you see everywhere, including bent ones.

/obj/machinery/atmospherics/pipe/simple
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "pipe11-2"

	name = "pipe"
	desc = "A one meter section of regular pipe."

	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	pipe_flags = PIPING_CARDINAL_AUTONORMALIZE

	device_type = BINARY

	construction_type = /obj/item/pipe/binary/bendable
	pipe_state = "simple"

/obj/machinery/atmospherics/pipe/simple/SetInitDirections()
	if(dir in GLOB.diagonals)
		initialize_directions = dir
		return
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/simple/update_icon()
	icon_state = "pipe[nodes[1] ? "1" : "0"][nodes[2] ? "1" : "0"]-[piping_layer]"
	if(pipe_vision_img)
		pipe_vision_img.icon_state = icon_state
	update_layer()
	update_alpha()
	var/turf/T = get_turf(src)
	if(level == 2 || (!T.intact_tile && !istype(T, /turf/open/floor/plating/plating_catwalk)))
		plane = GAME_PLANE
	else
		plane = FLOOR_PLANE
