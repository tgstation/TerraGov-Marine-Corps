// Quick overview:
//
// Pipes combine to form pipelines
// Pipelines and other atmospheric objects combine to form pipe_networks
//   Note: A single pipe_network represents a completely open space
//
// Pipes -> Pipelines
// Pipelines + Other Objects -> Pipe network

#define PIPE_VISIBLE_LEVEL 2
#define PIPE_HIDDEN_LEVEL 1

/obj/machinery/atmospherics
	anchored = TRUE
	move_resist = INFINITY				//Moving a connected machine without actually doing the normal (dis)connection things will probably cause a LOT of issues.
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = ENVIRON
	layer = GAS_PIPE_HIDDEN_LAYER //under wires
	max_integrity = 200
	resistance_flags = RESIST_ALL
	var/can_unwrench = FALSE
	var/initialize_directions = 0
	var/pipe_color
	var/piping_layer = PIPING_LAYER_DEFAULT
	var/pipe_flags = NONE

	var/global/list/iconsetids = list()
	var/global/list/pipeimages = list()

	var/image/pipe_vision_img = null

	var/device_type = 0
	var/list/obj/machinery/atmospherics/nodes

	var/construction_type
	var/pipe_state //icon_state as a pipe item
	var/on = FALSE

	///The bitflag that's being checked on ventcrawling. Default is to allow ventcrawling and seeing pipes.
	var/vent_movement = VENTCRAWL_ALLOWED | VENTCRAWL_CAN_SEE


/obj/machinery/atmospherics/examine(mob/user)
	. = ..()
	if(is_type_in_list(src, GLOB.ventcrawl_machinery) && isliving(user))
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_CAN_VENTCRAWL))
			. += span_notice("Alt-click to crawl through it.")

/obj/machinery/atmospherics/New(loc, process = TRUE, setdir)
	. = ..()
	//this should be in init, but the way our simple pipes have been setup, they'll runtime when apc's init before they do.
	//Someone should propably fully port tg atmos to tgmc
	nodes = new(device_type)
	SetInitDirections()

/obj/machinery/atmospherics/Initialize(mapload, process = TRUE, setdir)
	if(!isnull(setdir))
		setDir(setdir)
	if(pipe_flags & PIPING_CARDINAL_AUTONORMALIZE)
		normalize_cardinal_directions()
	if(process)
		SSair.atmos_machinery += src

	var/turf/turf_loc = null
	if(isturf(loc))
		turf_loc = loc

	SSspatial_grid.add_grid_awareness(src, SPATIAL_GRID_CONTENTS_TYPE_ATMOS)
	SSspatial_grid.add_grid_membership(src, turf_loc, SPATIAL_GRID_CONTENTS_TYPE_ATMOS)
	return ..()

/obj/machinery/atmospherics/Destroy()
	for(var/i in 1 to device_type)
		nullifyNode(i)

	SSair.atmos_machinery -= src

	if(pipe_vision_img)
		qdel(pipe_vision_img)

	return ..()

/obj/machinery/atmospherics/proc/destroy_network()
	return

/obj/machinery/atmospherics/proc/build_network()
	// Called to build a network from this node
	return

/obj/machinery/atmospherics/proc/nullifyNode(i)
	if(nodes[i])
		var/obj/machinery/atmospherics/N = nodes[i]
		N.disconnect(src)
		nodes[i] = null

/obj/machinery/atmospherics/proc/getNodeConnects()
	var/list/node_connects = list()
	node_connects.len = device_type

	for(var/i in 1 to device_type)
		for(var/D in GLOB.cardinals)
			if(D & GetInitDirections())
				if(D in node_connects)
					continue
				node_connects[i] = D
				break
	return node_connects

/obj/machinery/atmospherics/proc/normalize_cardinal_directions()
	switch(dir)
		if(SOUTH)
			setDir(NORTH)
		if(WEST)
			setDir(EAST)

//this is called just after the air controller sets up turfs
/obj/machinery/atmospherics/proc/atmosinit(list/node_connects)
	if(!node_connects) //for pipes where order of nodes doesn't matter
		node_connects = getNodeConnects()

	for(var/i in 1 to device_type)
		for(var/obj/machinery/atmospherics/target in get_step(src,node_connects[i]))
			if(can_be_node(target, i))
				nodes[i] = target
				break
	update_icon()

/obj/machinery/atmospherics/proc/setPipingLayer(new_layer)
	piping_layer = (pipe_flags & PIPING_DEFAULT_LAYER_ONLY) ? PIPING_LAYER_DEFAULT : new_layer
	update_icon()

/obj/machinery/atmospherics/proc/can_be_node(obj/machinery/atmospherics/target, iteration)
	return connection_check(target, piping_layer)

/obj/machinery/atmospherics/proc/connection_check(obj/machinery/atmospherics/target, given_layer)
	if(isConnectable(target, given_layer) && target.isConnectable(src, given_layer) && (target.initialize_directions & get_dir(target,src)))
		return TRUE
	return FALSE

/obj/machinery/atmospherics/proc/isConnectable(obj/machinery/atmospherics/target, given_layer)
	if(isnull(given_layer))
		given_layer = piping_layer
	if((target.piping_layer == given_layer) || (target.pipe_flags & PIPING_ALL_LAYER))
		return TRUE
	return FALSE

/obj/machinery/atmospherics/proc/pipeline_expansion()
	return nodes

/obj/machinery/atmospherics/proc/SetInitDirections()
	return

/obj/machinery/atmospherics/proc/GetInitDirections()
	return initialize_directions

/obj/machinery/atmospherics/proc/returnPipenet()
	return

/obj/machinery/atmospherics/proc/returnPipenetAir()
	return

/obj/machinery/atmospherics/proc/setPipenet()
	return

/obj/machinery/atmospherics/proc/replacePipenet()
	return

/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)
	if(istype(reference, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = reference
		P.destroy_network()
	nodes[nodes.Find(reference)] = null
	update_icon()

/obj/machinery/atmospherics/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pipe)) //lets you autodrop
		var/obj/item/pipe/pipe = I
		if(!user.dropItemToGround(pipe))
			return

		pipe.setPipingLayer(piping_layer) //align it with us
		return TRUE

	return ..()


/obj/machinery/atmospherics/wrench_act(mob/user, obj/item/tool)
	if(!can_unwrench(user))
		return ..()

	var/turf/T = get_turf(src)
	if (level==1 && isturf(T) && T.intact_tile)
		to_chat(user, span_warning("You must remove the plating first!"))
		return TRUE
	to_chat(user, span_notice("You begin to unfasten \the [src]..."))

	if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return TRUE

	user.visible_message( \
		"[user] unfastens \the [src].", \
		span_notice("You unfasten \the [src]."), \
		span_italics("You hear ratchet."))
	deconstruct(TRUE)
	return TRUE

/obj/machinery/atmospherics/proc/can_unwrench(mob/user)
	return can_unwrench

/obj/machinery/atmospherics/deconstruct(disassembled = TRUE, mob/living/blame_mob)
	if(!(atom_flags & NODECONSTRUCT))
		if(can_unwrench)
			var/obj/item/pipe/stored = new construction_type(loc, null, dir, src)
			stored.setPipingLayer(piping_layer)
			if(!disassembled)
				stored.take_damage(stored.max_integrity * 0.5)
	return ..()

/obj/machinery/atmospherics/proc/getpipeimage(iconset, iconstate, direction, col=rgb(255,255,255), piping_layer=2)

	//Add identifiers for the iconset
	if(iconsetids[iconset] == null)
		iconsetids[iconset] = num2text(length(iconsetids) + 1)

	//Generate a unique identifier for this image combination
	var/identifier = iconsetids[iconset] + "_[iconstate]_[direction]_[col]_[piping_layer]"

	if((!(. = pipeimages[identifier])))
		var/image/pipe_overlay
		pipe_overlay = . = pipeimages[identifier] = image(iconset, iconstate, dir = direction)
		pipe_overlay.color = col
		PIPING_LAYER_SHIFT(pipe_overlay, piping_layer)

/obj/machinery/atmospherics/on_construction(obj_color, set_layer)
	if(can_unwrench)
		add_atom_colour(obj_color, FIXED_COLOR_PRIORITY)
		pipe_color = obj_color
	setPipingLayer(set_layer)
	var/turf/T = get_turf(src)
	level = T.intact_tile ? 2 : 1
	atmosinit()
	var/list/nodes = pipeline_expansion()
	for(var/obj/machinery/atmospherics/A in nodes)
		A.atmosinit()
		A.addMember(src)
	build_network()

/**
 * Find a connecting /obj/machinery/atmospherics in specified direction, called by relaymove()
 * used by ventcrawling mobs to check if they can move inside a pipe in a specific direction
 * Arguments:
 * * direction - the direction we are checking against
 * * prompted_layer - the piping_layer we are inside
 */
/obj/machinery/atmospherics/proc/find_connecting(direction, prompted_layer)
	for(var/obj/machinery/atmospherics/target in get_step(src, direction))
		if(!(target.initialize_directions & get_dir(target,src))) //initialize_directions
			continue
		if(connection_check(target, prompted_layer))
			return target

/obj/machinery/atmospherics/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(istype(arrived, /mob/living))
		var/mob/living/L = arrived
		L.ventcrawl_layer = piping_layer
	return ..()

// Handles mob movement inside a pipenet
/obj/machinery/atmospherics/relaymove(mob/living/user, direction)
	if(!direction) //can't go this way.
		return
	if(user in buckled_mobs)
		return

	// We want to support holding two directions at once, so we do this
	var/obj/machinery/atmospherics/target_move
	for(var/canon_direction in GLOB.cardinals_multiz)
		if(!(direction & canon_direction))
			continue
		var/obj/machinery/atmospherics/temp_target = find_connecting(canon_direction, user.ventcrawl_layer)
		if(!temp_target)
			continue
		target_move = temp_target
		// If you're at a fork with two directions held, we will always prefer the direction you didn't last use
		// This way if you find a direction you've not used before, you take it, and if you don't, you take the other
		if(user.last_vent_dir == canon_direction)
			continue
		user.last_vent_dir = canon_direction
		break

	if(!target_move)
		// If we couldn't find a target to move to and we're ventcrawling, try to exit if this vent allows it
		if(HAS_TRAIT(user, TRAIT_MOVE_VENTCRAWLING) && (vent_movement & VENTCRAWL_ENTRANCE_ALLOWED))
			user.handle_ventcrawl(src)
		return

	if(!(target_move.vent_movement & VENTCRAWL_ALLOWED))
		return
	user.forceMove(target_move)
	var/list/pipenetdiff = return_pipenets() ^ target_move.return_pipenets()
	if(pipenetdiff.len)
		user.update_pipe_vision(full_refresh = TRUE)
	var/silent_crawl = FALSE //Some creatures can move through the vents silently
	if(isxeno(user))
		var/mob/living/carbon/xenomorph/xeno_user = user
		silent_crawl = xeno_user.xeno_caste.silent_vent_crawl
	if(!(TIMER_COOLDOWN_RUNNING(user, COOLDOWN_VENTSOUND) || silent_crawl))
		TIMER_COOLDOWN_START(user, COOLDOWN_VENTSOUND, 3 SECONDS)
		playsound(src, pick('sound/effects/alien/ventcrawl1.ogg','sound/effects/alien/ventcrawl2.ogg'), 50, TRUE, -3)

	//Would be great if this could be implemented when someone alt-clicks the image.
	if (target_move.vent_movement & VENTCRAWL_ENTRANCE_ALLOWED)
		user.handle_ventcrawl(target_move)
		return

	var/client/our_client = user.client
	if(!our_client)
		return
	our_client.set_eye(target_move)
	// Let's smooth out that movement with an animate yeah?
	// If the new x is greater (move is left to right) we get a negative offset. vis versa
	our_client.pixel_x = (x - target_move.x) * ICON_SIZE_X
	our_client.pixel_y = (y - target_move.y) * ICON_SIZE_Y
	animate(our_client, pixel_x = 0, pixel_y = 0, time = 0.05 SECONDS)
	our_client.move_delay = world.time + 0.05 SECONDS

/**
 * Getter of a list of pipenets
 *
 * called in relaymove() to create the image for vent crawling
 */
/obj/machinery/atmospherics/proc/return_pipenets()
	return list()

/obj/machinery/atmospherics/update_remote_sight(mob/user)
	if(!(vent_movement & VENTCRAWL_CAN_SEE))
		return
	user.sight |= (SEE_TURFS|BLIND)

/obj/machinery/atmospherics/proc/update_layer()
	layer = initial(layer) + (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE
