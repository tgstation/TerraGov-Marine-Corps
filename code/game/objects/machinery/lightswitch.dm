// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var
/obj/machinery/light_switch
	name = "light switch"
	desc = "It turns lights on and off. What are you, simple?"
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	anchored = TRUE
	var/on = 1
	var/area/area = null
	var/otherarea = null

/obj/machinery/light_switch/Initialize()
	. = ..()
	src.area = get_area(src)

	if(otherarea)
		src.area = locate(text2path("/area/[otherarea]"))

	if(!name)
		name = "light switch ([area.name])"

	src.on = src.area.lightswitch
	updateicon()

/obj/machinery/light_switch/proc/updateicon()
	if(machine_stat & NOPOWER)
		icon_state = "light-p"
	else
		if(on)
			icon_state = "light1"
		else
			icon_state = "light0"

/obj/machinery/light_switch/examine(mob/user)
	..()
	to_chat(user, "It is [on? "on" : "off"].")


/obj/machinery/light_switch/attack_paw(mob/user)
	src.attack_hand(user)

/obj/machinery/light_switch/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	on = !on

	area.lightswitch = on
	area.update_icon()

	area.power_change()

/obj/machinery/light_switch/power_change()

	if(!otherarea)
		if(powered(LIGHT))
			machine_stat &= ~NOPOWER
		else
			machine_stat |= NOPOWER

		updateicon()

/obj/machinery/light_switch/emp_act(severity)
	if(machine_stat & (BROKEN|NOPOWER))
		..(severity)
		return
	power_change()
	..(severity)
