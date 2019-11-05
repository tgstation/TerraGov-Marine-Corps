/**
* Multitool -- A multitool is used for hacking electronic devices.
* TO-DO -- Using it as a power measurement tool for cables etc. Nannek.
*
*/

/obj/item/multitool
	name = "multitool"
	desc = "Used for pulsing wires to test which to cut. Not recommended by doctors."
	icon_state = "multitool"
	flags_atom = CONDUCT
	force = 5.0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	tool_behaviour = TOOL_MULTITOOL

	materials = list(/datum/material/metal = 50, /datum/material/glass = 20)

	var/obj/machinery/telecomms/buffer // simple machine buffer for device linkage
