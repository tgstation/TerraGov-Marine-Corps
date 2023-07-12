/obj/machinery/portable_atmospherics/scrubber
	name = "portable air scrubber"
	icon_state = "pscrubber:0"
	density = TRUE

	/// If we're on/off. Purely cosmetic, just a different icon.
	var/on = FALSE

/obj/machinery/portable_atmospherics/scrubber/attack_hand(mob/living/user)
	. = ..()
	on = !on
	balloon_alert(user, "You turn [src] [on ? "on" : "off"]")
	update_icon()

/obj/machinery/portable_atmospherics/scrubber/update_icon_state()
	. = ..()
	icon_state = "pscrubber:[on]"

/obj/machinery/portable_atmospherics/scrubber/update_overlays()
	. = ..()

	cut_overlays()
	if(holding)
		add_overlay("scrubber-open")
	if(connected_port)
		add_overlay("scrubber-connector")

/obj/machinery/portable_atmospherics/scrubber/emp_act(severity)
	. = ..()

	if(!is_operational())
		return
	if(prob(50 / severity))
		on = !on
	update_icon()

/obj/machinery/portable_atmospherics/scrubber/huge
	name = "huge air scrubber"
	icon_state = "scrubber:0"
	anchored = TRUE
	active_power_usage = 500
	idle_power_usage = 10

/obj/machinery/portable_atmospherics/scrubber/huge/movable
	anchored = FALSE

/obj/machinery/portable_atmospherics/scrubber/huge/update_icon_state()
	. = ..()
	icon_state = "scrubber:[on]"
