/obj/machinery/atmospherics/components/unary/heat_exchanger

	icon_state = "he1"

	name = "heat exchanger"
	desc = "Exchanges heat between two input gases. Set up for fast heat transfer."

	can_unwrench = FALSE
	shift_underlay_only = FALSE // not really used

	layer = LOW_OBJ_LAYER

	var/obj/machinery/atmospherics/components/unary/heat_exchanger/partner = null
	var/update_cycle

	pipe_state = "heunary"

/obj/machinery/atmospherics/components/unary/heat_exchanger/layer1
	piping_layer = 1
	icon_state = "he_map-1"

/obj/machinery/atmospherics/components/unary/heat_exchanger/layer3
	piping_layer = 3
	icon_state = "he_map-3"

/obj/machinery/atmospherics/components/unary/heat_exchanger/update_icon()
	if(nodes[1])
		icon_state = "he1"
		var/obj/machinery/atmospherics/node = nodes[1]
		add_atom_colour(node.color, FIXED_COLOUR_PRIORITY)
	else
		icon_state = "he0"
	PIPING_LAYER_SHIFT(src, piping_layer)

/obj/machinery/atmospherics/components/unary/heat_exchanger/atmosinit()
	if(!partner)
		var/partner_connect = REVERSE_DIR(dir)

		for(var/obj/machinery/atmospherics/components/unary/heat_exchanger/target in get_step(src,partner_connect))
			if(target.dir & get_dir(src,target))
				partner = target
				partner.partner = src
				break

	..()
