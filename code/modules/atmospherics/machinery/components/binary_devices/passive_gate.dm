/*

Passive gate is similar to the regular pump except:
* It doesn't require power
* Can not transfer low pressure to higher pressure (so it's more like a valve where you can control the flow)

*/

/obj/machinery/atmospherics/components/binary/passive_gate
	icon_state = "passgate_map-2"

	name = "passive gate"
	desc = "A one-way air valve that does not require power."

	can_unwrench = FALSE
	shift_underlay_only = FALSE

	var/target_pressure = ONE_ATMOSPHERE

	var/id = null

	construction_type = /obj/item/pipe/directional
	pipe_state = "passivegate"

/obj/machinery/atmospherics/components/binary/passive_gate/update_icon_nopipes()
	cut_overlays()
	icon_state = "passgate_off"
	if(on)
		add_overlay(getpipeimage(icon, "passgate_on"))

/obj/machinery/atmospherics/components/binary/passive_gate/can_unwrench(mob/user)
	. = ..()
	if(. && on)
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first!"))
		return FALSE


/obj/machinery/atmospherics/components/binary/passive_gate/layer1
	piping_layer = 1
	icon_state = "passgate_map-1"

/obj/machinery/atmospherics/components/binary/passive_gate/layer3
	piping_layer = 3
	icon_state = "passgate_map-3"
