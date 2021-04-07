/turf/open/space/transit
	name = "\proper hyperspace"
	icon_state = "black"
	dir = SOUTH
	baseturfs = /turf/open/space/transit
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED //Different from /tg/
	flags_atom = NOJAUNT_1 //This line goes out to every wizard that ever managed to escape the den. I'm sorry.
	explosion_block = INFINITY
	///The number of icon state available
	var/available_icon_state_amounts = 15

/turf/open/space/transit/atmos
	name = "\proper high atmosphere"
	baseturfs = /turf/open/space/transit/atmos
	available_icon_state_amounts = 8

//Overwrite because we dont want people building rods in space.
/turf/open/space/transit/attackby(obj/item/I, mob/user, params)
	return

///turf/open/space/transit/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
//	. = ..()
//	underlay_appearance.icon_state = "speedspace_ns_[get_transit_state(asking_turf)]"
//	underlay_appearance.transform = turn(matrix(), get_transit_angle(asking_turf))

/turf/open/space/transit/south
	dir = SOUTH

/turf/open/space/transit/north
	dir = NORTH

/turf/open/space/transit/west
	dir = WEST

/turf/open/space/transit/east
	dir = EAST

/turf/open/space/transit/Entered(atom/movable/AM, atom/OldLoc)
	..()
	if(!locate(/obj/structure/lattice) in src)
		throw_atom(AM)

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


/turf/open/space/transit/Initialize()
	. = ..()
	update_icon()
	for(var/atom/movable/AM in src)
		throw_atom(AM)

/turf/open/space/transit/update_icon()
	. = ..()
	transform = turn(matrix(), get_transit_angle(src))

/turf/open/space/transit/update_icon_state()
	icon_state = "speedspace_ns_[get_transit_state(src, available_icon_state_amounts)]"

/turf/open/space/transit/atmos/update_icon_state()
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
