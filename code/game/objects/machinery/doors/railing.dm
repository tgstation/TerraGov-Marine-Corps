/obj/machinery/door/poddoor/railing
	name = "\improper retractable railing"
	icon = 'icons/obj/doors/railing.dmi'
	icon_state = "railing1"
	use_power = 0
	flags_atom = ON_BORDER
	opacity = FALSE
	open_layer = CATWALK_LAYER
	closed_layer = WINDOW_LAYER

	var/obj/docking_port/mobile/supply/linked_pad


/obj/machinery/door/poddoor/railing/opened
	icon_state = "railing0"
	density = FALSE


/obj/machinery/door/poddoor/railing/Initialize()
	. = ..()
	if(dir == SOUTH)
		closed_layer = ABOVE_MOB_LAYER
	layer = closed_layer
	var/static/list/connections = list(
		COMSIG_ATOM_EXIT = .proc/on_try_exit
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/machinery/door/poddoor/railing/Destroy()
	if(linked_pad)
		linked_pad.railings -= src
		linked_pad = null
	return ..()


/obj/machinery/door/poddoor/railing/proc/on_try_exit(datum/source, atom/movable/mover, direction, list/moveblockers)
	SIGNAL_HANDLER
	if(!density || !(flags_atom & ON_BORDER) || !(direction & dir) || (mover.status_flags & INCORPOREAL))
		return NONE
	if(mover.throwing)
		return NONE
	moveblockers += src
	return COMPONENT_ATOM_BLOCK_EXIT

/obj/machinery/door/poddoor/railing/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!density)
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


/obj/machinery/door/poddoor/railing/update_icon()
	if(density)
		icon_state = "railing1"
	else
		icon_state = "railing0"

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
