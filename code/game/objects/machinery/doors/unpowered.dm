/obj/machinery/door/airlock/unpowered
	autoclose = FALSE
	no_panel = TRUE
	hackProof = TRUE


/obj/machinery/door/airlock/unpowered/try_to_activate_door(mob/user)
	if(locked)
		return FALSE
	return ..()


/obj/machinery/door/airlock/unpowered/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/emag) || locked)
		return FALSE
	return ..()

/obj/machinery/door/airlock/unpowered/shuttle
	icon = 'icons/turf/shuttle.dmi'
	name = "Shuttle Airlock"
	icon_state = "door1"
	opacity = TRUE
	density = TRUE