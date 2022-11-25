/obj/machinery/space_heater
	anchored = FALSE
	density = FALSE
	icon = 'icons/obj/machines/atmos.dmi'
	icon_state = "sheater0"
	name = "space heater"
	desc = "Made by Space Amish using traditional space techniques, this heater is guaranteed not to set the station on fire."
	var/obj/item/cell/cell
	var/on = 0
	var/open = 0
	var/set_temperature = T0C + 70	//K
	var/heating_power = 40000


/obj/machinery/space_heater/Initialize()
	. = ..()
	cell = new (src)
	cell.charge += 500
	update_icon()

/obj/machinery/space_heater/update_icon()
	overlays.Cut()
	icon_state = "sheater[on]"
	if(open)
		overlays  += "sheater-open"

/obj/machinery/space_heater/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSTABLE))
		return TRUE


/obj/machinery/space_heater/examine(mob/user)
	. = ..()
	. += "The heater is [on ? "on" : "off"] and the hatch is [open ? "open" : "closed"]."
	if(open)
		. += "The power cell is [cell ? "installed" : "missing"]."
	else
		. += "The charge meter reads [cell ? round(cell.percent(),1) : 0]%"


/obj/machinery/space_heater/emp_act(severity)
	if(machine_stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(cell)
		cell.emp_act(severity)
	..(severity)

/obj/machinery/space_heater/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/cell))
		if(!open)
			to_chat(user, "The hatch must be open to insert a power cell.")
			return

		if(cell)
			to_chat(user, "There is already a power cell inside.")
			return

		var/obj/item/cell/C = user.get_active_held_item()
		if(!istype(C))
			return

		if(!user.transferItemToLoc(C, src))
			return

		cell = C

		user.visible_message(span_notice(" [user] inserts a power cell into [src]."), span_notice(" You insert the power cell into [src]."))

	else if(isscrewdriver(I))
		open = !open
		user.visible_message(span_notice(" [user] [open ? "opens" : "closes"] the hatch on the [src]."), span_notice(" You [open ? "open" : "close"] the hatch on the [src]."))
		update_icon()


/obj/machinery/space_heater/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	on = !on
	if(on)
		start_processing()
	else
		stop_processing()

	user.visible_message(span_notice(" [user] switches [on ? "on" : "off"] the [src]."),span_notice(" You switch [on ? "on" : "off"] the [src]."))
	update_icon()


/obj/machinery/space_heater/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!open)
		return FALSE

	if(!on)
		return FALSE

	return TRUE


/obj/machinery/space_heater/interact(mob/user)
	. = ..()
	if(.)
		return

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

	var/datum/browser/popup = new(user, "spaceheater", "<div align='center'>Space Heater Controls</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/space_heater/Topic(href, href_list)
	. = ..()
	if(.)
		return

	switch(href_list["op"])

		if("temp")
			var/value = text2num(href_list["val"])

			// limit to 0-90 degC
			set_temperature = dd_range(T0C, T0C + 90, set_temperature + value)

		if("cellremove")
			if(open && cell && !usr.get_active_held_item())
				usr.visible_message(span_notice(" [usr] removes \the [cell] from \the [src]."), span_notice(" You remove \the [cell] from \the [src]."))
				cell.update_icon()
				usr.put_in_hands(cell)
				cell = null


		if("cellinstall")
			if(open && !cell)
				var/obj/item/cell/C = usr.get_active_held_item()
				if(istype(C))
					if(usr.drop_held_item())
						cell = C
						C.forceMove(src)

						usr.visible_message(span_notice(" [usr] inserts \the [C] into \the [src]."), span_notice(" You insert \the [C] into \the [src]."))

	updateUsrDialog()



/obj/machinery/space_heater/process()
	if(on)
		if(isturf(loc) && cell && cell.charge)
			for(var/mob/living/carbon/human/H in range(2, src))
				H.adjust_bodytemperature(min(round(T20C - H.bodytemperature)*0.7, 25), 0, T20C)


			cell.use(50*GLOB.CELLRATE)

		else
			on = 0
			stop_processing()
			update_icon()
