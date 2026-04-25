/obj/structure/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'

/obj/structure/shuttle/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -40, 8, 1)

/obj/structure/shuttle/window
	name = "shuttle window"
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "1"
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	resistance_flags = RESIST_ALL
	layer = ABOVE_WINDOW_LAYER

/obj/structure/shuttle/engine
	name = "engine"
	density = TRUE
	anchored = TRUE
	resistance_flags = RESIST_ALL

/obj/structure/shuttle/engine/heater
	name = "heater"
	icon_state = "heater"

/obj/structure/shuttle/engine/platform
	name = "platform"
	icon_state = "platform"

/obj/structure/shuttle/engine/propulsion
	name = "propulsion"
	icon_state = "propulsion"
	opacity = TRUE

/obj/structure/shuttle/engine/propulsion/burst
	name = "burst"

/obj/structure/shuttle/engine/propulsion/burst/left
	name = "left"
	icon_state = "burst_l"

/obj/structure/shuttle/engine/propulsion/burst/right
	name = "right"
	icon_state = "burst_r"

/obj/structure/shuttle/engine/router
	name = "router"
	icon_state = "router"
