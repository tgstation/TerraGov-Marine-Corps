/turf/open/space/transit
	name = "\proper hyperspace"
	icon_state = "black"
	dir = SOUTH
	baseturfs = /turf/open/space/transit
	explosion_block = INFINITY
	///The number of icon state available
	var/available_icon_state_amounts = 15


/turf/open/space/transit/Initialize(mapload)
	. = ..()
	update_appearance()
	RegisterSignal(src, COMSIG_TURF_RESERVATION_RELEASED, PROC_REF(launch_contents))

/turf/open/space/transit/Destroy()
	//Signals are NOT removed from turfs upon replacement, and we get replaced ALOT, so unregister our signal
	UnregisterSignal(src, COMSIG_TURF_RESERVATION_RELEASED)
	return ..()

/turf/open/space/transit/atmos
	name = "\proper high atmosphere"
	baseturfs = /turf/open/space/transit/atmos
	available_icon_state_amounts = 8
	plane = FLOOR_PLANE

//Overwrite because we dont want people building rods in space.
/turf/open/space/transit/attackby(obj/item/I, mob/user, params)
	return

/turf/open/space/transit/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	. = ..()
	if(plane != FLOOR_PLANE) // snowflake behaviour e.g clouds
		underlay_appearance.icon_state = "speedspace_ns_[get_transit_state(asking_turf)]"
		underlay_appearance.transform = turn(matrix(), get_transit_angle(asking_turf))

///Get rid of all our contents, called when our reservation is released (which in our case means the shuttle arrived)
/turf/open/space/transit/proc/launch_contents(datum/turf_reservation/reservation)
	SIGNAL_HANDLER

	for(var/atom/movable/movable in contents)
		dump_in_space(movable)

///Dump a movable in a random eligible tile
/proc/dump_in_space(atom/movable/dumpee)
	var/static/list/area/possible_dump_lzs
	// yes this doesnt update when new areas are added but imo not worth wasting the CPU time
	// since it doesnt change often. update if you feel different
	if(!possible_dump_lzs)
		possible_dump_lzs = list()
		for(var/area/zone AS in GLOB.areas)
			if(zone.area_flags & MARINE_BASE || zone.area_flags & NEAR_FOB)
				possible_dump_lzs += zone
	var/area/garbage_dump = pick(possible_dump_lzs)
	var/turf/dumpturf = pick(garbage_dump.get_turfs_from_all_zlevels())
	dumpee.forceMove(dumpturf)
	var/dumpee_pix_z = dumpee.pixel_z
	dumpee.pixel_z += 400
	animate(dumpee, 1 SECONDS, pixel_z=dumpee_pix_z)
	if(isliving(dumpee))
		var/mob/living/skydiver = dumpee
		skydiver.take_overall_damage(300, BRUTE) // you fell from space!! YOU ARE A PANCAKE
		skydiver.take_overall_damage(300, BURN) // A BURNING PANCAKE

/turf/open/space/transit/south
	dir = SOUTH

/turf/open/space/transit/north
	dir = NORTH

/turf/open/space/transit/west
	dir = WEST

/turf/open/space/transit/east
	dir = EAST

/turf/open/space/transit/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	..()
	if(!locate(/obj/structure/lattice) in src) //todo wtf is this even
		throw_atom(arrived)

/turf/open/space/transit/proc/throw_atom(atom/movable/AM)
	set waitfor = FALSE
	if(QDELETED(AM) || istype(AM, /obj/docking_port))
		return
	if(AM.loc != src) 	// Multi-tile objects are "in" multiple locs but its loc is it's true placement.
		return			// Don't move multi tile objects if their origin isnt in transit
	var/max = world.maxx-TRANSITIONEDGE
	var/min = 1+TRANSITIONEDGE

	var/list/possible_transtitons = list()
	for(var/A in SSmapping.z_list)
		var/datum/space_level/D = A
		if (D.linkage == CROSSLINKED)
			possible_transtitons += D.z_value
	if(!length(possible_transtitons))
		return
	var/_z = pick(possible_transtitons)

	//now select coordinates for a border turf
	var/_x
	var/_y
	switch(dir)
		if(SOUTH)
			_x = rand(min,max)
			_y = max
		if(WEST)
			_x = max
			_y = rand(min,max)
		if(EAST)
			_x = min
			_y = rand(min,max)
		else
			_x = rand(min,max)
			_y = min

	var/turf/T = locate(_x, _y, _z)
	AM.forceMove(T)


/turf/open/space/transit/Initialize(mapload)
	. = ..()
	update_icon()
	for(var/atom/movable/AM in src)
		throw_atom(AM)

/turf/open/space/transit/update_icon()
	. = ..()
	transform = turn(matrix(), get_transit_angle(src))

/turf/open/space/transit/update_icon_state()
	. = ..()
	icon_state = "speedspace_ns_[get_transit_state(src, available_icon_state_amounts)]"

/turf/open/space/transit/atmos/update_icon_state()
	. = ..()
	icon_state = "Cloud_[get_transit_state(src, available_icon_state_amounts)]"

/proc/get_transit_state(turf/T, available_icon_state_amounts)
	var/p = round(available_icon_state_amounts / 2)
	. = 1
	switch(T.dir)
		if(NORTH)
			. = ((-p*T.x+T.y) % available_icon_state_amounts) + 1
			if(. < 1)
				. += available_icon_state_amounts
		if(EAST)
			. = ((T.x+p*T.y) % available_icon_state_amounts) + 1
		if(WEST)
			. = ((T.x-p*T.y) % available_icon_state_amounts) + 1
			if(. < 1)
				. += available_icon_state_amounts
		else
			. = ((p*T.x+T.y) % available_icon_state_amounts) + 1

/proc/get_transit_angle(turf/T)
	. = 0
	switch(T.dir)
		if(NORTH)
			. = 180
		if(EAST)
			. = 90
		if(WEST)
			. = -90
