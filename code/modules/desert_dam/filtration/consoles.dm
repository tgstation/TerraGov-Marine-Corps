/obj/machinery/console
	name = "console"
	desc = "A console."
	icon = 'icons/obj/filtration/filtration.dmi'
	icon_state = "console"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 1000
	var/id = null
	var/damaged = 0

/obj/machinery/console/update_icon()
	..()
	if(damaged)
		icon_state = "[initial(icon_state)]-d"
	else if(stat & NOPOWER)
		icon_state = "[initial(icon_state)]-off"
	else
		icon_state = initial(icon_state)
	return

/obj/machinery/console/ex_act(severity)
	switch(severity)
		if(1.0)
			get_broken()
			return
		if(2.0)
			if (prob(40))
				get_broken()
				return
		if(3.0)
			if (prob(10))
				get_broken()
				return
		else
	return

/obj/machinery/console/proc/get_broken()
	if(damaged)
		return //We're already broken
	damaged = !damaged
	visible_message("<span class='warning'>[src]'s screen cracks, and it bellows out smoke!</span>")
	playsound(src, 'sound/effects/metal_crash.ogg', 35)
	update_icon()
	return

//Consoles for the floodgates
/obj/machinery/console/floodgate/toggle
	icon_state = "toggle"
	var/status = 0 //0 for closed, 1 for open

/obj/machinery/console/floodgate/status
	icon_state = "status"

/obj/machinery/console/floodgate/time
	icon_state = "time"