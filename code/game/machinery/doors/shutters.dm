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
	if(operating) //doors can still open when emag-disabled
		return FALSE
	if(!SSticker)
		return FALSE
	if(!operating) //in case of emag
		operating = TRUE
	flick("shutterc0", src)
	icon_state = "shutter0"
	playsound(loc, 'sound/machines/blastdoor.ogg', 25)
	addtimer(CALLBACK(src, .proc/do_open), 10)
	return TRUE

/obj/machinery/door/poddoor/shutters/proc/do_open()
	density = FALSE
	layer = open_layer
	SetOpacity(FALSE)

	if(operating) //emag again
		operating = FALSE
	if(autoclose)
		addtimer(CALLBACK(src, .proc/autoclose), 150)

/obj/machinery/door/poddoor/shutters/close()
	if(operating)
		return
	operating = TRUE
	flick("shutterc1", src)
	icon_state = "shutter1"
	layer = closed_layer
	density = TRUE
	if(visible)
		SetOpacity(TRUE)
	playsound(loc, 'sound/machines/blastdoor.ogg', 25)
	addtimer(CALLBACK(src, .proc/do_close), 10)
	return TRUE

/obj/machinery/door/poddoor/shutters/proc/do_close()
	operating = FALSE

/obj/machinery/door/poddoor/shutters/almayer
	icon = 'icons/obj/doors/almayer/blastdoors_shutters.dmi'
	openspeed = 4 //shorter open animation.
	tiles_with = list(
		/turf/closed/wall,
		/obj/structure/window/framed/almayer,
		/obj/machinery/door/airlock)

/obj/machinery/door/poddoor/shutters/almayer/Initialize()
	relativewall_neighbours()
	return ..()


//transit shutters used by marine dropships
/obj/machinery/door/poddoor/shutters/transit
	name = "Transit shutters"
	desc = "Safety shutters to prevent dangerous depressurization during flight"
	icon = 'icons/obj/doors/almayer/blastdoors_shutters.dmi'
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE

/obj/machinery/door/poddoor/shutters/almayer/open
	density = FALSE
	opacity = FALSE
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	layer = PODDOOR_OPEN_LAYER
	icon_state = "shutter0"

/obj/machinery/door/poddoor/shutters/transit/open
	density = FALSE
	opacity = FALSE
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	layer = PODDOOR_OPEN_LAYER
	icon_state = "shutter0"

/obj/machinery/door/poddoor/shutters/almayer/pressure
	name = "pressure shutters"
	density = 0
	opacity = 0
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	icon_state = "shutter0"
	open_layer = PODDOOR_CLOSED_LAYER
	closed_layer = PODDOOR_CLOSED_LAYER
