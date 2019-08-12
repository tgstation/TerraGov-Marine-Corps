/obj/machinery/door/poddoor/shutters
	name = "\improper Shutters"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "shutter1"
	power_channel = ENVIRON

/obj/machinery/door/poddoor/shutters/Initialize()
	. = ..()
	if(density && closed_layer)
		layer = closed_layer
	else if(!density && open_layer)
		layer = open_layer
	else
		layer = PODDOOR_CLOSED_LAYER

/obj/machinery/door/poddoor/shutters/open()
	if(operating)
		return FALSE
	if(!SSticker)
		return FALSE
	if(!operating)
		operating = TRUE
	do_animate("opening")
	icon_state = "shutter0"
	playsound(loc, 'sound/machines/shutter.ogg', 25)
	addtimer(CALLBACK(src, .proc/do_open), 1 SECONDS)
	return TRUE

/obj/machinery/door/poddoor/shutters/proc/do_open()
	density = FALSE
	layer = open_layer
	set_opacity(FALSE)

	if(operating)
		operating = FALSE
	if(autoclose)
		addtimer(CALLBACK(src, .proc/autoclose), 150)

/obj/machinery/door/poddoor/shutters/close()
	if(operating)
		return
	operating = TRUE
	do_animate("closing")
	icon_state = "shutter1"
	layer = closed_layer
	density = TRUE
	if(visible)
		set_opacity(TRUE)
	playsound(loc, 'sound/machines/shutter.ogg', 25)
	addtimer(CALLBACK(src, .proc/do_close), 1 SECONDS)
	return TRUE

/obj/machinery/door/poddoor/shutters/proc/do_close()
	operating = FALSE


/obj/machinery/door/poddoor/shutters/update_icon()
	if(operating)
		return
	icon_state = "shutter[density]"


/obj/machinery/door/poddoor/shutters/do_animate(animation)
	switch(animation)
		if("opening")
			flick("shutterc0", src)
		if("closing")
			flick("shutterc1", src)


/obj/machinery/door/poddoor/shutters/mainship
	icon = 'icons/obj/doors/mainship/blastdoors_shutters.dmi'
	icon_state = "shutter1"
	openspeed = 4 //shorter open animation.
	tiles_with = list(
		/turf/closed/wall,
		/obj/structure/window/framed/mainship,
		/obj/machinery/door/airlock)


/obj/machinery/door/poddoor/shutters/mainship/Initialize()
	relativewall_neighbours()
	return ..()


/obj/machinery/door/poddoor/shutters/timed_late
	icon = 'icons/obj/doors/mainship/blastdoors_shutters.dmi'
	name = "Timed Emergency Shutters"
	use_power = FALSE


/obj/machinery/door/poddoor/shutters/timed_late/Initialize()
	RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_CRASH), .proc/open)
	return ..()


//transit shutters used by marine dropships
/obj/machinery/door/poddoor/shutters/transit
	name = "Transit shutters"
	desc = "Safety shutters to prevent dangerous depressurization during flight"
	icon = 'icons/obj/doors/mainship/blastdoors_shutters.dmi'
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE


/obj/machinery/door/poddoor/shutters/mainship/open
	density = FALSE
	opacity = FALSE
	layer = PODDOOR_OPEN_LAYER
	icon_state = "shutter0"


/obj/machinery/door/poddoor/shutters/mainship/open/indestructible
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE


/obj/machinery/door/poddoor/shutters/transit/open
	density = FALSE
	opacity = FALSE
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	layer = PODDOOR_OPEN_LAYER
	icon_state = "shutter0"


/obj/machinery/door/poddoor/shutters/mainship/pressure
	name = "pressure shutters"
	density = FALSE
	opacity = FALSE
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	icon_state = "shutter0"
	open_layer = PODDOOR_CLOSED_LAYER
	closed_layer = PODDOOR_CLOSED_LAYER
