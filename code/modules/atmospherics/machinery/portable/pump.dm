/obj/machinery/portable_atmospherics/pump
	name = "portable air pump"
	icon_state = "psiphon:0"
	density = TRUE

	/// If the pump is on, controls icon_state
	var/on = FALSE

/obj/machinery/portable_atmospherics/pump/update_icon_state()
	. = ..()
	icon_state = "psiphon:[on]"

/obj/machinery/portable_atmospherics/pump/update_overlays()
	. = ..()

	if(holding)
		. += "siphon-open"
	if(connected_port)
		. += "siphon-connector"

/obj/machinery/portable_atmospherics/pump/emp_act(severity)
	. = ..()
	if(!is_operational())
		return
	if(prob(50 / severity))
		on = !on
	update_icon()
