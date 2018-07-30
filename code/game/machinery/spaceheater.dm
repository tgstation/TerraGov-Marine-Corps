/obj/machinery/space_heater
	anchored = 0
	density = 0
	icon = 'icons/obj/machines/atmos.dmi'
	icon_state = "sheater0"
	name = "space heater"
	desc = "Made by Space Amish using traditional space techniques, this heater is guaranteed not to set the station on fire."
	var/obj/item/cell/cell
	var/on = 0
	var/open = 0
	var/set_temperature = T0C + 70	//K
	var/heating_power = 40000

	flags_atom = FPRINT


/obj/machinery/space_heater/New()
	..()
	cell = new (src)
	cell.charge += 500
	update_icon()

/obj/machinery/space_heater/update_icon()
	overlays.Cut()
	icon_state = "sheater[on]"
	if(open)
		overlays  += "sheater-open"

/obj/machinery/space_heater/CanPass(atom/movable/mover, turf/target)
	if(!density) //Because broken racks -Agouri |TODO: SPRITE!|
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/machinery/space_heater/examine(mob/user)
	..()
	user << "The heater is [on ? "on" : "off"] and the hatch is [open ? "open" : "closed"]."
	if(open)
		user << "The power cell is [cell ? "installed" : "missing"]."
	else
		user << "The charge meter reads [cell ? round(cell.percent(),1) : 0]%"


/obj/machinery/space_heater/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(cell)
		cell.emp_act(severity)
	..(severity)

/obj/machinery/space_heater/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/cell))
		if(open)
			if(cell)
				user << "There is already a power cell inside."
				return
			else
				// insert cell
				var/obj/item/cell/C = usr.get_active_hand()
				if(istype(C))
					if(user.drop_inv_item_to_loc(C, src))
						cell = C
						C.add_fingerprint(usr)

						user.visible_message("\blue [user] inserts a power cell into [src].", "\blue You insert the power cell into [src].")
		else
			user << "The hatch must be open to insert a power cell."
			return
	else if(istype(I, /obj/item/tool/screwdriver))
		open = !open
		user.visible_message("\blue [user] [open ? "opens" : "closes"] the hatch on the [src].", "\blue You [open ? "open" : "close"] the hatch on the [src].")
		update_icon()
		if(!open && user.interactee == src)
			user << browse(null, "window=spaceheater")
			user.unset_interaction()
	else
		..()
	return

/obj/machinery/space_heater/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	interact(user)

/obj/machinery/space_heater/interact(mob/user as mob)

	if(open)

		var/dat
		dat = "Power cell: "
		if(cell)
			dat += "<A href='byond://?src=\ref[src];op=cellremove'>Installed</A><BR>"
		else
			dat += "<A href='byond://?src=\ref[src];op=cellinstall'>Removed</A><BR>"

		dat += "Power Level: [cell ? round(cell.percent(),1) : 0]%<BR><BR>"

		dat += "Set Temperature: "

		dat += "<A href='?src=\ref[src];op=temp;val=-5'>-</A>"

		dat += " [set_temperature]K ([set_temperature-T0C]&deg;C)"
		dat += "<A href='?src=\ref[src];op=temp;val=5'>+</A><BR>"

		user.set_interaction(src)
		user << browse("<HEAD><TITLE>Space Heater Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=spaceheater")
		onclose(user, "spaceheater")
	else
		on = !on
		if(on)
			start_processing()
		else
			stop_processing()
		user.visible_message("\blue [user] switches [on ? "on" : "off"] the [src].","\blue You switch [on ? "on" : "off"] the [src].")
		update_icon()
	return


/obj/machinery/space_heater/Topic(href, href_list)
	if (usr.stat)
		return
	if ((in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon)))
		usr.set_interaction(src)

		switch(href_list["op"])

			if("temp")
				var/value = text2num(href_list["val"])

				// limit to 0-90 degC
				set_temperature = dd_range(T0C, T0C + 90, set_temperature + value)

			if("cellremove")
				if(open && cell && !usr.get_active_hand())
					usr.visible_message("\blue [usr] removes \the [cell] from \the [src].", "\blue You remove \the [cell] from \the [src].")
					cell.updateicon()
					usr.put_in_hands(cell)
					cell.add_fingerprint(usr)
					cell = null


			if("cellinstall")
				if(open && !cell)
					var/obj/item/cell/C = usr.get_active_hand()
					if(istype(C))
						if(usr.drop_held_item())
							cell = C
							C.forceMove(src)
							C.add_fingerprint(usr)

							usr.visible_message("\blue [usr] inserts \the [C] into \the [src].", "\blue You insert \the [C] into \the [src].")

		updateDialog()
	else
		usr << browse(null, "window=spaceheater")
		usr.unset_interaction()
	return



/obj/machinery/space_heater/process()
	if(on)
		if(isturf(loc) && cell && cell.charge)
			for(var/mob/living/carbon/human/H in range(2, src))
				if(H.bodytemperature < T20C)
					H.bodytemperature += min(round(T20C - H.bodytemperature)*0.7, 25)


			cell.use(50*CELLRATE)

		else
			on = 0
			stop_processing()
			update_icon()
