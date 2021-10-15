
/obj/machinery/line_nexter
	name = "Turnstile"
	desc = "a one way barrier combined with a bar to pull people out of line."
	icon = 'icons/Marine/barricades.dmi'
	density = TRUE
	icon_state = "turnstile"
	anchored = TRUE
	dir = 8
	var/last_use
	var/id

/obj/machinery/line_nexter/Initialize()
	. = ..()
	last_use = world.time
	var/static/list/connections = list(
		COMSIG_ATOM_EXIT = .proc/on_try_exit
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/machinery/line_nexter/ex_act(severity)
	return

/obj/machinery/line_nexter/proc/on_try_exit(datum/source, atom/movable/O, direction, list/knownblockers)
	SIGNAL_HANDLER
	if(!iscarbon(O))
		return NONE
	var/mob/living/carbon/C = O
	if(C.pulledby)
		if(!C.incapacitated() && (direction & WEST))
			knownblockers += C
			return COMPONENT_ATOM_BLOCK_EXIT
	if(!density || !(flags_atom & ON_BORDER) || !(direction & dir) || (O.status_flags & INCORPOREAL))
		return NONE
	knownblockers += C
	return COMPONENT_ATOM_BLOCK_EXIT

/obj/machinery/line_nexter/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(get_dir(loc, target) == dir)
		return 0
	else
		return 1

/obj/machinery/line_nexter/proc/next()
	//if((last_use + 20) > world.time) // 20 seconds
	for(var/mob/living/carbon/human/H in locate(x,y,z))
		step(H,dir)
	last_use = world.time

/obj/machinery/line_nexter_control
	name = "Next Button"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	var/id

/obj/machinery/line_nexter_control/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(istype(user,/mob/living/carbon/xenomorph))
		return

	icon_state = "doorctrl1"

	for(var/obj/machinery/line_nexter/L in GLOB.machines)
		if(id == L.id)
			L.next()

	spawn(15)
		icon_state = "doorctrl0"
