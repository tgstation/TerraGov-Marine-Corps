/obj/vehicle/ridden/bicycle
	name = "bicycle"
	desc = "Keep away from electricity."
	icon_state = "bicycle"

/obj/vehicle/ridden/bicycle/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/bicycle)

