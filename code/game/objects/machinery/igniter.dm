/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting flammable items."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter1"
	plane = FLOOR_PLANE
	var/id = null
	var/on = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 50

/obj/machinery/igniter/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/igniter/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	use_power(active_power_usage)
	on = !on
	icon_state = "igniter[on]"


/obj/machinery/igniter/Initialize()
	. = ..()
	icon_state = "igniter[on]"


/obj/machinery/igniter/update_icon()
	if(is_operational())
		icon_state = "igniter[on]"
	else
		icon_state = "igniter0"

// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "Mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 1000
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
	use_power(active_power_usage)
	return 1

/obj/machinery/sparker/emp_act(severity)
	if(machine_stat & (BROKEN|NOPOWER))
		..(severity)
		return
	ignite()
	..(severity)

/obj/machinery/ignition_switch/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/ignition_switch/attackby(obj/item/I, mob/user, params)
	. = ..()
	return attack_hand(user)

/obj/machinery/ignition_switch/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(active_power_usage)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/sparker/M in GLOB.machines)
		if (M.id == src.id)
			INVOKE_ASYNC(M, /obj/machinery/sparker.proc/ignite)

	for(var/obj/machinery/igniter/M in GLOB.machines)
		if(M.id == src.id)
			use_power(active_power_usage)
			M.on = !( M.on )
			M.icon_state = text("igniter[]", M.on)

	sleep(50)

	icon_state = "launcherbtt"
	active = 0

	return
