/obj/machinery/atmospherics/pipe
	level = 1
	plane = FLOOR_PLANE
	use_power = NO_POWER_USE
	can_unwrench = FALSE
	flags_atom = SHUTTLE_IMMUNE
	var/datum/pipeline/parent = null

	buckle_lying = -1

/obj/machinery/atmospherics/pipe/New()
	. = ..()
	add_atom_colour(pipe_color, FIXED_COLOUR_PRIORITY)

/obj/machinery/atmospherics/pipe/Initialize()
	. = ..()
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)

/obj/machinery/atmospherics/pipe/nullifyNode(i)
	var/obj/machinery/atmospherics/oldN = nodes[i]
	..()
	if(oldN)
		oldN.build_network()

/obj/machinery/atmospherics/pipe/destroy_network()
	QDEL_NULL(parent)

/obj/machinery/atmospherics/pipe/build_network()
	if(QDELETED(parent))
		parent = new
		parent.build_pipeline(src)

/obj/machinery/atmospherics/pipe/atmosinit()
	var/turf/T = loc			// hide if turf is not intact
	hide(T.intact_tile)
	..()

/obj/machinery/atmospherics/pipe/hide(i)
	if(level == 1 && isturf(loc))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
	update_icon()

/obj/machinery/atmospherics/pipe/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/pipe_meter))
		var/obj/item/pipe_meter/meter = I
		user.dropItemToGround(meter)
		meter.setAttachLayer(piping_layer)

/obj/machinery/atmospherics/pipe/returnPipenet()
	return parent

/obj/machinery/atmospherics/pipe/setPipenet(datum/pipeline/P)
	parent = P

/obj/machinery/atmospherics/pipe/Destroy()
	QDEL_NULL(parent)

	var/turf/T = loc
	for(var/obj/machinery/meter/meter in T)
		if(meter.target == src)
			new /obj/item/pipe_meter (T)
			qdel(meter)
	return ..()

/obj/machinery/atmospherics/pipe/update_icon()
	. = ..()
	update_alpha()

/obj/machinery/atmospherics/pipe/proc/update_alpha()
	alpha = invisibility ? 64 : 255

/obj/machinery/atmospherics/pipe/proc/update_node_icon()
	for(var/i in 1 to device_type)
		if(nodes[i])
			var/obj/machinery/atmospherics/N = nodes[i]
			N.update_icon()

/obj/machinery/atmospherics/pipe/returnPipenets()
	. = list(parent)


/obj/machinery/atmospherics/pipe/proc/paint(paint_color)
	add_atom_colour(paint_color, FIXED_COLOUR_PRIORITY)
	pipe_color = paint_color
	update_node_icon()
	return TRUE
