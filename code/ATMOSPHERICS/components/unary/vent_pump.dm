#define PRESSURE_CHECK_INTERNAL 2

/obj/machinery/atmospherics/unary/vent_pump
	icon = 'icons/atmos/vent_pump.dmi'
	icon_state = "map_vent"

	name = "Air Vent"
	desc = "Has a valve and pump attached to it"
	use_power = 1
	idle_power_usage = 150		//internal circuitry, friction losses and stuff
	active_power_usage = 7500	//This also doubles as a measure of how powerful the pump is, in Watts. 7500 W ~ 10 HP

	connect_types = list(1,2) //connects to regular and supply pipes

	var/area/initial_loc
	level = 1
	var/area_uid
	var/id_tag = null

	var/on = 0
	var/pump_direction = 1 //0 = siphoning, 1 = releasing

	var/last_power_draw = 0

	var/external_pressure_bound = EXTERNAL_PRESSURE_BOUND
	var/internal_pressure_bound = INTERNAL_PRESSURE_BOUND

	var/pressure_checks = PRESSURE_CHECKS
	//1: Do not pass external_pressure_bound
	//2: Do not pass internal_pressure_bound
	//3: Do not pass either

	// Used when handling incoming radio signals requesting default settings
	var/external_pressure_bound_default = EXTERNAL_PRESSURE_BOUND
	var/internal_pressure_bound_default = INTERNAL_PRESSURE_BOUND
	var/pressure_checks_default = PRESSURE_CHECKS

	var/welded = 0 // Added for aliens -- TLE

	var/frequency = 1439
	var/datum/radio_frequency/radio_connection

	var/radio_filter_out
	var/radio_filter_in

/obj/machinery/atmospherics/unary/vent_pump/on
	on = 1
	icon_state = "map_vent_out"

/obj/machinery/atmospherics/unary/vent_pump/siphon
	pump_direction = 0

/obj/machinery/atmospherics/unary/vent_pump/siphon/on
	on = 1
	icon_state = "map_vent_in"

/obj/machinery/atmospherics/unary/vent_pump/New()
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

/obj/machinery/atmospherics/unary/vent_pump/high_volume
	name = "Large Air Vent"
	power_channel = EQUIP
	active_power_usage = 15000	//15 kW ~ 20 HP


/obj/machinery/atmospherics/unary/vent_pump/engine
	name = "Engine Core Vent"
	power_channel = ENVIRON
	active_power_usage = 15000	//15 kW ~ 20 HP

/obj/machinery/atmospherics/unary/vent_pump/update_icon(var/safety = 0)
	if(!check_icon_cache())
		return
	if (!node)
		on = 0

	overlays.Cut()

	var/vent_icon = "vent"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	if(T.intact_tile && node && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe))
		vent_icon += "h"

	if(welded)
		vent_icon += "weld"
	else if(!powered())
		vent_icon += "off"
	else
		vent_icon += "[on ? "[pump_direction ? "out" : "in"]" : "off"]"

	overlays += icon_manager.get_atmos_icon("device", , , vent_icon)

/obj/machinery/atmospherics/unary/vent_pump/update_underlays()
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

/obj/machinery/atmospherics/unary/vent_pump/hide()
	update_icon()
	update_underlays()

/obj/machinery/atmospherics/unary/vent_pump/proc/can_pump()
	if(stat & (NOPOWER|BROKEN))
		return 0
	if(!on)
		return 0
	if(welded)
		return 0
	return 1

/obj/machinery/atmospherics/unary/vent_pump/process()
	..()

	if (!node)
		on = 0
	if(!can_pump())
		update_use_power(0)	//usually we get here because a player turned a pump off - definitely want to update.
		last_power_draw = 0
		last_flow_rate = 0
		return 0

	return 1

//Radio remote control

/obj/machinery/atmospherics/unary/vent_pump/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency,radio_filter_in)

/obj/machinery/atmospherics/unary/vent_pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"area" = src.area_uid,
		"tag" = src.id_tag,
		"device" = "AVP",
		"power" = on,
		"direction" = pump_direction?("release"):("siphon"),
		"checks" = pressure_checks,
		"internal" = internal_pressure_bound,
		"external" = external_pressure_bound,
		"timestamp" = world.time,
		"sigtype" = "status",
		"power_draw" = last_power_draw,
		"flow_rate" = last_flow_rate,
	)

	if(!initial_loc.air_vent_names[id_tag])
		var/new_name = "[initial_loc.name] Vent Pump #[initial_loc.air_vent_names.len+1]"
		initial_loc.air_vent_names[id_tag] = new_name
		src.name = new_name
	initial_loc.air_vent_info[id_tag] = signal.data

	radio_connection.post_signal(src, signal, radio_filter_out)

	return 1


/obj/machinery/atmospherics/unary/vent_pump/initialize()
	..()

	//some vents work his own spesial way
	radio_filter_in = frequency==1439?(RADIO_FROM_AIRALARM):null
	radio_filter_out = frequency==1439?(RADIO_TO_AIRALARM):null
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/unary/vent_pump/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	//log_admin("DEBUG \[[world.timeofday]\]: /obj/machinery/atmospherics/unary/vent_pump/receive_signal([signal.debug_print()])")
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return 0

	if(signal.data["purge"] != null)
		pressure_checks &= ~1
		pump_direction = 0

	if(signal.data["stabalize"] != null)
		pressure_checks |= 1
		pump_direction = 1

	if(signal.data["power"] != null)
		on = text2num(signal.data["power"])

	if(signal.data["power_toggle"] != null)
		on = !on

	if(signal.data["checks"] != null)
		if (signal.data["checks"] == "default")
			pressure_checks = pressure_checks_default
		else
			pressure_checks = text2num(signal.data["checks"])

	if(signal.data["checks_toggle"] != null)
		pressure_checks = (pressure_checks?0:3)

	if(signal.data["direction"] != null)
		pump_direction = text2num(signal.data["direction"])

	if(signal.data["set_internal_pressure"] != null)
		if (signal.data["set_internal_pressure"] == "default")
			internal_pressure_bound = internal_pressure_bound_default
		else
			internal_pressure_bound = between(
				0,
				text2num(signal.data["set_internal_pressure"]),
				ONE_ATMOSPHERE*50
			)

	if(signal.data["set_external_pressure"] != null)
		if (signal.data["set_external_pressure"] == "default")
			external_pressure_bound = external_pressure_bound_default
		else
			external_pressure_bound = between(
				0,
				text2num(signal.data["set_external_pressure"]),
				ONE_ATMOSPHERE*50
			)

	if(signal.data["adjust_internal_pressure"] != null)
		internal_pressure_bound = between(
			0,
			internal_pressure_bound + text2num(signal.data["adjust_internal_pressure"]),
			ONE_ATMOSPHERE*50
		)

	if(signal.data["adjust_external_pressure"] != null)


		external_pressure_bound = between(
			0,
			external_pressure_bound + text2num(signal.data["adjust_external_pressure"]),
			ONE_ATMOSPHERE*50
		)

	if(signal.data["init"] != null)
		name = signal.data["init"]
		return

	if(signal.data["status"] != null)
		spawn(2)
			broadcast_status()
		return //do not update_icon

		//log_admin("DEBUG \[[world.timeofday]\]: vent_pump/receive_signal: unknown command \"[signal.data["command"]]\"\n[signal.debug_print()]")
	spawn(2)
		broadcast_status()
	update_icon()
	return

/obj/machinery/atmospherics/unary/vent_pump/attackby(obj/item/W, mob/user)
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(1, user))
			user.visible_message("<span class='notice'>[user] starts welding [src] with [WT].</span>", \
			"<span class='notice'>You start welding [src] with [WT].</span>")
			playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
			if(do_after(user, 50, TRUE, 5, BUSY_ICON_BUILD))
				if(!src || !WT.isOn()) return 0
				playsound(get_turf(src), 'sound/items/Welder2.ogg', 25, 1)
				if(!welded)
					user.visible_message("<span class='notice'>[user] welds [src] shut.</span>", \
					"<span class='notice'>You weld [src] shut.</span>")
					welded = 1
					update_icon()
					return 1
				else
					user.visible_message("<span class='notice'>[user] welds [src] open.</span>", \
					"<span class='notice'>You weld [src] open.</span>")
					welded = 0
					update_icon()
					return 1
			else
				to_chat(user, "<span class='warning'>[W] needs to be on to start this task.</span>")
				return 0
		else
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return 1

	if(!iswrench(W))
		return ..()
	if(!(stat & NOPOWER) && on)
		to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first.</span>")
		return 1
	var/turf/T = src.loc
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

/obj/machinery/atmospherics/unary/vent_pump/examine(mob/user)
	..()
	if(get_dist(user, src) <= 1)
		to_chat(user, "<span class='info'>A small gauge in the corner reads [round(last_flow_rate, 0.1)] L/s; [round(last_power_draw)] W.</span>")
	else
		to_chat(user, "<span class='info'>You are too far away to read the gauge.</span>")
	if(welded)
		to_chat(user, "<span class='info'>It seems welded shut.</span>")

/obj/machinery/atmospherics/unary/vent_pump/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/unary/vent_pump/Dispose()
	if(initial_loc)
		initial_loc.air_vent_info -= id_tag
		initial_loc.air_vent_names -= id_tag
	. = ..()


/obj/machinery/atmospherics/unary/vent_pump/can_crawl_through()
	return !welded
