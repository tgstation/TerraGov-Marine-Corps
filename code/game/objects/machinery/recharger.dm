/obj/machinery/recharger
	name = "recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 15000	//15 kW
	var/obj/item/charging = null
	var/percent_charge_complete = 0
	var/list/allowed_devices = list(/obj/item/weapon/baton, /obj/item/cell, /obj/item/weapon/gun/energy/taser, /obj/item/defibrillator)

/obj/machinery/recharger/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(issilicon(user))
		return

	var/allowed = FALSE
	for(var/allowed_type in allowed_devices)
		if(istype(I, allowed_type))
			allowed = TRUE
			break

	if(iswrench(I))
		if(charging)
			to_chat(user, span_warning("Remove [charging] first!"))
			return
		anchored = !anchored
		to_chat(user, "You [anchored ? "attached" : "detached"] the recharger.")
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

	if(!allowed)
		return

	if(charging)
		to_chat(user, span_warning("\A [charging] is already charging here."))
		return
	// Checks to make sure he's not in space doing it, and that the area got proper power.
	var/area/A = get_area(src)
	if(!isarea(A) || (A.power_equip == 0 && A.requires_power))
		to_chat(user, span_warning("The [name] blinks red as you try to insert the item!"))
		return

	if(istype(I, /obj/item/defibrillator))
		var/obj/item/defibrillator/D = I
		if(D.ready)
			to_chat(user, span_warning("It won't fit, put the paddles back into [D] first!"))
			return

	if(!user.transferItemToLoc(I, src))
		return

	charging = I
	start_processing()
	update_icon()


obj/machinery/recharger/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(istype(user,/mob/living/silicon))
		return

	if(charging)
		charging.update_icon()
		user.put_in_hands(charging)
		charging = null
		stop_processing()
		percent_charge_complete = 0
		update_icon()

obj/machinery/recharger/process()
	if(machine_stat & (NOPOWER|BROKEN) || !anchored)
		update_icon()
		return
	if(!charging)
		percent_charge_complete = 0
		update_icon()
	//This is an awful check. Holy cow.
	else
		if(istype(charging, /obj/item/weapon/gun/energy/taser))
			var/obj/item/weapon/gun/energy/taser/E = charging
			if(!E.rounds)
				E.rounds += active_power_usage * GLOB.CELLRATE
				percent_charge_complete = E.rounds * 100 / E.max_rounds
				update_icon()
			else
				percent_charge_complete = 100
				update_icon()
			return

		if(istype(charging, /obj/item/weapon/baton))
			var/obj/item/weapon/baton/B = charging
			if(B.bcell)
				if(!B.bcell.fully_charged())
					B.bcell.give(active_power_usage*GLOB.CELLRATE)
					percent_charge_complete = B.bcell.percent()
					update_icon()
				else
					percent_charge_complete = 100
					update_icon()
			else
				percent_charge_complete = 0
				update_icon()
			return

		if(istype(charging, /obj/item/defibrillator))
			var/obj/item/defibrillator/D = charging
			if(!D.dcell.fully_charged())
				D.dcell.give(active_power_usage*GLOB.CELLRATE)
				percent_charge_complete = D.dcell.percent()
				update_icon()
			else
				percent_charge_complete = 100
				update_icon()
			return

		if(istype(charging, /obj/item/cell))
			var/obj/item/cell/C = charging
			if(!C.fully_charged())
				C.give(active_power_usage*GLOB.CELLRATE)
				percent_charge_complete = C.percent()
				update_icon()
			else
				percent_charge_complete = 100
				update_icon()
			return


obj/machinery/recharger/emp_act(severity)
	if(machine_stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return

	if(istype(charging, /obj/item/weapon/baton))
		var/obj/item/weapon/baton/B = charging
		if(B.bcell)
			B.bcell.charge = 0
	..(severity)

/obj/machinery/recharger/update_icon()
	overlays = list()
	if((machine_stat & (NOPOWER|BROKEN)))
		return
	else if(!charging)
		overlays += "recharger-power"
		return

	if(percent_charge_complete < 25)
		overlays += "recharger-10"
	else if(percent_charge_complete >= 25 && percent_charge_complete < 50)
		overlays += "recharger-25"
	else if(percent_charge_complete >= 50 && percent_charge_complete < 75)
		overlays += "recharger-50"
	else if(percent_charge_complete >= 75 && percent_charge_complete < 100)
		overlays += "recharger-75"
	else if(percent_charge_complete >= 100)
		overlays += "recharger-100"

	if(istype(charging, /obj/item/weapon/gun/energy/taser))
		overlays += "recharger-taser"
	else if(istype(charging, /obj/item/weapon/baton))
		overlays += "recharger-baton"

/obj/machinery/recharger/nopower
	use_power = NO_POWER_USE
