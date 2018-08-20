/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'icons/atmos/vent_scrubber.dmi'
	icon_state = "map_scrubber"

	name = "Air Scrubber"
	desc = "Has a valve and pump attached to it"
	use_power = 1
	idle_power_usage = 150		//internal circuitry, friction losses and stuff
	active_power_usage = 7500	//This also doubles as a measure of how powerful the pump is, in Watts. 7500 W ~ 10 HP
	var/last_power_draw = 0

	connect_types = list(1,3) //connects to regular and scrubber pipes

	level = 1

	var/area/initial_loc
	var/id_tag = null
	var/frequency = 1439
	var/datum/radio_frequency/radio_connection

	var/on = 0
	var/scrubbing = 1 //0 = siphoning, 1 = scrubbing
	var/list/scrubbing_gas = list("carbon_dioxide")

	var/panic = 0 //is this scrubber panicked?
	var/welded = 0

	var/area_uid
	var/radio_filter_out
	var/radio_filter_in

/obj/machinery/atmospherics/unary/vent_scrubber/on
	on = 1

/obj/machinery/atmospherics/unary/vent_scrubber/New()
	..()

	icon = null
	initial_loc = get_area(loc)
	if (initial_loc.master)
		initial_loc = initial_loc.master
	area_uid = initial_loc.uid
	if (!id_tag)
		assign_uid()
		id_tag = num2text(uid)
	if(ticker && ticker.current_state == 3)//if the game is running
		src.initialize()
		src.broadcast_status()

/obj/machinery/atmospherics/unary/vent_scrubber/update_icon(var/safety = 0)
	if(!check_icon_cache())
		return

	overlays.Cut()

	if(welded)
		icon = 'icons/atmos/vent_scrubber.dmi'
		icon_state = "welded"
		return

	var/scrubber_icon = "scrubber"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	if(!powered())
		scrubber_icon += "off"
	else
		scrubber_icon += "[on ? "[scrubbing ? "on" : "in"]" : "off"]"

	overlays += icon_manager.get_atmos_icon("device", , , scrubber_icon)

/obj/machinery/atmospherics/unary/vent_scrubber/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		if(T.intact_tile && node && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe))
			return
		else
			if(node)
				add_underlay(T, node, dir, node.icon_connect_type)
			else
				add_underlay(T,, dir)

/obj/machinery/atmospherics/unary/vent_scrubber/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, radio_filter_in)

/obj/machinery/atmospherics/unary/vent_scrubber/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src
	signal.data = list(
		"area" = area_uid,
		"tag" = id_tag,
		"device" = "AScr",
		"timestamp" = world.time,
		"power" = on,
		"scrubbing" = scrubbing,
		"panic" = panic,
		"filter_co2" = ("carbon_dioxide" in scrubbing_gas),
		"filter_phoron" = ("phoron" in scrubbing_gas),
		"filter_n2o" = ("sleeping_agent" in scrubbing_gas),
		"sigtype" = "status"
	)
	if(!initial_loc.air_scrub_names[id_tag])
		var/new_name = "[initial_loc.name] Air Scrubber #[initial_loc.air_scrub_names.len+1]"
		initial_loc.air_scrub_names[id_tag] = new_name
		src.name = new_name
	initial_loc.air_scrub_info[id_tag] = signal.data
	radio_connection.post_signal(src, signal, radio_filter_out)

	return 1

/obj/machinery/atmospherics/unary/vent_scrubber/initialize()
	..()
	radio_filter_in = frequency==initial(frequency)?(RADIO_FROM_AIRALARM):null
	radio_filter_out = frequency==initial(frequency)?(RADIO_TO_AIRALARM):null
	if (frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/unary/vent_scrubber/process()
	..()
	if (!node)
		on = 0
	//broadcast_status()
	if(!on || (stat & (NOPOWER|BROKEN)))
		update_use_power(0)	//we got here because a player turned a pump off - definitely want to update.
		last_flow_rate = 0
		last_power_draw = 0
		return 0

	if(!loc) return

	if(welded)
		return 0

	return 1

/obj/machinery/atmospherics/unary/vent_scrubber/hide(var/i) //to make the little pipe section invisible, the icon changes.
	update_icon()
	update_underlays()

/obj/machinery/atmospherics/unary/vent_scrubber/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return 0

	if(signal.data["power"] != null)
		on = text2num(signal.data["power"])
	if(signal.data["power_toggle"] != null)
		on = !on

	if(signal.data["panic_siphon"]) //must be before if("scrubbing" thing
		panic = text2num(signal.data["panic_siphon"] != null)
		if(panic)
			on = 1
			scrubbing = 0
		else
			scrubbing = 1
	if(signal.data["toggle_panic_siphon"] != null)
		panic = !panic
		if(panic)
			on = 1
			scrubbing = 0
		else
			scrubbing = 1

	if(signal.data["scrubbing"] != null)
		scrubbing = text2num(signal.data["scrubbing"])
	if(signal.data["toggle_scrubbing"])
		scrubbing = !scrubbing

	var/list/toggle = list()

	if(!isnull(signal.data["co2_scrub"]) && text2num(signal.data["co2_scrub"]) != ("carbon_dioxide" in scrubbing_gas))
		toggle += "carbon_dioxide"
	else if(signal.data["toggle_co2_scrub"])
		toggle += "carbon_dioxide"

	if(!isnull(signal.data["tox_scrub"]) && text2num(signal.data["tox_scrub"]) != ("phoron" in scrubbing_gas))
		toggle += "phoron"
	else if(signal.data["toggle_tox_scrub"])
		toggle += "phoron"

	if(!isnull(signal.data["n2o_scrub"]) && text2num(signal.data["n2o_scrub"]) != ("sleeping_agent" in scrubbing_gas))
		toggle += "sleeping_agent"
	else if(signal.data["toggle_n2o_scrub"])
		toggle += "sleeping_agent"

	scrubbing_gas ^= toggle

	if(signal.data["init"] != null)
		name = signal.data["init"]
		return

	if(signal.data["status"] != null)
		spawn(2)
			broadcast_status()
		return //do not update_icon

//			log_admin("DEBUG \[[world.timeofday]\]: vent_scrubber/receive_signal: unknown command \"[signal.data["command"]]\"\n[signal.debug_print()]")
	spawn(2)
		broadcast_status()
	update_icon()
	return

/obj/machinery/atmospherics/unary/vent_scrubber/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(1, user))
			user.visible_message("<span class='notice'>[user] starts welding [src] with [WT].</span>", \
			"<span class='notice'>You start welding [src] with [WT].</span>")
			playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
			if(do_after(user, 50, TRUE, 5, BUSY_ICON_BUILD))
				if(!src || !WT.isOn())
					return
				playsound(get_turf(src), 'sound/items/Welder2.ogg', 25, 1)
				if(!welded)
					user.visible_message("<span class='notice'>[user] welds [src] shut.</span>", \
					"<span class='notice'>You weld [src] shut.</span>")
					welded = 1
					update_icon()
				else
					user.visible_message("<span class='notice'>[user] welds [src] open.</span>", \
					"<span class='notice'>You weld [src] open.</span>")
					welded = 0
					update_icon()
			else
				to_chat(user, "<span class='warning'>[WT] needs to be on to start this task.</span>")
		else
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
		return
	if(!iswrench(W))
		return ..()
	if(!(stat & NOPOWER) && on)
		to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first.</span>")
		return 1
	var/turf/T = loc
	if(node && node.level == 1 && isturf(T) && T.intact_tile)
		to_chat(user, "<span class='warning'>You must remove the plating first.</span>")
		return 1

	playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
	user.visible_message("<span class='notice'>[user] begins unfastening [src].</span>",
	"<span class='notice'>You begin unfastening [src].</span>")
	if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
		playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] unfastens [src].</span>",
		"<span class='notice'>You unfasten [src].</span>")
		new /obj/item/pipe(loc, make_from = src)
		cdel(src)

/obj/machinery/atmospherics/unary/vent_scrubber/examine(mob/user)
	..()
	if(get_dist(user, src) <= 1)
		to_chat(user, "<span class='info'>A small gauge in the corner reads [round(last_flow_rate, 0.1)] L/s; [round(last_power_draw)] W.</span>")
	else
		to_chat(user, "<span class='info'>You are too far away to read the gauge.</span>")
	if(welded)
		to_chat(user, "<span class='info'>It seems welded shut.</span>")

/obj/machinery/atmospherics/unary/vent_scrubber/Dispose()
	if(initial_loc)
		initial_loc.air_scrub_info -= id_tag
		initial_loc.air_scrub_names -= id_tag
	. = ..()

/obj/machinery/atmospherics/unary/vent_scrubber/can_crawl_through()
	return !welded
