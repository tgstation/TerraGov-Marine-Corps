/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network

*/
/obj/machinery/atmospherics
	anchored = 1
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = ENVIRON
	var/nodealert = 0

	layer = ATMOS_DEVICE_LAYER

	var/connect_types[] = list(1) //1=regular, 2=supply, 3=scrubber
	var/connected_to = 1 //same as above, currently not used for anything
	var/icon_connect_type = "" //"-supply" or "-scrubbers"

	var/initialize_directions = 0
	var/pipe_color

	var/image/pipe_vision_img = null

	var/global/datum/pipe_icon_manager/icon_manager

	var/ventcrawl_message_busy = 0 //Prevent spamming

/obj/machinery/atmospherics/New()
	if(!icon_manager)
		icon_manager = new()

	if(!pipe_color)
		pipe_color = color
	color = null

	if(!pipe_color_check(pipe_color))
		pipe_color = null

	if(pipe_vision_img)
		qdel(pipe_vision_img)
		pipe_vision_img = null

	start_processing()
	return ..()

/obj/machinery/atmospherics/Initialize()
	. = ..()
	if(initialize() == INITIALIZE_HINT_QDEL)
		return INITIALIZE_HINT_QDEL

/obj/machinery/atmospherics/Destroy()
	for(var/mob/living/M in src) //ventcrawling is serious business
		M.remove_ventcrawl()
		M.forceMove(loc)
	if(contents.len)
		for(var/atom/movable/A in contents)
			A.forceMove(loc)
	stop_processing()
	. = ..()

/obj/machinery/atmospherics/proc/initialize() // temporary until someone unfucks atmos
	return

/obj/machinery/atmospherics/power_change()
	return // overriding this for pipes etc, powered stuff overrides this.

/obj/machinery/atmospherics/attackby(atom/A, mob/user as mob)
	if(istype(A, /obj/item/device/pipe_painter))
		return
	..()

/obj/machinery/atmospherics/proc/add_underlay(var/turf/T, var/obj/machinery/atmospherics/node, var/direction, var/icon_connect_type)
	if(node)
		if(T.intact_tile && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe))
			//underlays += icon_manager.get_atmos_icon("underlay_down", direction, color_cache_name(node))
			underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "down" + icon_connect_type)
		else
			//underlays += icon_manager.get_atmos_icon("underlay_intact", direction, color_cache_name(node))
			underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "intact" + icon_connect_type)
	else
		//underlays += icon_manager.get_atmos_icon("underlay_exposed", direction, pipe_color)
		underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "exposed" + icon_connect_type)

/obj/machinery/atmospherics/proc/update_underlays()
	if(check_icon_cache())
		return 1
	else
		return 0

obj/machinery/atmospherics/proc/check_connect_types(obj/machinery/atmospherics/atmos1, obj/machinery/atmospherics/atmos2)
	var/i
	var/list1[] = atmos1.connect_types
	var/list2[] = atmos2.connect_types
	for(i=1,i<=list1.len,i++)
		var/j
		for(j=1,j<=list2.len,j++)
			if(list1[i] == list2[j])
				var/n = list1[i]
				return n
	return 0

obj/machinery/atmospherics/proc/check_connect_types_construction(obj/machinery/atmospherics/atmos1, obj/item/pipe/pipe2)
	var/i
	var/list1[] = atmos1.connect_types
	var/list2[] = pipe2.connect_types
	for(i=1,i<=list1.len,i++)
		var/j
		for(j=1,j<=list2.len,j++)
			if(list1[i] == list2[j])
				var/n = list1[i]
				return n
	return 0


/obj/machinery/atmospherics/proc/check_icon_cache(var/safety = 0)
	if(!istype(icon_manager))
		if(!safety) //to prevent infinite loops
			icon_manager = new()
			check_icon_cache(1)
		return 0

	return 1

/obj/machinery/atmospherics/proc/color_cache_name(var/obj/machinery/atmospherics/node)
	//Don't use this for standard pipes
	if(!istype(node))
		return null

	return node.pipe_color

/obj/machinery/atmospherics/process()
	build_network()
	stop_processing()

/obj/machinery/atmospherics/proc/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	// Check to see if should be added to network. Add self if so and adjust variables appropriately.
	// Note don't forget to have neighbors look as well!

	return null

/obj/machinery/atmospherics/proc/build_network()
	// Called to build a network from this node

	return null

/obj/machinery/atmospherics/proc/return_network(obj/machinery/atmospherics/reference)
	// Returns pipe_network associated with connection to reference
	// Notes: should create network if necessary
	// Should never return null

	return null

/obj/machinery/atmospherics/proc/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	// Used when two pipe_networks are combining

/obj/machinery/atmospherics/proc/return_network_air(datum/network/reference)
	return

/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)

/obj/machinery/atmospherics/update_icon()
	return null

#define VENT_SOUND_DELAY 20

/obj/machinery/atmospherics/relaymove(mob/living/user, direction)
	if(!(direction & initialize_directions)) //can't go in a way we aren't connecting to
		return

	var/obj/machinery/atmospherics/target_move = findConnecting(direction)
	if(target_move)
		if(is_type_in_list(target_move, ventcrawl_machinery) && target_move.can_crawl_through())
			if(ventcrawl_message_busy > world.time)
				return
			ventcrawl_message_busy = world.time + 20
			if(!istype(user,/mob/living/carbon/Xenomorph/Hunter))
				target_move.visible_message("<span class='warning'>You hear something squeezing through the ducts.</span>")
			to_chat(user, "<span class='notice'>You begin to climb out of [target_move]</span>")
			if(do_after(user, 20, FALSE))
				user.remove_ventcrawl()
				user.forceMove(target_move.loc) //handles entering and so on
				user.visible_message("<span class='warning'>[user] climbs out of [target_move].</span>", \
				"<span class='notice'>You climb out of [target_move].</span>")
				if(!istype(user,/mob/living/carbon/Xenomorph/Hunter)) //Hunters silently enter/exit vents.
					pick(playsound(user, 'sound/effects/alien_ventpass1.ogg', 35, 1), playsound(user, 'sound/effects/alien_ventpass2.ogg', 35, 1))
		else if(target_move.can_crawl_through())
			user.loc = target_move
			user.client.eye = target_move //if we don't do this, Byond only updates the eye every tick - required for smooth movement
			if(world.time - user.last_played_vent > VENT_SOUND_DELAY && !istype(user,/mob/living/carbon/Xenomorph/Hunter) ) //Hunters silently enter/exit/move through vents.
				user.last_played_vent = world.time
				pick(playsound(src, 'sound/effects/alien_ventcrawl1.ogg', 25, 1), playsound(src, 'sound/effects/alien_ventcrawl2.ogg', 25, 1))
	else
		if((direction & initialize_directions) || is_type_in_list(src, ventcrawl_machinery) && can_crawl_through()) //if we move in a way the pipe can connect, but doesn't - or we're in a vent
			if(ventcrawl_message_busy > world.time)
				return
			ventcrawl_message_busy = world.time + 20
			if(!istype(user,/mob/living/carbon/Xenomorph/Hunter) ) //Hunters silently enter/exit/move through vents.
				visible_message("<span class='warning'>You hear something squeezing through the ducts.</span>")
			to_chat(user, "<span class='notice'>You begin to climb out of [src]</span>")
			if(do_after(user, 20, FALSE))
				user.remove_ventcrawl()
				user.forceMove(src.loc)
				user.visible_message("<span class='warning'>[user] climbs out of [src].</span>", \
				"<span class='notice'>You climb out of [src].</span>")
				if(!istype(user,/mob/living/carbon/Xenomorph/Hunter) )
					pick(playsound(user, 'sound/effects/alien_ventpass1.ogg', 35, 1), playsound(user, 'sound/effects/alien_ventpass2.ogg', 35, 1))
	user.canmove = 0
	spawn(1)
		user.canmove = 1

/obj/machinery/atmospherics/proc/can_crawl_through()
	return 1

//Find a connecting /obj/machinery/atmospherics in specified direction.
/obj/machinery/atmospherics/proc/findConnecting(var/direction)
	for(var/obj/machinery/atmospherics/target in get_step(src,direction))
		if( (target.initialize_directions & get_dir(target,src)) && check_connect_types(target,src) )
			return target
