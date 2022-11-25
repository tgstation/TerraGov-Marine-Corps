/obj/machinery/cell_charger
	name = "heavy-duty cell charger"
	desc = "A much more powerful version of the standard recharger that is specially designed for charging power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger0"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 40000	//40 kW. (this the power drawn when charging)
	power_channel = EQUIP
	var/obj/item/cell/charging = null
	var/chargelevel = -1

/obj/machinery/cell_charger/proc/updateicon()
	icon_state = "ccharger[charging ? 1 : 0]"

	if(charging && !(machine_stat & (BROKEN|NOPOWER)) )

		var/newlevel = 	round(charging.percent() * 4.0 / 99)
		//to_chat(world, "nl: [newlevel]")

		if(chargelevel != newlevel)

			overlays.Cut()
			overlays += "ccharger-o[newlevel]"

			chargelevel = newlevel
	else
		overlays.Cut()

/obj/machinery/cell_charger/examine(mob/user)
	. = ..()
	. += "There's [charging ? "a" : "no"] cell in the charger."
	if(charging)
		. += "Current charge: [charging.charge]"

/obj/machinery/cell_charger/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(machine_stat & BROKEN)
		return

	if(istype(I, /obj/item/cell) && anchored)
		if(charging)
			to_chat(user, span_warning("There is already a cell in the charger."))
			return

		var/area/A = loc.loc
		if(!isarea(A))
			return

		if(A.power_equip == 0) // There's no APC in this area, don't try to cheat power!
			to_chat(user, span_warning("The [name] blinks red as you try to insert the cell!"))
			return

		if(user.transferItemToLoc(I, src))
			charging = I
			user.visible_message("[user] inserts a cell into the charger.", "You insert a cell into the charger.")
			chargelevel = -1
			start_processing()

		updateicon()

	else if(iswrench(I))
		if(charging)
			to_chat(user, span_warning("Remove the cell first!"))
			return

		anchored = !anchored
		to_chat(user, "You [anchored ? "attach" : "detach"] the cell charger [anchored ? "to" : "from"] the ground")
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

/obj/machinery/cell_charger/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(charging)
		usr.put_in_hands(charging)
		charging.update_icon()

		src.charging = null
		user.visible_message("[user] removes the cell from the charger.", "You remove the cell from the charger.")
		chargelevel = -1
		updateicon()
		stop_processing()


/obj/machinery/cell_charger/emp_act(severity)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	if(charging)
		charging.emp_act(severity)
	..(severity)


/obj/machinery/cell_charger/process()
	//to_chat(world, "ccpt [charging] [stat]")
	if((machine_stat & (BROKEN|NOPOWER)) || !anchored)
		return

	if (charging && !charging.fully_charged())
		charging.give(active_power_usage*GLOB.CELLRATE)

		updateicon()
