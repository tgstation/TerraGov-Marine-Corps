
/obj/machinery/line_nexter
	name = "Turnstile"
	desc = "a one way barrier combined with a bar to pull people out of line."
	icon = 'icons/obj/structures/barricades/misc.dmi'
	density = TRUE
	icon_state = "turnstile"
	anchored = TRUE
	allow_pass_flags = PASS_DEFENSIVE_STRUCTURE|PASSABLE
	atom_flags = ON_BORDER
	dir = 8
	var/last_use
	var/id

/obj/machinery/line_nexter/Initialize(mapload)
	. = ..()
	last_use = world.time
	var/static/list/connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_try_exit)
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/machinery/line_nexter/on_try_exit(datum/source, atom/movable/mover, direction, list/knownblockers)
	if(iscarbon(mover) && (direction & dir))
		return NONE
	return ..()

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
