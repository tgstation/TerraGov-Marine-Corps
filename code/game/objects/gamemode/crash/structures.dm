/obj/structure/fuel_tank
	name = "fuel tank"
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "cell-tank"
	flags_atom = CONDUCT
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE

	anchored = FALSE
	climbable = FALSE

	var/fuel_amount = 100
	var/attached

/obj/structure/fuel_tank/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/structure/fuel_tank/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "<span class='notice'>It has [fuel_amount] fuel left.</span>")

/obj/structure/fuel_tank/MouseDrop(over_object, src_location, over_location)
	. = ..()

	if(attached)
		to_chat(usr, "<span>It's already pumping fuel, you can't disconnect it.</span>")
		return

	if(!istype(over_object, /obj/structure/shuttle/engine))
		to_chat(usr, "<span>You can't attach that there!</span>")
		return

	attached = over_object
	START_PROCESSING(SSobj, src)

/obj/structure/fuel_tank/process()
	if(!attached)
		return

	if(!--fuel_amount)
		STOP_PROCESSING(SSobj, src)
		return
