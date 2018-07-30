//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

obj/machinery/recharger
	name = "recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger"
	anchored = 1
	use_power = 1
	idle_power_usage = 4
	active_power_usage = 15000	//15 kW
	var/obj/item/charging = null
	var/percent_charge_complete = 0
	var/list/allowed_devices = list(/obj/item/weapon/baton, /obj/item/device/laptop, /obj/item/cell, /obj/item/weapon/gun/energy/taser, /obj/item/device/defibrillator)

obj/machinery/recharger/attackby(obj/item/G as obj, mob/user as mob)
	if(istype(user,/mob/living/silicon))
		return

	var/allowed = 0
	for (var/allowed_type in allowed_devices)
		if (istype(G, allowed_type)) allowed = 1

	if(allowed)
		if(charging)
			user << "\red \A [charging] is already charging here."
			return
		// Checks to make sure he's not in space doing it, and that the area got proper power.
		var/area/a = get_area(src)
		if(!isarea(a) || (a.power_equip == 0 && !a.unlimited_power))
			user << "\red The [name] blinks red as you try to insert the item!"
			return
		if(istype(G, /obj/item/device/laptop))
			var/obj/item/device/laptop/L = G
			if(!L.stored_computer.battery)
				user << "There's no battery in it!"
				return
		if(istype(G, /obj/item/device/defibrillator))
			var/obj/item/device/defibrillator/D = G
			if(D.ready)
				user << "<span class='warning'>It won't fit, put the paddles back into [D] first!</span>"
				return
		if(user.drop_inv_item_to_loc(G, src))
			charging = G
			start_processing()
			update_icon()
	else if(istype(G, /obj/item/tool/wrench))
		if(charging)
			user << "\red Remove [charging] first!"
			return
		anchored = !anchored
		user << "You [anchored ? "attached" : "detached"] the recharger."
		playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)

obj/machinery/recharger/attack_hand(mob/user as mob)
	if(istype(user,/mob/living/silicon))
		return

	add_fingerprint(user)

	if(charging)
		charging.update_icon()
		user.put_in_hands(charging)
		charging = null
		stop_processing()
		percent_charge_complete = 0
		update_icon()

obj/machinery/recharger/attack_paw(mob/user as mob)
	return attack_hand(user)

obj/machinery/recharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		update_use_power(0)
		update_icon()
		return
	if(!charging)
		update_use_power(1)
		percent_charge_complete = 0
		update_icon()
	//This is an awful check. Holy cow.
	else
		if(istype(charging, /obj/item/weapon/gun/energy/taser))
			var/obj/item/weapon/gun/energy/taser/E = charging
			if(!E.cell.fully_charged())
				E.cell.give(active_power_usage*CELLRATE)
				percent_charge_complete = E.cell.percent()
				update_use_power(2)
				update_icon()
			else
				percent_charge_complete = 100
				update_use_power(1)
				update_icon()
			return

		if(istype(charging, /obj/item/weapon/baton))
			var/obj/item/weapon/baton/B = charging
			if(B.bcell)
				if(!B.bcell.fully_charged())
					B.bcell.give(active_power_usage*CELLRATE)
					percent_charge_complete = B.bcell.percent()
					update_use_power(2)
					update_icon()
				else
					percent_charge_complete = 100
					update_use_power(1)
					update_icon()
			else
				percent_charge_complete = 0
				update_use_power(1)
				update_icon()
			return

		if(istype(charging, /obj/item/device/laptop))
			var/obj/item/device/laptop/L = charging
			if(!L.stored_computer.battery.fully_charged())
				L.stored_computer.battery.give(active_power_usage*CELLRATE)
				percent_charge_complete = L.stored_computer.battery.percent()
				update_use_power(2)
				update_icon()
			else
				percent_charge_complete = 100
				update_use_power(1)
				update_icon()
			return

		if(istype(charging, /obj/item/device/defibrillator))
			var/obj/item/device/defibrillator/D = charging
			if(!D.dcell.fully_charged())
				D.dcell.give(active_power_usage*CELLRATE)
				percent_charge_complete = D.dcell.percent()
				update_use_power(2)
				update_icon()
			else
				percent_charge_complete = 100
				update_use_power(1)
				update_icon()
			return

		if(istype(charging, /obj/item/cell))
			var/obj/item/cell/C = charging
			if(!C.fully_charged())
				C.give(active_power_usage*CELLRATE)
				percent_charge_complete = C.percent()
				update_use_power(2)
				update_icon()
			else
				percent_charge_complete = 100
				update_use_power(1)
				update_icon()
			return

		/* Disable defib recharging
		if(istype(charging, /obj/item/device/defibrillator))
			var/obj/item/device/defibrillator/D = charging
			if(D.dcell)
				if(!D.dcell.fully_charged())
					icon_state = icon_state_charging
					D.dcell.give(active_power_usage*CELLRATE)
					update_use_power(2)
				else
					icon_state = icon_state_charged
					update_use_power(1)
			else
				icon_state = icon_state_idle
				update_use_power(1)
			return
		*/

/obj/machinery/recharger/power_change()
	..()
	update_icon()

obj/machinery/recharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return
/*
	if(istype(charging,  /obj/item/weapon/gun/energy))
		var/obj/item/weapon/gun/energy/E = charging
		if(E.power_supply)
			E.power_supply.emp_act(severity)
*/
	if(istype(charging, /obj/item/weapon/baton))
		var/obj/item/weapon/baton/B = charging
		if(B.bcell)
			B.bcell.charge = 0
	..(severity)

obj/machinery/recharger/update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	src.overlays = 0
	if((stat & (NOPOWER|BROKEN)))
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

/*
obj/machinery/recharger/wallcharger
	name = "wall recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wrecharger0"
	active_power_usage = 25000	//25 kW , It's more specialized than the standalone recharger (guns and batons only) so make it more powerful
	allowed_devices = list(/obj/item/weapon/gun/energy, /obj/item/weapon/baton)
	icon_state_charged = "wrecharger2"
	icon_state_idle = "wrecharger0"
	icon_state_charging = "wrecharger1"
*/
