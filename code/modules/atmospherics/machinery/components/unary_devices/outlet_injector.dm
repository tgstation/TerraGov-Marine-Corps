/obj/machinery/atmospherics/components/unary/outlet_injector
	icon_state = "inje_map-2"

	name = "air injector"
	desc = "Has a valve and pump attached to it."

	use_power = IDLE_POWER_USE
	can_unwrench = FALSE
	shift_underlay_only = FALSE

	resistance_flags = UNACIDABLE

	var/injecting = 0

	var/volume_rate = 50

	var/id = null

	level = 1
	layer = ATMOS_DEVICE_LAYER

	pipe_state = "injector"


/obj/machinery/atmospherics/components/unary/outlet_injector/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		// everything is already shifted so don't shift the cap
		add_overlay(getpipeimage(icon, "inje_cap", initialize_directions))

	if(!nodes[1] || !on || !is_operational())
		icon_state = "inje_off"
	else
		icon_state = "inje_on"

/obj/machinery/atmospherics/components/unary/outlet_injector/power_change()
	var/old_stat = machine_stat
	..()
	if(old_stat != machine_stat)
		update_icon()


/obj/machinery/atmospherics/components/unary/outlet_injector/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational())
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first!"))
		return FALSE

// mapping

/obj/machinery/atmospherics/components/unary/outlet_injector/layer1
	piping_layer = 1
	icon_state = "inje_map-1"

/obj/machinery/atmospherics/components/unary/outlet_injector/layer3
	piping_layer = 2
	icon_state = "inje_map-2"

/obj/machinery/atmospherics/components/unary/outlet_injector/on
	on = TRUE

/obj/machinery/atmospherics/components/unary/outlet_injector/on/layer1
	piping_layer = 1
	icon_state = "inje_map-1"

/obj/machinery/atmospherics/components/unary/outlet_injector/on/layer3
	piping_layer = 2
	icon_state = "inje_map-2"

/obj/machinery/atmospherics/components/unary/outlet_injector/atmos
	on = TRUE
	volume_rate = 200

/obj/machinery/atmospherics/components/unary/outlet_injector/atmos/atmos_waste
	name = "atmos waste outlet injector"

/obj/machinery/atmospherics/components/unary/outlet_injector/atmos/engine_waste
	name = "engine outlet injector"

/obj/machinery/atmospherics/components/unary/outlet_injector/atmos/toxin_input
	name = "plasma tank input injector"

/obj/machinery/atmospherics/components/unary/outlet_injector/atmos/oxygen_input
	name = "oxygen tank input injector"

/obj/machinery/atmospherics/components/unary/outlet_injector/atmos/nitrogen_input
	name = "nitrogen tank input injector"

/obj/machinery/atmospherics/components/unary/outlet_injector/atmos/mix_input
	name = "mix tank input injector"

/obj/machinery/atmospherics/components/unary/outlet_injector/atmos/nitrous_input
	name = "nitrous oxide tank input injector"

/obj/machinery/atmospherics/components/unary/outlet_injector/atmos/air_input
	name = "air mix tank input injector"

/obj/machinery/atmospherics/components/unary/outlet_injector/atmos/carbon_input
	name = "carbon dioxide tank input injector"

/obj/machinery/atmospherics/components/unary/outlet_injector/atmos/incinerator_input
	name = "incinerator chamber input injector"

/obj/machinery/atmospherics/components/unary/outlet_injector/atmos/toxins_mixing_input
	name = "toxins mixing input injector"
