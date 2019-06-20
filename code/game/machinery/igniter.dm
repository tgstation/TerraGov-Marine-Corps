/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting flammable items."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter1"
	var/id = null
	var/on = 1.0
	anchored = TRUE
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/igniter/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/igniter/attack_paw(mob/user as mob)
	return

/obj/machinery/igniter/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return

	use_power(50)
	src.on = !( src.on )
	src.icon_state = text("igniter[]", src.on)
	return

/obj/machinery/igniter/process()	//ugh why is this even in process()?
//	if (src.on && !(machine_stat & NOPOWER) )
//		var/turf/location = src.loc
//		if (isturf(location))
//			location.hotspot_expose(1000,500,1)
	return 1

/obj/machinery/igniter/New()
	..()
	icon_state = "igniter[on]"

/obj/machinery/igniter/update_icon()
	if(!( machine_stat & NOPOWER) )
		icon_state = "igniter[src.on]"
	else
		icon_state = "igniter0"

// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "Mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	var/id = null
	var/disable = 0
	var/last_spark = 0
	var/base_state = "migniter"
	anchored = TRUE

/obj/machinery/sparker/update_icon()
	if ( !(machine_stat & NOPOWER) && disable == 0 )

		icon_state = "[base_state]"
//		src.sd_SetLuminosity(2)
	else
		icon_state = "[base_state]-p"
//		src.sd_SetLuminosity(0)

/obj/machinery/sparker/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/detective_scanner))
		return

	else if(isscrewdriver(I))
		disable = !disable
		if(disable)
			user.visible_message("<span class='warning'> [user] has disabled the [src]!</span>", "<span class='warning'> You disable the connection to the [src].</span>")
			icon_state = "[base_state]-d"
		else
			user.visible_message("<span class='warning'> [user] has reconnected the [src]!</span>", "<span class='warning'> You fix the connection to the [src].</span>")
			if(powered())
				icon_state = "[base_state]"
			else
				icon_state = "[base_state]-p"

/obj/machinery/sparker/attack_ai()
	if (src.anchored)
		return src.ignite()
	else
		return

/obj/machinery/sparker/proc/ignite()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_spark && world.time < src.last_spark + 50))
		return


	flick("[base_state]-spark", src)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(2, 1, src)
	s.start()
	src.last_spark = world.time
	use_power(1000)
//	var/turf/location = src.loc
//	if (isturf(location))
//		location.hotspot_expose(1000,500,1)
	return 1

/obj/machinery/sparker/emp_act(severity)
	if(machine_stat & (BROKEN|NOPOWER))
		..(severity)
		return
	ignite()
	..(severity)

/obj/machinery/ignition_switch/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/ignition_switch/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/ignition_switch/attackby(obj/item/I, mob/user, params)
	. = ..()
	return attack_hand(user)

/obj/machinery/ignition_switch/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/sparker/M in GLOB.machines)
		if (M.id == src.id)
			spawn( 0 )
				M.ignite()

	for(var/obj/machinery/igniter/M in GLOB.machines)
		if(M.id == src.id)
			use_power(50)
			M.on = !( M.on )
			M.icon_state = text("igniter[]", M.on)

	sleep(50)

	icon_state = "launcherbtt"
	active = 0

	return
