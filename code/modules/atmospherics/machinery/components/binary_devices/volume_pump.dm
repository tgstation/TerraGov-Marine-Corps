// Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.
//
// node1, air1, network1 correspond to input
// node2, air2, network2 correspond to output
//
// Thus, the two variables affect pump operation are set in New():
//   air1.volume
//     This is the volume of gas available to the pump that may be transfered to the output
//   air2.volume
//     Higher quantities of this cause more air to be perfected later
//     but overall network volume is also increased as this increases...

/obj/machinery/atmospherics/components/binary/volume_pump
	icon_state = "volpump_map-2"
	name = "volumetric gas pump"
	desc = "A pump that moves gas by volume."

	can_unwrench = FALSE
	shift_underlay_only = FALSE

	var/transfer_rate = MAX_TRANSFER_RATE

	var/id = null

	construction_type = /obj/item/pipe/directional
	pipe_state = "volumepump"


/obj/machinery/atmospherics/components/binary/volume_pump/update_icon_nopipes()
	icon_state = on && is_operational() ? "volpump_on" : "volpump_off"


/obj/machinery/atmospherics/components/binary/volume_pump/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational())
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first!"))
		return FALSE

// mapping

/obj/machinery/atmospherics/components/binary/volume_pump/layer1
	piping_layer = 1
	icon_state = "volpump_map-1"

/obj/machinery/atmospherics/components/binary/volume_pump/layer3
	piping_layer = 3
	icon_state = "volpump_map-3"

/obj/machinery/atmospherics/components/binary/volume_pump/on
	on = TRUE
	icon_state = "volpump_on_map"

/obj/machinery/atmospherics/components/binary/volume_pump/on/layer1
	piping_layer = 1
	icon_state = "volpump_map-1"

/obj/machinery/atmospherics/components/binary/volume_pump/on/layer3
	piping_layer = 3
	icon_state = "volpump_map-3"
