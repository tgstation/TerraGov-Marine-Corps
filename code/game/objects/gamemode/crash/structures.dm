/obj/structure/fuel_tank
	name = "fuel tank"
	icon = 'icons/obj/jet_fuel_tank.dmi'
	icon_state = "jet_tank_0"
	flags_atom = CONDUCT
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE

	density = TRUE
	anchored = FALSE
	climbable = FALSE

	var/fuel_amount = 100
	var/obj/structure/shuttle/engine/fuel_dock/attached

/obj/structure/fuel_tank/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/structure/fuel_tank/update_icon()
	icon_state = "jet_tank_[anchored ? "1" : "0"]"
	cut_overlays()
	if(attached)
		add_overlay("jet_tank_o_hose")
	switch(round((fuel_amount / initial(fuel_amount)) * 100))
		if(0)
			add_overlay("jet_tank_o_0")
		if(1 to 49)
			add_overlay("jet_tank_o_33")
		if(50 to 99)
			add_overlay("jet_tank_o_66")
		if(100)
			add_overlay("jet_tank_o_100")
			
	. = ..()


/obj/structure/fuel_tank/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "<span class='notice'>It has [fuel_amount] fuel left.</span>")
	if (attached)	
		to_chat(user, "<span class='warning'>It's attached to \the [attached].</span>")
	else
		to_chat(user, "<span class='warning'>It's not attached to anything.</span>")
	

/obj/structure/fuel_tank/MouseDrop(over_object, src_location, over_location)
	. = ..()

	if(!in_range(usr, src))
		return

	if(attached)
		to_chat(usr, "<span>It's already pumping fuel, you better not touch it.</span>")
		return

	// if(get_dist(src_location, over_location) > 0)
	if(src_location != over_location)
		return

	if(!istype(over_object, /obj/structure/shuttle/engine/fuel_dock))
		to_chat(usr, "<span>You can't attach that there!</span>")
		return

	if(fuel_amount < 1)
		return

	var/obj/structure/shuttle/engine/fuel_dock/E = over_object
	if(E.fuel_current >= E.fuel_max)
		to_chat(usr, "<span class='notice'>That dock is completely full!</span>")
		return

	attached = over_object
	anchored = TRUE
	START_PROCESSING(SSobj, src)
	visible_message("\The [src] clicks as it connects to \the [attached].")
	update_icon()

/obj/structure/fuel_tank/process()
	if(!attached)
		STOP_PROCESSING(SSobj, src)
		update_icon()
		return

	if(!--fuel_amount)
		attached = null
		anchored = FALSE
		STOP_PROCESSING(SSobj, src)
		visible_message("\The [src] beeps as it runs out of fuel.")

	if(++attached.fuel_current >= attached.fuel_max)
		attached = null
		anchored = FALSE
		STOP_PROCESSING(SSobj, src)
		visible_message("\The [src] beeps as dock becomes full.")

	update_icon()



/obj/structure/shuttle/engine/fuel_dock
	name = "fuel dock"
	icon = 'icons/obj/fuel_pad.dmi'
	icon_state = "fuel_pad"
	flags_atom = CONDUCT
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	
	density = FALSE
	anchored = TRUE
	
	var/fuel_max = 3000
	var/fuel_current = 0
	var/obj/structure/fuel_tank/connected

/obj/structure/shuttle/engine/fuel_dock/update_icon()
	. = ..()
	cut_overlays()
	if(connected)
		add_overlay("fuel_pad_o_hose")
