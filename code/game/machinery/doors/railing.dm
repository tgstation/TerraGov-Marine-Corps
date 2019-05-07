/obj/machinery/door/poddoor/railing
	name = "\improper retractable railing"
	icon = 'icons/obj/doors/railing.dmi'
	icon_state = "railing1"
	use_power = 0
	flags_atom = ON_BORDER
	opacity = 0

	throwpass = TRUE //You can throw objects over this, despite its density.
	open_layer = CATWALK_LAYER
	closed_layer = WINDOW_LAYER

/obj/machinery/door/poddoor/railing/New()
	..()
	if(dir == SOUTH)
		closed_layer = ABOVE_MOB_LAYER
	layer = closed_layer

/obj/machinery/door/poddoor/railing/CheckExit(atom/movable/O, turf/target)
	if(!density)
		return 1

	if(O && O.throwing)
		return 1

	if(get_dir(loc, target) == dir)
		return 0
	else
		return 1

/obj/machinery/door/poddoor/railing/CanPass(atom/movable/mover, turf/target)
	if(!density)
		return 1

	if(mover && mover.throwing)
		return 1

	if(get_dir(loc, target) == dir)
		return 0
	else
		return 1

/obj/machinery/door/poddoor/railing/open()
	if(!SSticker || operating || !density)
		return FALSE

	operating = TRUE
	flick("railingc0", src)
	icon_state = "railing0"
	layer = open_layer

	addtimer(CALLBACK(src, .proc/do_open), 12)
	return TRUE

/obj/machinery/door/poddoor/railing/proc/do_open()
	density = FALSE
	operating = FALSE

/obj/machinery/door/poddoor/railing/close()
	if (!SSticker || operating || density)
		return FALSE
		
	density = TRUE
	operating = TRUE
	layer = closed_layer
	flick("railingc1", src)
	icon_state = "railing1"

	addtimer(CALLBACK(src, .proc/do_close), 12)
	return TRUE

/obj/machinery/door/poddoor/railing/proc/do_close()
	operating = FALSE
