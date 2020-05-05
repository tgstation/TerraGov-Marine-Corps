#define PUMP_OUT "out"
#define PUMP_IN "in"
#define PUMP_MAX_PRESSURE (ONE_ATMOSPHERE * 25)
#define PUMP_MIN_PRESSURE (ONE_ATMOSPHERE / 10)
#define PUMP_DEFAULT_PRESSURE (ONE_ATMOSPHERE)

/obj/machinery/portable_atmospherics/pump
	name = "portable air pump"
	icon_state = "psiphon:0"
	density = TRUE

	var/on = FALSE
	var/direction = PUMP_OUT
	var/obj/machinery/atmospherics/components/binary/pump/pump

	volume = 1000

/obj/machinery/portable_atmospherics/pump/Initialize()
	. = ..()
	pump = new(src, FALSE)
	pump.on = TRUE
	pump.machine_stat = 0
	pump.build_network()

/obj/machinery/portable_atmospherics/pump/Destroy()
	QDEL_NULL(pump)
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
	if(is_operational())
		if(prob(50 / severity))
			on = !on
		if(prob(100 / severity))
			direction = PUMP_OUT
		pump.target_pressure = rand(0, 100 * ONE_ATMOSPHERE)
		update_icon()
