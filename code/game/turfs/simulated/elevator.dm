// Elevator floors
/turf/simulated/shuttle/floor/elevator
	icon = 'icons/turf/elevator.dmi'
	icon_state = "floor"

/turf/simulated/shuttle/floor/elevator/grating
	icon_state = "floor_grating"

// Elevator walls (directional)
/turf/simulated/shuttle/wall/elevator
	icon = 'icons/turf/elevator.dmi'
	icon_state = "wall"

// Wall with gears that animate when elevator is moving
/turf/simulated/shuttle/wall/elevator/gears
	icon_state = "wall_gear"

/turf/simulated/shuttle/wall/elevator/gears/proc/start()
	icon_state = "wall_gear_animated"

/turf/simulated/shuttle/wall/elevator/gears/proc/stop()
	icon_state = "wall_gear"

// Special wall icons
/turf/simulated/shuttle/wall/elevator/research
	icon_state = "wall_research"

/turf/simulated/shuttle/wall/elevator/dorm
	icon_state = "wall_dorm"

// Elevator Buttons
/turf/simulated/shuttle/wall/elevator/button
	name = "elevator buttons"

/turf/simulated/shuttle/wall/elevator/button/research
	icon_state = "wall_button_research"

/turf/simulated/shuttle/wall/elevator/button/dorm
	icon_state = "wall_button_dorm"

// Elevator door
/obj/machinery/door/airlock/multi_tile/elevator
	icon = 'icons/obj/doors/elevator4x1.dmi'
	icon_state = "door_closed"
	width = 4
	openspeed = 31

/obj/machinery/door/airlock/multi_tile/elevator/research
	name = "\improper Research Elevator"

/obj/machinery/door/airlock/multi_tile/elevator/arrivals
	name = "\improper Arrivals Elevator"

/obj/machinery/door/airlock/multi_tile/elevator/dormatory
	name = "\improper Dormatory Elevator"

/obj/machinery/door/airlock/multi_tile/elevator/freight
	name = "\improper Freight Elevator"