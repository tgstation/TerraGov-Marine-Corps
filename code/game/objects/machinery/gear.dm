/obj/machinery/gear
	name = "\improper gear"
	icon_state = "gear"
	anchored = TRUE
	density = FALSE
	resistance_flags = UNACIDABLE
	use_power = 0
	var/id

/obj/machinery/gear/proc/start_moving(direction = NORTH)
	icon_state = "gear_moving"
	setDir(direction)

/obj/machinery/gear/proc/stop_moving()
	icon_state = "gear"

/obj/machinery/elevator_strut
	name = "\improper strut"
	icon = 'icons/obj/elevator_strut.dmi'
	anchored = TRUE
	resistance_flags = UNACIDABLE
	density = FALSE
	use_power = 0
	opacity = TRUE
	layer = ABOVE_MOB_LAYER
	var/id

/obj/machinery/elevator_strut/top
	icon_state = "strut_top"

/obj/machinery/elevator_strut/bottom
	icon_state = "strut_bottom"

/obj/machinery/gear/vehicle // todo do for suppply as well instead of varediting
	id = "vehicle_elevator_gear"
