/obj/machinery/portable_atmospherics
	name = "atmoalter"
	use_power = 0

	var/gas_type = GAS_TYPE_AIR
	var/pressure = ONE_ATMOSPHERE
	var/temperature = T20C

	var/obj/machinery/atmospherics/portables_connector/connected_port

	var/volume = 0
	var/destroyed = 0

	var/maximum_pressure = 90*ONE_ATMOSPHERE


/obj/machinery/portable_atmospherics/initialize()
	. = ..()
	spawn()
		var/obj/machinery/atmospherics/portables_connector/port = locate() in loc
		if(port)
			connect(port)
			update_icon()

/obj/machinery/portable_atmospherics/process()
	if(connected_port)
		update_icon()

/obj/machinery/portable_atmospherics/update_icon()
	return null

/obj/machinery/portable_atmospherics/proc/connect(obj/machinery/atmospherics/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return 0

	//Make sure are close enough for a valid connection
	if(new_port.loc != loc)
		return 0

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src

	anchored = 1 //Prevent movement

	return 1

/obj/machinery/portable_atmospherics/proc/disconnect()
	if(!connected_port)
		return 0

	anchored = 0

	connected_port.connected_device = null
	connected_port = null

	return 1

/obj/machinery/portable_atmospherics/proc/update_connected_network()
	if(!connected_port)
		return


/obj/machinery/portable_atmospherics/attackby(obj/item/W, mob/user)
	var/obj/icon = src
	if (istype(W, /obj/item/tool/wrench))
		if(connected_port)
			disconnect()
			to_chat(user, "<span class='notice'>You disconnect [name] from the port.</span>")
			update_icon()
			return
		else
			var/obj/machinery/atmospherics/portables_connector/possible_port = locate(/obj/machinery/atmospherics/portables_connector/) in loc
			if(possible_port)
				if(connect(possible_port))
					to_chat(user, "<span class='notice'>You connect [name] to the port.</span>")
					update_icon()
					return
				else
					to_chat(user, "<span class='notice'>[name] failed to connect to the port.</span>")
					return
			else
				to_chat(user, "<span class='notice'>Nothing happens.</span>")
				return

	else if ((istype(W, /obj/item/device/analyzer)) && Adjacent(user))
		visible_message("<span class='warning'> [user] has used [W] on \icon[icon]</span>")
		to_chat(user, "<span class='notice'>Results of analysis of \icon[icon]</span>")
		if (pressure>0)
			to_chat(user, "<span class='notice'>Pressure: [round(pressure,0.1)] kPa</span>")
			to_chat(user, "<span class='notice'>[gas_type]: [100]%</span>")
			to_chat(user, "<span class='notice'>Temperature: [round(temperature-T0C)]&deg;C</span>")
		else
			to_chat(user, "<span class='notice'>Tank is empty!</span>")




/obj/machinery/portable_atmospherics/powered
	var/power_rating
	var/power_losses
	var/last_power_draw = 0
	var/obj/item/cell/cell

/obj/machinery/portable_atmospherics/powered/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/cell))
		if(cell)
			to_chat(user, "There is already a power cell installed.")
			return

		var/obj/item/cell/C = I

		if(user.drop_inv_item_to_loc(C, src))
			C.add_fingerprint(user)
			cell = C
			user.visible_message("<span class='notice'> [user] opens the panel on [src] and inserts [C].</span>", "<span class='notice'> You open the panel on [src] and insert [C].</span>")
		return

	if(istype(I, /obj/item/tool/screwdriver))
		if(!cell)
			to_chat(user, "<span class='warning'>There is no power cell installed.</span>")
			return

		user.visible_message("<span class='notice'> [user] opens the panel on [src] and removes [cell].</span>", "<span class='notice'> You open the panel on [src] and remove [cell].</span>")
		cell.add_fingerprint(user)
		cell.loc = src.loc
		cell = null
		return

	..()

