//Acts like a normal vent, but has an input AND output.

#define EXT_BOUND 1
#define INPUT_MIN 2
#define OUTPUT_MAX 4

/obj/machinery/atmospherics/components/binary/dp_vent_pump
	icon = 'icons/obj/atmospherics/components/unary_devices.dmi' //We reuse the normal vent icons!
	icon_state = "dpvent_map-2"

	//node2 is output port
	//node1 is input port

	name = "dual-port air vent"
	desc = "Has a valve and pump attached to it. There are two ports."

	level = 1
	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

	var/pump_direction = 1 //0 = siphoning, 1 = releasing

	var/pressure_checks = EXT_BOUND

	//EXT_BOUND: Do not pass external_pressure_bound
	//INPUT_MIN: Do not pass input_pressure_min
	//OUTPUT_MAX: Do not pass output_pressure_max


/obj/machinery/atmospherics/components/binary/dp_vent_pump/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		var/image/cap = getpipeimage(icon, "dpvent_cap", dir, piping_layer = piping_layer)
		add_overlay(cap)

	if(!on || !is_operational())
		icon_state = "vent_off"
	else
		icon_state = pump_direction ? "vent_out" : "vent_in"


/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume
	name = "large dual-port air vent"

// Mapping

/obj/machinery/atmospherics/components/binary/dp_vent_pump/layer1
	piping_layer = 1
	icon_state = "dpvent_map-1"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/layer3
	piping_layer = 3
	icon_state = "dpvent_map-3"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/on
	on = TRUE
	icon_state = "dpvent_map_on-2"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/on/layer1
	piping_layer = 1
	icon_state = "dpvent_map_on-1"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/on/layer3
	piping_layer = 3
	icon_state = "dpvent_map_on-3"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/layer1
	piping_layer = 1
	icon_state = "dpvent_map-1"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/layer3
	piping_layer = 3
	icon_state = "dpvent_map-3"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/on
	on = TRUE
	icon_state = "dpvent_map_on-2"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/on/layer1
	piping_layer = 1
	icon_state = "dpvent_map_on-1"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/on/layer3
	piping_layer = 3
	icon_state = "dpvent_map_on-3"

#undef EXT_BOUND
#undef INPUT_MIN
#undef OUTPUT_MAX
