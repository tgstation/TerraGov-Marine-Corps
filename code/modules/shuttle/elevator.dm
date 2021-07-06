/obj/docking_port/stationary/heisennaught_elevator
	name = "elevator zone"
	id = "elevator"
	dir = SOUTH
	dwidth = 1
	dheight = 1
	width = 3
	height = 1

/obj/machinery/computer/shuttle/heisennaught_elevator
	name = "elevator computer"
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	possible_destinations = "down;up"

/obj/docking_port/stationary/heisennaught_elevator/up
	id = "up"

/obj/docking_port/stationary/heisennaught_elevator/down
	id = "down"
	roundstart_template = /datum/map_template/shuttle/heisennaught_elevator