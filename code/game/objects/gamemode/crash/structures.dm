/obj/structure/fuel_tank
	name = "fuel tank"
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "cell-tank"
	flags_atom = CONDUCT
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE

	anchored = FALSE
	climbable = FALSE

	var/fuel_amount = 100
	var/obj/structure/shuttle/engine/attached

/obj/structure/fuel_tank/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/structure/fuel_tank/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "<span class='notice'>It has [fuel_amount] fuel left.</span>")
	if (attached)	
		to_chat(user, "<span class='warning'>It's attached to \the [attached].</span>")
	else
		to_chat(user, "<span class='warning'>It's not attached to anything.</span>")
	

/obj/structure/fuel_tank/MouseDrop(over_object, src_location, over_location)
	. = ..()

	if(attached)
		to_chat(usr, "<span>It's already pumping fuel, you better not touch it.</span>")
		return

	if(get_dist(src_location, over_location) > 1)
		return


	if(!istype(over_object, /obj/structure/shuttle/engine))
		to_chat(usr, "<span>You can't attach that there!</span>")
		return

	if(fuel_amount < 1)
		return

	attached = over_object
	anchored = TRUE
	START_PROCESSING(SSobj, src)
	visible_message("\The [src] clicks as it connects to \the [attached].")

/obj/structure/fuel_tank/process()
	if(!attached)
		return

	if(!--fuel_amount)
		attached = null
		anchored = FALSE
		STOP_PROCESSING(SSobj, src)
		visible_message("\The [src] beeps as it runs out of fuel.")

	if(++attached.fuel_current == attached.fuel_max)
		attached = null
		anchored = FALSE
		STOP_PROCESSING(SSobj, src)
		visible_message("\The [src] beeps as engine is full.")


