// So much of atmospherics.dm was used solely by components, so separating this makes things all a lot cleaner.
// On top of that, now people can add component-speciic procs/vars if they want!

/obj/machinery/atmospherics/components
	var/welded = FALSE //Used on pumps and scrubbers
	var/showpipe = FALSE
	var/shift_underlay_only = TRUE //Layering only shifts underlay?

	var/list/datum/pipeline/parents

/obj/machinery/atmospherics/components/New()
	. = ..()
	parents = new(device_type)

// Iconnery

/obj/machinery/atmospherics/components/proc/update_icon_nopipes()
	return

/obj/machinery/atmospherics/components/update_icon()
	update_icon_nopipes()

	underlays.Cut()

	var/turf/T = loc
	if(level == 2 || (!T.intact_tile && !istype(T, /turf/open/floor/plating/plating_catwalk)))
		showpipe = TRUE
		plane = GAME_PLANE
	else
		showpipe = FALSE
		plane = FLOOR_PLANE

	if(!showpipe)
		return ..()

	var/connected = 0 //Direction bitset

	if(nodes)
		for(var/i in 1 to device_type) //adds intact pieces
			if(nodes[i])
				var/obj/machinery/atmospherics/node = nodes[i]
				var/image/img = get_pipe_underlay("pipe_intact", get_dir(src, node), node.pipe_color)
				underlays += img
				connected |= img.dir

	for(var/direction in GLOB.cardinals)
		if((initialize_directions & direction) && !(connected & direction))
			underlays += get_pipe_underlay("pipe_exposed", direction)

	if(!shift_underlay_only)
		PIPING_LAYER_SHIFT(src, piping_layer)
	return ..()

/obj/machinery/atmospherics/components/proc/get_pipe_underlay(state, dir, color = null)
	if(color)
		. = getpipeimage('icons/obj/atmospherics/components/binary_devices.dmi', state, dir, color, piping_layer = shift_underlay_only ? piping_layer : 2)
	else
		. = getpipeimage('icons/obj/atmospherics/components/binary_devices.dmi', state, dir, piping_layer = shift_underlay_only ? piping_layer : 2)

// Pipenet stuff; housekeeping

/obj/machinery/atmospherics/components/nullifyNode(i)
	if(parents[i])
		nullifyPipenet(parents[i])
	..()

/obj/machinery/atmospherics/components/on_construction()
	..()
	update_parents()

/obj/machinery/atmospherics/components/build_network()
	for(var/i in 1 to device_type)
		if(!parents[i])
			parents[i] = new /datum/pipeline()
			var/datum/pipeline/P = parents[i]
			P.build_pipeline(src)

/obj/machinery/atmospherics/components/proc/nullifyPipenet(datum/pipeline/reference)
	if(!reference)
		CRASH("nullifyPipenet(null) called by [type] on [COORD(src)]")
	var/i = parents.Find(reference)
	reference.other_atmosmch -= src
	parents[i] = null

/obj/machinery/atmospherics/components/pipeline_expansion(datum/pipeline/reference)
	if(reference)
		return list(nodes[parents.Find(reference)])
	return ..()

/obj/machinery/atmospherics/components/setPipenet(datum/pipeline/reference, obj/machinery/atmospherics/A)
	parents[nodes.Find(A)] = reference

/obj/machinery/atmospherics/components/returnPipenet(obj/machinery/atmospherics/A = nodes[1]) //returns parents[1] if called without argument
	return parents[nodes.Find(A)]

/obj/machinery/atmospherics/components/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	parents[parents.Find(Old)] = New

// Helpers

/obj/machinery/atmospherics/components/proc/update_parents()
	for(var/i in 1 to device_type)
		var/datum/pipeline/parent = parents[i]
		if(!parent)
			throw EXCEPTION("Component is missing a pipenet! Rebuilding...")
			build_network()
		parent.update = 1

/obj/machinery/atmospherics/components/returnPipenets()
	. = list()
	for(var/i in 1 to device_type)
		. += returnPipenet(nodes[i])
