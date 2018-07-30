/obj/machinery/atmospherics/unary/oxygen_generator
	icon = 'icons/atmos/oxygen_generator.dmi'
	icon_state = "intact_off"
	density = 1
	name = "Oxygen Generator"
	desc = ""
	dir = SOUTH
	initialize_directions = SOUTH
	var/on = 0
	var/oxygen_content = 10

/obj/machinery/atmospherics/unary/oxygen_generator/update_icon()
	if(node)
		icon_state = "intact_[on?("on"):("off")]"
	else
		icon_state = "exposed_off"
		on = 0

/obj/machinery/atmospherics/unary/oxygen_generator/process()
	..()
	if(!on)
		return 0

	return 1