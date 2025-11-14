GLOBAL_LIST_EMPTY(elevator_doors)

/obj/machinery/door/window/elevator
	name = "elevator door"
	desc = "Keeps idiots like you from walking into an open elevator shaft."
	icon_state = "left"
	base_state = "left"

/obj/machinery/door/window/elevator/right
	icon_state = "right"
	base_state = "right"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/elevator/left, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/elevator/right, 0)
