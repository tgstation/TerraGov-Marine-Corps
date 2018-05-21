/obj/machinery/atmospherics/unary/generator_input
	icon = 'icons/atmos/heat_exchanger.dmi'
	icon_state = "intact"
	density = 1

	name = "Generator Input"
	desc = "Placeholder"

	var/update_cycle

/obj/machinery/atmospherics/unary/generator_input/update_icon()
	if(node)
		icon_state = "intact"
	else
		icon_state = "exposed"

