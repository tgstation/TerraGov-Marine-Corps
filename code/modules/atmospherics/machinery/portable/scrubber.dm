/obj/machinery/portable_atmospherics/scrubber
	name = "portable air scrubber"
	icon_state = "pscrubber:0"
	density = TRUE

	var/on = FALSE
	var/volume_rate = 1000
	volume = 1000

	var/list/scrubbing = list()

/obj/machinery/portable_atmospherics/scrubber/update_icon()
	icon_state = "pscrubber:[on]"

	cut_overlays()
	if(holding)
		add_overlay("scrubber-open")
	if(connected_port)
		add_overlay("scrubber-connector")

/obj/machinery/portable_atmospherics/scrubber/emp_act(severity)
	. = ..()
	if(is_operational())
		if(prob(50 / severity))
			on = !on
		update_icon()

/obj/machinery/portable_atmospherics/scrubber/huge
	name = "huge air scrubber"
	icon_state = "scrubber:0"
	anchored = TRUE
	active_power_usage = 500
	idle_power_usage = 10

	volume_rate = 1500
	volume = 50000

	var/movable = FALSE

/obj/machinery/portable_atmospherics/scrubber/huge/movable
	movable = TRUE

/obj/machinery/portable_atmospherics/scrubber/huge/update_icon()
	icon_state = "scrubber:[on]"
