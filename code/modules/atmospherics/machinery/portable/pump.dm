/obj/machinery/portable_atmospherics/pump
	name = "portable air pump"
	icon_state = "psiphon:0"
	density = TRUE

	/// If the pump is on, controls icon_state
	var/on = FALSE
	var/obj/machinery/atmospherics/components/binary/pump/connected_pump

/obj/machinery/portable_atmospherics/pump/Initialize(mapload)
	. = ..()
	connected_pump = new(src, FALSE)
	connected_pump.on = TRUE
	connected_pump.machine_stat = 0
	connected_pump.build_network()

/obj/machinery/portable_atmospherics/pump/Destroy()
	QDEL_NULL(connected_pump)
	return ..()

/obj/machinery/portable_atmospherics/pump/update_icon()
	icon_state = "psiphon:[on]"

	cut_overlays()
	if(holding)
		add_overlay("siphon-open")
	if(connected_port)
		add_overlay("siphon-connector")

/obj/machinery/portable_atmospherics/pump/emp_act(severity)
	. = ..()
	if(!is_operational())
		return
	if(prob(50 / severity))
		on = !on
	connected_pump.target_pressure = rand(0, 100 * ONE_ATMOSPHERE)
	update_icon()
