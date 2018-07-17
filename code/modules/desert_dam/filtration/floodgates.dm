/turf/closed/wall/r_wall/bunker/floodgate
	name = "flood gate"
	desc = "A gate, designed to help prevent flooding. It can only be closed for a certain period of time, but would allow parts of the river to flow through filtered."
	hull = 1

/obj/structure/floodgate
	name = "flood gate"
	desc = "A gate, designed to help prevent flooding. It can only be closed for a certain period of time, but would allow parts of the river to flow through filtered."
	icon = 'icons/turf/walls/bunker.dmi'
	icon_state = "gate_west"

/obj/machinery/console
	name = "console"
	desc = "A console."
	icon = 'icons/obj/filtration/filtration.dmi'
	icon_state = "console"
	var/id = null

/obj/machinery/console/toggle
	icon_state = "toggle"
	var/status = 0 //0 for closed, 1 for open

/obj/machinery/console/status
	icon_state = "status"

/obj/machinery/console/time
	icon_state = "time"