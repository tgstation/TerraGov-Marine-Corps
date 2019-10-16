/*
It's like a regular ol' straight pipe, but you can turn it on and off.
*/

/obj/machinery/atmospherics/components/binary/valve
	icon_state = "mvalve_map-2"

	name = "manual valve"
	desc = "A pipe with a valve that can be used to disable flow of gas through it."

	can_unwrench = FALSE
	shift_underlay_only = FALSE
	pipe_flags = PIPING_CARDINAL_AUTONORMALIZE

	var/id = null

	var/valve_type = "m" //lets us have a nice, clean, OOP update_icon_nopipes()

	construction_type = /obj/item/pipe/binary
	pipe_state = "mvalve"

	var/switching = FALSE

/obj/machinery/atmospherics/components/binary/valve/update_icon_nopipes(animation = FALSE)
	normalize_cardinal_directions()
	if(animation)
		flick("[valve_type]valve_[on][!on]", src)
	icon_state = "[valve_type]valve_[on ? "on" : "off"]"

/obj/machinery/atmospherics/components/binary/valve/proc/toggle()
	if(on)
		on = FALSE
		update_icon_nopipes()
	else
		on = TRUE
		update_icon_nopipes()
		update_parents()

/obj/machinery/atmospherics/components/binary/valve/interact(mob/user)
	if(switching)
		return
	update_icon_nopipes(TRUE)
	switching = TRUE
	addtimer(CALLBACK(src, .proc/finish_interact), 10)

/obj/machinery/atmospherics/components/binary/valve/proc/finish_interact()
	toggle()
	switching = FALSE


/obj/machinery/atmospherics/components/binary/valve/digital // can be controlled by AI
	icon_state = "dvalve_map-2"

	name = "digital valve"
	desc = "A digitally controlled valve."
	valve_type = "d"
	pipe_state = "dvalve"


/obj/machinery/atmospherics/components/binary/valve/digital/update_icon_nopipes(animation)
	if(!is_operational())
		normalize_cardinal_directions()
		icon_state = "dvalve_nopower"
		return
	..()


/obj/machinery/atmospherics/components/binary/valve/layer1
	piping_layer = 1
	icon_state = "mvalve_map-1"

/obj/machinery/atmospherics/components/binary/valve/layer3
	piping_layer = 3
	icon_state = "mvalve_map-3"

/obj/machinery/atmospherics/components/binary/valve/on
	on = TRUE

/obj/machinery/atmospherics/components/binary/valve/on/layer1
	piping_layer = 1
	icon_state = "mvalve_map-1"

/obj/machinery/atmospherics/components/binary/valve/on/layer3
	piping_layer = 3
	icon_state = "mvalve_map-3"

/obj/machinery/atmospherics/components/binary/valve/digital/layer1
	piping_layer = 1
	icon_state = "dvalve_map-1"

/obj/machinery/atmospherics/components/binary/valve/digital/layer3
	piping_layer = 3
	icon_state = "dvalve_map-3"

/obj/machinery/atmospherics/components/binary/valve/digital/on
	on = TRUE

/obj/machinery/atmospherics/components/binary/valve/digital/on/layer1
	piping_layer = 1
	icon_state = "dvalve_map-1"

/obj/machinery/atmospherics/components/binary/valve/digital/on/layer3
	piping_layer = 3
	icon_state = "dvalve_map-3"
