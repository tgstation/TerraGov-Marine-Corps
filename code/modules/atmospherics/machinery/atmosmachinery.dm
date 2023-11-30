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

	///Whether we get pipenet vision while inside or just see normally.
	var/can_see_pipes = TRUE

/obj/machinery/atmospherics/examine(mob/user)
	. = ..()
	if(is_type_in_list(src, GLOB.ventcrawl_machinery) && isliving(user))
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_CAN_VENTCRAWL))
			. += span_notice("Alt-click to crawl through it.")

/obj/machinery/atmospherics/New(loc, process = TRUE, setdir)
	. = ..()
	if(!isnull(setdir))
		setDir(setdir)
	if(pipe_flags & PIPING_CARDINAL_AUTONORMALIZE)
		normalize_cardinal_directions()
	nodes = new(device_type)
	if(process)
		SSair.atmos_machinery += src
	SetInitDirections()

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

//Find a connecting /obj/machinery/atmospherics in specified direction
/obj/machinery/atmospherics/proc/findConnecting(direction, prompted_layer)
	for(var/obj/machinery/atmospherics/target in get_step(src, direction))
		if(target.initialize_directions & get_dir(target,src))
			if(connection_check(target, prompted_layer))
				return target

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


/obj/machinery/atmospherics/wrench_act(mob/living/user, obj/item/I)
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

/obj/machinery/atmospherics/deconstruct(disassembled = TRUE)
	if(!(flags_atom & NODECONSTRUCT))
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
		add_atom_colour(obj_color, FIXED_COLOUR_PRIORITY)
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

/obj/machinery/atmospherics/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(istype(arrived, /mob/living))
		var/mob/living/L = arrived
		L.ventcrawl_layer = piping_layer
	return ..()


/obj/machinery/atmospherics/proc/climb_out(mob/living/user, turf/T)
	if(T.density)
		to_chat(user, span_notice("You cannot climb out, the exit is blocked!"))
		return
	if(TIMER_COOLDOWN_CHECK(user, COOLDOWN_VENTCRAWL))
		return FALSE
	var/silent_crawl = FALSE
	var/vent_crawl_exit_time = 2 SECONDS
	if(isxeno(user))
		var/mob/living/carbon/xenomorph/X = user
		silent_crawl = X.xeno_caste.silent_vent_crawl
		vent_crawl_exit_time = X.xeno_caste.vent_exit_speed
	TIMER_COOLDOWN_START(user, COOLDOWN_VENTCRAWL, vent_crawl_exit_time)
	if(!silent_crawl) //Xenos with silent crawl can silently enter/exit/move through vents.
		visible_message(span_warning("You hear something squeezing through the ducts."))
	to_chat(user, span_notice("You begin to climb out of [src]"))
	if(!do_after(user, vent_crawl_exit_time, IGNORE_HELD_ITEM, src))
		return FALSE
	user.remove_ventcrawl()
	user.forceMove(T)
	user.visible_message(span_warning("[user] climbs out of [src].</span>"), \
	span_notice("You climb out of [src].</span>"))
	if(!silent_crawl)
		playsound(src, get_sfx("alien_ventpass"), 35, TRUE)


/obj/machinery/atmospherics/relaymove(mob/living/user, direction)
	direction &= initialize_directions
	if(!direction || !(direction in GLOB.cardinals)) //cant go this way.
		return

	var/obj/machinery/atmospherics/target_move = findConnecting(direction, user.ventcrawl_layer)
	if(target_move)
		if(target_move.can_crawl_through())
			if(is_type_in_typecache(target_move, GLOB.ventcrawl_machinery))
				climb_out(user, target_move.loc)
			else

				// Check for impassable types
				var/obj/effect/forcefield/fog/impassable = locate() in get_turf(target_move)
				if(impassable)
					return

				user.forceMove(target_move)
				user.update_pipe_vision()
				user.client.eye = target_move  //Byond only updates the eye every tick, This smooths out the movement
				var/silent_crawl = FALSE //Some creatures can move through the vents silently
				if(isxeno(user))
					var/mob/living/carbon/xenomorph/X = user
					silent_crawl = X.xeno_caste.silent_vent_crawl
				if(TIMER_COOLDOWN_CHECK(user, COOLDOWN_VENTSOUND) || silent_crawl)
					return
				TIMER_COOLDOWN_START(user, COOLDOWN_VENTSOUND, 3 SECONDS)
				playsound(src, pick('sound/effects/alien_ventcrawl1.ogg','sound/effects/alien_ventcrawl2.ogg'), 50, TRUE, -3)
	else if((direction & initialize_directions) || is_type_in_typecache(src, GLOB.ventcrawl_machinery) && can_crawl_through()) //if we move in a way the pipe can connect, but doesn't - or we're in a vent
		climb_out(user, src.loc)

	//PLACEHOLDER COMMENT FOR ME TO READD THE 1 (?) DS DELAY THAT WAS IMPLEMENTED WITH A... TIMER?


/obj/machinery/atmospherics/proc/can_crawl_through()
	return TRUE

/obj/machinery/atmospherics/proc/returnPipenets()
	return list()

/obj/machinery/atmospherics/update_remote_sight(mob/user)
	if(!can_see_pipes)
		return
	user.sight |= (SEE_TURFS|BLIND)

/obj/machinery/atmospherics/proc/update_layer()
	layer = initial(layer) + (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE
