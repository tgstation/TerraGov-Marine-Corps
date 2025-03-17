/obj/machinery/atmospherics/pipe/heat_exchanging
	level = 2
	var/minimum_temperature_difference = 20
	var/thermal_conductivity = WINDOW_HEAT_TRANSFER_COEFFICIENT
	color = "#404040"
	buckle_lying = -1
	var/icon_temperature = T20C //stop small changes in temperature causing icon refresh

/obj/machinery/atmospherics/pipe/heat_exchanging/New()
	. = ..()
	add_atom_colour("#404040", FIXED_COLOR_PRIORITY)

/obj/machinery/atmospherics/pipe/heat_exchanging/isConnectable(obj/machinery/atmospherics/pipe/heat_exchanging/target, given_layer, HE_type_check = TRUE)
	if(istype(target, /obj/machinery/atmospherics/pipe/heat_exchanging) != HE_type_check)
		return FALSE
	. = ..()

/obj/machinery/atmospherics/pipe/heat_exchanging/hide()
	return
