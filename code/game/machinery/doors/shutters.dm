/obj/machinery/door/poddoor/shutters
	name = "\improper Shutters"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "shutter1"
	power_channel = ENVIRON

/obj/machinery/door/poddoor/shutters/New()
	..()
	if(density && closed_layer)
		layer = closed_layer
	else if(!density && open_layer)
		layer = open_layer
	else
		layer = PODDOOR_CLOSED_LAYER

/obj/machinery/door/poddoor/shutters/attackby(obj/item/C as obj, mob/user as mob)
	add_fingerprint(user)
	if(!C.pry_capable)
		return
	else if(!CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE) && istype(C, /obj/item/tool/pickaxe/plasmacutter) && !user.action_busy)
		var/obj/item/tool/pickaxe/plasmacutter/P = C
		if(!P.start_cut(user, name, src))
			return
		if(do_after(user, P.calc_delay(user), TRUE, 5, BUSY_ICON_HOSTILE) && P)
			P.cut_apart(user, name, src)
			qdel()
		return

	if(density && (machine_stat & NOPOWER) && !operating && !CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		operating = 1
		spawn(-1)
			flick("shutterc0", src)
			icon_state = "shutter0"
			sleep(15)
			density = 0
			SetOpacity(0)
			operating = 0
			return
	return

/obj/machinery/door/poddoor/shutters/open()
	if(operating == 1) //doors can still open when emag-disabled
		return
	if(!SSticker)
		return 0
	if(!operating) //in case of emag
		operating = 1
	flick("shutterc0", src)
	icon_state = "shutter0"
	playsound(loc, 'sound/machines/blastdoor.ogg', 25)
	sleep(10)
	density = 0
	layer = open_layer
	SetOpacity(0)

	if(operating == 1) //emag again
		operating = 0
	if(autoclose)
		spawn(150)
			autoclose()		//TODO: note to self: look into this ~Carn
	return 1

/obj/machinery/door/poddoor/shutters/close()
	if(operating)
		return
	operating = 1
	flick("shutterc1", src)
	icon_state = "shutter1"
	layer = closed_layer
	density = 1
	if(visible)
		SetOpacity(1)
	playsound(loc, 'sound/machines/blastdoor.ogg', 25)

	sleep(10)
	operating = 0
	return

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
