/obj/machinery/atmospherics/components/trinary/mixer
	icon_state = "mixer_off"
	density = FALSE

	name = "gas mixer"
	desc = "Very useful for mixing gasses."

	can_unwrench = FALSE

	var/target_pressure = ONE_ATMOSPHERE
	var/node1_concentration = 0.5
	var/node2_concentration = 0.5

	construction_type = /obj/item/pipe/trinary/flippable
	pipe_state = "mixer"

	//node 3 is the outlet, nodes 1 & 2 are intakes

/obj/machinery/atmospherics/components/trinary/mixer/update_icon()
	cut_overlays()
	for(var/direction in GLOB.cardinals)
		if(!(direction & initialize_directions))
			continue
		var/obj/machinery/atmospherics/node = findConnecting(direction)

		var/image/cap
		if(node)
			cap = getpipeimage(icon, "cap", direction, node.pipe_color, piping_layer = piping_layer)
		else
			cap = getpipeimage(icon, "cap", direction, piping_layer = piping_layer)

		add_overlay(cap)

	return ..()

/obj/machinery/atmospherics/components/trinary/mixer/update_icon_nopipes()
	var/on_state = on && nodes[1] && nodes[2] && nodes[3] && is_operational()
	icon_state = "mixer_[on_state ? "on" : "off"][flipped ? "_f" : ""]"

/obj/machinery/atmospherics/components/trinary/mixer/power_change()
	var/old_stat = machine_stat
	..()
	if(machine_stat != old_stat)
		update_icon()

/obj/machinery/atmospherics/components/trinary/mixer/proc/adjust_node1_value(delta)
	node1_concentration = round(max(0, min(1, node1_concentration + delta)), 0.01)
	node2_concentration = 1 - node1_concentration

/obj/machinery/atmospherics/components/trinary/mixer/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational())
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first!"))
		return FALSE

// mapping

/obj/machinery/atmospherics/components/trinary/mixer/layer1
	piping_layer = 1
	icon_state = "mixer_off_map-1"
/obj/machinery/atmospherics/components/trinary/mixer/layer3
	piping_layer = 3
	icon_state = "mixer_off_map-3"

/obj/machinery/atmospherics/components/trinary/mixer/on
	on = TRUE
	icon_state = "mixer_on"

/obj/machinery/atmospherics/components/trinary/mixer/on/layer1
	piping_layer = 1
	icon_state = "mixer_on_map-1"
/obj/machinery/atmospherics/components/trinary/mixer/on/layer3
	piping_layer = 3
	icon_state = "mixer_on_map-3"

/obj/machinery/atmospherics/components/trinary/mixer/flipped
	icon_state = "mixer_off_f"
	flipped = TRUE

/obj/machinery/atmospherics/components/trinary/mixer/flipped/layer1
	piping_layer = 1
	icon_state = "mixer_off_f_map-1"
/obj/machinery/atmospherics/components/trinary/mixer/flipped/layer3
	piping_layer = 3
	icon_state = "mixer_off_f_map-3"

/obj/machinery/atmospherics/components/trinary/mixer/flipped/on
	on = TRUE
	icon_state = "mixer_on_f"

/obj/machinery/atmospherics/components/trinary/mixer/flipped/on/layer1
	piping_layer = 1
	icon_state = "mixer_on_f_map-1"
/obj/machinery/atmospherics/components/trinary/mixer/flipped/on/layer3
	piping_layer = 3
	icon_state = "mixer_on_f_map-3"

/obj/machinery/atmospherics/components/trinary/mixer/airmix //For standard airmix to distro
	name = "air mixer"
	icon_state = "mixer_on"
	node1_concentration = N2STANDARD
	node2_concentration = O2STANDARD
	target_pressure = MAX_OUTPUT_PRESSURE
	on = TRUE

/obj/machinery/atmospherics/components/trinary/mixer/airmix/inverse
	node1_concentration = O2STANDARD
	node2_concentration = N2STANDARD

/obj/machinery/atmospherics/components/trinary/mixer/airmix/flipped
	icon_state = "mixer_on_f"
	flipped = TRUE

/obj/machinery/atmospherics/components/trinary/mixer/airmix/flipped/inverse
	node1_concentration = O2STANDARD
	node2_concentration = N2STANDARD
