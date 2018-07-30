/obj/machinery/atmospherics/trinary/filter
	icon = 'icons/atmos/filter.dmi'
	icon_state = "map"
	density = 0
	level = 1

	name = "Gas filter"

	use_power = 1
	idle_power_usage = 150		//internal circuitry, friction losses and stuff
	active_power_usage = 7500	//This also doubles as a measure of how powerful the filter is, in Watts. 7500 W ~ 10 HP

	var/temp = null // -- TLE

	var/set_flow_rate = ATMOS_DEFAULT_VOLUME_FILTER

	/*
	Filter types:
	-1: Nothing
	 0: Phoron: Phoron, Oxygen Agent B
	 1: Oxygen: Oxygen ONLY
	 2: Nitrogen: Nitrogen ONLY
	 3: Carbon Dioxide: Carbon Dioxide ONLY
	 4: Sleeping Agent (N2O)
	*/
	var/filter_type = -1
	var/list/filtered_out = list()


	var/frequency = 0
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/trinary/filter/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/trinary/filter/New()
	..()
	switch(filter_type)
		if(0) //removing hydrocarbons
			filtered_out = list("phoron", "oxygen_agent_b")
		if(1) //removing O2
			filtered_out = list("oxygen")
		if(2) //removing N2
			filtered_out = list("nitrogen")
		if(3) //removing CO2
			filtered_out = list("carbon_dioxide")
		if(4)//removing N2O
			filtered_out = list("sleeping_agent")

	if(radio_controller)
		initialize()

/obj/machinery/atmospherics/trinary/filter/update_icon()
	if(istype(src, /obj/machinery/atmospherics/trinary/filter/m_filter))
		icon_state = "m"
	else
		icon_state = ""

	if(!powered())
		icon_state += "off"
	else if(node2 && node3 && node1)
		icon_state += on ? "on" : "off"
	else
		icon_state += "off"
		on = 0

/obj/machinery/atmospherics/trinary/filter/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		add_underlay(T, node1, turn(dir, -180))

		if(istype(src, /obj/machinery/atmospherics/trinary/filter/m_filter))
			add_underlay(T, node2, turn(dir, 90))
		else
			add_underlay(T, node2, turn(dir, -90))

		add_underlay(T, node3, dir)

/obj/machinery/atmospherics/trinary/filter/hide(var/i)
	update_underlays()

/obj/machinery/atmospherics/trinary/filter/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/trinary/filter/process()
	..()
	if((stat & (NOPOWER|BROKEN)) || !on)
		update_use_power(0)	//usually we get here because a player turned a pump off - definitely want to update.
		last_flow_rate = 0
		return

	return 1

/obj/machinery/atmospherics/trinary/filter/initialize()
	set_frequency(frequency)
	..()

/obj/machinery/atmospherics/trinary/filter/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if (!istype(W, /obj/item/tool/wrench))
		return ..()

	playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
	user.visible_message("<span class='notice'>[user] begins unfastening [src].</span>",
	"<span class='notice'>You begin unfastening [src].</span>")
	if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
		playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] unfastens [src].</span>",
		"<span class='notice'>You unfasten [src].</span>")
		new /obj/item/pipe(loc, make_from = src)
		cdel(src)

/obj/machinery/atmospherics/trinary/filter/attack_hand(user as mob) // -- TLE
	if(..())
		return

	if(!src.allowed(user))
		user << "\red Access denied."
		return

	var/dat
	var/current_filter_type
	switch(filter_type)
		if(0)
			current_filter_type = "Phoron"
		if(1)
			current_filter_type = "Oxygen"
		if(2)
			current_filter_type = "Nitrogen"
		if(3)
			current_filter_type = "Carbon Dioxide"
		if(4)
			current_filter_type = "Nitrous Oxide"
		if(-1)
			current_filter_type = "Nothing"
		else
			current_filter_type = "ERROR - Report this bug to the admin, please!"

	dat += {"
			<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"On":"Off"]</a><br>
			<b>Filtering: </b>[current_filter_type]<br><HR>
			<h4>Set Filter Type:</h4>
			<A href='?src=\ref[src];filterset=0'>Phoron</A><BR>
			<A href='?src=\ref[src];filterset=1'>Oxygen</A><BR>
			<A href='?src=\ref[src];filterset=2'>Nitrogen</A><BR>
			<A href='?src=\ref[src];filterset=3'>Carbon Dioxide</A><BR>
			<A href='?src=\ref[src];filterset=4'>Nitrous Oxide</A><BR>
			<A href='?src=\ref[src];filterset=-1'>Nothing</A><BR>
			<HR>
			<B>Set Flow Rate Limit:</B>
			[src.set_flow_rate]L/s|<a href='?src=\ref[src];set_flow_rate=1'>Change</a><BR>
			<B>Flow rate: </B>[round(last_flow_rate, 0.1)]L/s
			"}
/*
		user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD>[dat]","window=atmo_filter")
		onclose(user, "atmo_filter")
		return

	if (src.temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];temp=1'>Clear Screen</A>", src.temp, src)
	//else
	//	src.on != src.on
*/
	user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_filter")
	onclose(user, "atmo_filter")
	return

/obj/machinery/atmospherics/trinary/filter/Topic(href, href_list) // -- TLE
	if(..())
		return
	usr.set_interaction(src)
	src.add_fingerprint(usr)
	if(href_list["filterset"])
		filter_type = text2num(href_list["filterset"])

		filtered_out.Cut()	//no need to create new lists unnecessarily
		switch(filter_type)
			if(0) //removing hydrocarbons
				filtered_out += "phoron"
				filtered_out += "oxygen_agent_b"
			if(1) //removing O2
				filtered_out += "oxygen"
			if(2) //removing N2
				filtered_out += "nitrogen"
			if(3) //removing CO2
				filtered_out += "carbon_dioxide"
			if(4)//removing N2O
				filtered_out += "sleeping_agent"

	if (href_list["temp"])
		src.temp = null
	if(href_list["set_flow_rate"])
		var/new_flow_rate = input(usr,"Enter new flow rate (0-5000L/s)","Flow Rate Control",src.set_flow_rate) as num
		src.set_flow_rate = max(0, min(5000, new_flow_rate))
	if(href_list["power"])
		on=!on
	src.update_icon()
	src.updateUsrDialog()
/*
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.interactee == src))
			src.attack_hand(M)
*/
	return

/obj/machinery/atmospherics/trinary/filter/m_filter
	icon_state = "mmap"

	dir = SOUTH
	initialize_directions = SOUTH|NORTH|EAST

obj/machinery/atmospherics/trinary/filter/m_filter/New()
	..()
	switch(dir)
		if(NORTH)
			initialize_directions = WEST|NORTH|SOUTH
		if(SOUTH)
			initialize_directions = SOUTH|EAST|NORTH
		if(EAST)
			initialize_directions = EAST|WEST|NORTH
		if(WEST)
			initialize_directions = WEST|SOUTH|EAST

/obj/machinery/atmospherics/trinary/filter/m_filter/initialize()
	set_frequency(frequency)

	if(node1 && node2 && node3) return

	var/node1_connect = turn(dir, -180)
	var/node2_connect = turn(dir, 90)
	var/node3_connect = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			node2 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node3_connect))
		if(target.initialize_directions & get_dir(target,src))
			node3 = target
			break

	update_icon()
	update_underlays()
