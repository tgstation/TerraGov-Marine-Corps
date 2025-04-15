//3-Way Manifold

/obj/machinery/atmospherics/pipe/manifold
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold-2"

	name = "pipe manifold"
	desc = "A manifold composed of regular pipes."

	dir = SOUTH
	initialize_directions = EAST|NORTH|WEST

	device_type = TRINARY

	construction_type = /obj/item/pipe/trinary
	pipe_state = "manifold"

	var/mutable_appearance/center

/obj/machinery/atmospherics/pipe/manifold/New()
	. = ..()
	icon_state = ""
	center = mutable_appearance(icon, "manifold_center")

/obj/machinery/atmospherics/pipe/manifold/SetInitDirections()
	initialize_directions = NORTH|SOUTH|EAST|WEST
	initialize_directions &= ~dir

/obj/machinery/atmospherics/pipe/manifold/update_overlays()
	. = ..()

	if(!center)
		center = mutable_appearance(icon, "manifold_center")
	PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
	. += center

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			. += getpipeimage(icon, "pipe-[piping_layer]", get_dir(src, nodes[i]))

	update_layer()
	update_alpha()
