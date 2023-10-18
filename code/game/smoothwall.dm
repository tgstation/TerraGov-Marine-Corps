//Separate dm because it relates to two types of atoms + ease of removal in case it's needed.
//Also assemblies.dm for falsewall checking for this when used.
//I should really make the shuttle wall check run every time it's moved, but centcom uses unsimulated floors so !effort

///Base proc to trigger the smoothing system. It will behave according to the smoothing atom's system.
/* /atom/proc/smooth_self()
	switch(smoothing_behavior)
		if(CARDINAL_SMOOTHING)
			relativewall()
		if(DIAGONAL_SMOOTHING)
			diagonal_smooth_self()


///Base proc to update adjacent atoms the source can smooth with.
/atom/proc/smooth_neighbors(epicenter)
	switch(smoothing_behavior)
		if(CARDINAL_SMOOTHING)
			relativewall_neighbours(epicenter)
		if(DIAGONAL_SMOOTHING)
			diagonal_smooth_neighbors(epicenter)

/atom/proc/relativewall() //atom because it should be useable both for walls, false walls, doors, windows, etc
	if(smoothing_behavior != CARDINAL_SMOOTHING || !smoothing_groups)
		CRASH("relativewall() called without smoothing behavior defined")
	var/junction = NONE
	for(var/direction in GLOB.cardinals)
		var/turf/neighbor = get_step(src, direction)
		if(!neighbor)
			continue
		if(smoothing_groups & neighbor.smoothing_groups)
			junction |=  direction //smooth cardinals are the same as BYOND cardinals
			continue
		for(var/obj/object in neighbor)
			if(!(smoothing_groups & object.smoothing_groups))
				continue
			junction |=  direction //smooth cardinals are the same as BYOND cardinals
			break

	handle_icon_junction(junction)

///Old cardinal smoothing system. Scans cardinal neighbors for targets to smooth with.
/atom/proc/relativewall_neighbours(epicenter)
	if(isnull(epicenter))
		epicenter = src
	for(var/direction in GLOB.cardinals)
		var/turf/neighbor = get_step(epicenter, direction)
		if(!neighbor)
			continue
		if(neighbor.smoothing_behavior && (smoothing_groups & neighbor.smoothing_groups))
			neighbor.smooth_self()
		for(var/obj/object in neighbor)
			if(!object.smoothing_behavior || !(smoothing_groups & object.smoothing_groups))
				continue
			object.smooth_self()
/atom/proc/handle_icon_junction(junction)
	return

/obj/machinery/door/airlock/multi_tile/relativewall_neighbours(epicenter)
	if(isnull(epicenter))
		epicenter = locs //list of locations
	else
		epicenter = list(epicenter, get_step(epicenter, (dir & (EAST|WEST)) ? EAST : NORTH ))
	var/list/atom/permutated = list(src = TRUE)
	for(var/location in epicenter)
		for(var/direction in GLOB.cardinals)
			var/turf/neighbor = get_step(location, direction)
			if(!neighbor || permutated[neighbor])
				continue
			permutated[neighbor] = TRUE
			if(neighbor.smoothing_behavior && (smoothing_groups & neighbor.smoothing_groups))
				neighbor.smooth_self()
			for(var/obj/object in neighbor)
				if(!object.smoothing_behavior || !(smoothing_groups & object.smoothing_groups) || permutated[object])
					continue
				permutated[object] = TRUE
				object.smooth_self()

// Not proud of this.
/obj/structure/mineral_door/resin/handle_icon_junction(junction)
	if(junction & (SOUTH|NORTH))
		dir = WEST
	else if(junction & (EAST|WEST))
		dir = NORTH

/obj/structure/window/framed/handle_icon_junction(jun)
	icon_state = "[basestate][jun]"
	junction = jun

/obj/structure/window_frame/handle_icon_junction(jun)
	icon_state = "[basestate][jun]_frame"
	junction = jun

/turf/closed/handle_icon_junction(junction)
	icon_state = "[walltype][junction]"
	junctiontype = junction

/obj/structure/grille/mainship/handle_icon_junction(junction)
	icon_state = "grille[junction]"

/turf/open/floor/vault/relativewall()
	return

/turf/closed/wall/vault/relativewall()
	return

/turf/open/shuttle/relativewall()
	return

/turf/closed/wall/indestructible/relativewall()
	return

/*
 * * Diagonal smoothing system.
 * For now only implemented for walls.
*/

///Scans surroundings for things to smooth with.
/atom/proc/diagonal_smooth_self()
	return

/turf/closed/diagonal_smooth_self()
	if(smoothing_behavior != DIAGONAL_SMOOTHING || !smoothing_groups)
		CRASH("diagonal_smooth_self() called without smoothing behavior defined")
	junctiontype = NONE
	for(var/direction in GLOB.cardinals)
		var/turf/neighbor = get_step(src, direction)
		if(!neighbor)
			continue
		if(smoothing_groups & neighbor.smoothing_groups)
			junctiontype |=  direction //smooth cardinals are the same as BYOND cardinals
			continue
		for(var/obj/object in neighbor)
			if(!(smoothing_groups & object.smoothing_groups))
				continue
			junctiontype |=  direction //smooth cardinals are the same as BYOND cardinals
			break
	if(!(junctiontype & (NORTH|SOUTH)) || !(junctiontype & (EAST|WEST)))
		update_corners()
		return //Without a corner there's no need to worry about diagonals.
	for(var/direction in GLOB.diagonals)
		var/turf/neighbor = get_step(src, direction)
		if(!neighbor)
			continue
		if(smoothing_groups & neighbor.smoothing_groups)
			junctiontype |= GLOB.diagonal_smoothing_conversion["[direction]"]
			continue
		for(var/obj/object in neighbor)
			if(!(smoothing_groups & object.smoothing_groups))
				continue
			junctiontype |= GLOB.diagonal_smoothing_conversion["[direction]"]
			break
	update_corners()


///Diagonal smoothing system, based on corner states.
/turf/closed/proc/update_corners()
	var/ne = CONVEX //Initial values are those of the wall without neighbors.
	var/se = CONVEX
	var/sw = CONVEX
	var/nw = CONVEX

	if(!(junctiontype & N_NORTH))
		if(!(junctiontype & N_EAST))
			ne = CONVEX
		else
			ne = HORIZONTAL
	else if(!(junctiontype & N_EAST))
		ne = VERTICAL
	else if(!(junctiontype & N_NORTHEAST))
		ne = CONCAVE
	else
		ne = FLAT

	if(!(junctiontype & N_SOUTH))
		if(!(junctiontype & N_EAST))
			se = CONVEX
		else
			se = HORIZONTAL
	else if(!(junctiontype & N_EAST))
		se = VERTICAL
	else if(!(junctiontype & N_SOUTHEAST))
		se = CONCAVE
	else
		se = FLAT

	if(!(junctiontype & N_SOUTH))
		if(!(junctiontype & N_WEST))
			sw = CONVEX
		else
			sw = HORIZONTAL
	else if(!(junctiontype & N_WEST))
		sw = VERTICAL
	else if(!(junctiontype & N_SOUTHWEST))
		sw = CONCAVE
	else
		sw = FLAT

	if(!(junctiontype & N_NORTH))
		if(!(junctiontype & N_WEST))
			nw = CONVEX
		else
			nw = HORIZONTAL
	else if(!(junctiontype & N_WEST))
		nw = VERTICAL
	else if(!(junctiontype & N_NORTHWEST))
		nw = CONCAVE
	else
		nw = FLAT

	icon_state = "[walltype]-[ne]-[se]-[sw]-[nw]"


///Scans surroundings for things that would smooth with the source.
/atom/proc/diagonal_smooth_neighbors(epicenter)
	if(isnull(epicenter))
		epicenter = src
	var/found_neighbors = 0
	for(var/direction in GLOB.cardinals)
		var/turf/neighbor = get_step(epicenter, direction)
		if(!neighbor)
			continue
		if(neighbor.smoothing_behavior && (smoothing_groups & neighbor.smoothing_groups))
			neighbor.smooth_self()
			found_neighbors++
		for(var/obj/object in neighbor)
			if(!object.smoothing_behavior || !(smoothing_groups & object.smoothing_groups))
				continue
			object.smooth_self()
			found_neighbors++
	if(!found_neighbors)
		return //No use checking diagonals if there's no cardinal adjacent ones.
	for(var/direction in GLOB.diagonals)
		var/turf/neighbor = get_step(epicenter, direction)
		if(!neighbor)
			continue
		if((neighbor.smoothing_behavior == DIAGONAL_SMOOTHING) && (smoothing_groups & neighbor.smoothing_groups))
			neighbor.smooth_self()
		for(var/obj/object in neighbor)
			if((object.smoothing_behavior != DIAGONAL_SMOOTHING) || !(smoothing_groups & object.smoothing_groups))
				continue
			object.smooth_self()
*/


