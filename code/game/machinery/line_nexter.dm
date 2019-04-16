
/obj/machinery/line_nexter
	name = "Turnstile"
	desc = "a one way barrier combined with a bar to pull people out of line."
	icon = 'icons/Marine/barricades.dmi'
	density = 1
	icon_state = "turnstile"
	anchored = 1
	dir = 8
	var/last_use
	var/id

/obj/machinery/line_nexter/New()
	..()
	last_use = world.time

/obj/machinery/line_nexter/ex_act(severity)
	return

/obj/machinery/line_nexter/CheckExit(atom/movable/O, turf/target)
	if(iscarbon(O))
		var/mob/living/carbon/C = O
		if(C.pulledby)
			if(!C.incapacitated() && target == locate(x-1,y,z))
				return 0
	return 1

/obj/machinery/line_nexter/CanPass(atom/movable/mover, turf/target)
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

/obj/machinery/line_nexter_control/attack_hand(mob/user)
	add_fingerprint(user)
	if(istype(user,/mob/living/carbon/Xenomorph))
		return

	icon_state = "doorctrl1"
	add_fingerprint(user)

	for(var/obj/machinery/line_nexter/L in GLOB.machines)
		if(id == L.id)
			L.next()

	spawn(15)
		icon_state = "doorctrl0"
