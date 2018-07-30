/obj/machinery/door/poddoor/railing
	name = "\improper retractable railing"
	icon = 'icons/obj/doors/railing.dmi'
	icon_state = "railing1"
	use_power = 0
	flags_atom = ON_BORDER
	opacity = 0
	explosion_resistance = 0

	throwpass = TRUE //You can throw objects over this, despite its density.
	open_layer = CATWALK_LAYER
	closed_layer = WINDOW_LAYER
	var/closed_layer_south = ABOVE_MOB_LAYER

/obj/machinery/door/poddoor/railing/New()
	..()
	switch(dir)
		if(SOUTH) layer = closed_layer_south
		else layer = closed_layer

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
	if (src.operating == 1) //doors can still open when emag-disabled
		return 0
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick("railingc0", src)
	src.icon_state = "railing0"
	layer = open_layer

	sleep(12)

	src.density = 0
	if(operating == 1) //emag again
		src.operating = 0
	return 1

/obj/machinery/door/poddoor/railing/close()
	if (src.operating)
		return 0
	src.density = 1
	src.operating = 1
	switch(dir)
		if(SOUTH) layer = closed_layer_south
		else layer = closed_layer
	flick("railingc1", src)
	src.icon_state = "railing1"

	sleep(12)

	src.operating = 0
	return 1