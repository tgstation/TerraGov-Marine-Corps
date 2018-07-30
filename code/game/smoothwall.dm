//Separate dm because it relates to two types of atoms + ease of removal in case it's needed.
//Also assemblies.dm for falsewall checking for this when used.
//I should really make the shuttle wall check run every time it's moved, but centcom uses unsimulated floors so !effort

/atom
	//A list of paths only that each turf should tile with
	var/list/tiles_with

/atom/proc/relativewall() //atom because it should be useable both for walls, false walls, doors, windows, etc
	var/junction = 0 //flag used for icon_state
	var/i //iterator
	var/turf/T //The turf we are checking
	var/j //second iterator
	var/k //third iterator (I know, that's a lot, but I'm trying to make this modular, so bear with me)

	for(i in cardinal) //For all cardinal dir turfs
		T = get_step(src, i)
		if(!istype(T)) continue
		for(j in tiles_with) //And for all types that we tile with
			if(istype(T, j))
				junction |= i
				break

			for(k in T)
				if(istype(k, j))
					//world << "DEBUG: type is: [j], object is [k]. Checking successful."
					junction |= i
					//world << "DEBUG: Junction is: [junction]."
					break

	handle_icon_junction(junction)

/atom/proc/relativewall_neighbours()
	var/i //iterator
	var/turf/T //The turf we are checking
	var/j //second iterator
	var/atom/k //third iterator (I know, that's a lot, but I'm trying to make this modular, so bear with me)

	for(i in cardinal) //For all cardinal dir turfs
		T = get_step(src, i)
		if(!istype(T)) continue
		for(j in tiles_with) //And for all types that we tile with
			if(istype(T, j))
				T.relativewall() //If we tile this type, junction it
				break

			for(k in T)
				if(istype(k, j))
					k.relativewall() //get_dir to i, since k is something inside the turf T
					break

/atom/proc/handle_icon_junction(junction)
	return

//Windows are weird. The walls technically tile with them, but they don't tile back. At least, not really.
//They require more states or something to that effect, but this is a workaround to use what we have.
//I could introduce flags here, but I feel like the faster the better. In this case an override with copy and pasted code is fine for now.
/obj/structure/window/framed/relativewall()
	var/jun_1 = 0 //Junction 1.
	var/jun_2 = 0 //Junction 2.
	var/turf/T
	var/i
	var/j
	var/k

	for(i in cardinal)
		T = get_step(src, i)
		if(!istype(T)) continue
		for(j in tiles_with)
			if(istype(T, j))
				jun_1 |= i
				break

			for(k in T)
				if(istype(k, j))
					jun_1 |= i
					break

		for(j in tiles_special)
			for(k in T)
				if(istype(k, j))
					jun_2 |= i
					break

	handle_icon_junction(jun_1, jun_2)

//Windows are weird. The walls technically tile with them, but they don't tile back. At least, not really.
//They require more states or something to that effect, but this is a workaround to use what we have.
//I could introduce flags here, but I feel like the faster the better. In this case an override with copy and pasted code is fine for now.
/obj/structure/window_frame/relativewall()
	var/jun_1 = 0 //Junction 1.
	var/jun_2 = 0 //Junction 2.
	var/turf/T
	var/i
	var/j
	var/k

	for(i in cardinal)
		T = get_step(src, i)
		if(!istype(T)) continue
		for(j in tiles_with)
			if(istype(T, j))
				jun_1 |= i
				break

			for(k in T)
				if(istype(k, j))
					jun_1 |= i
					break

		for(j in tiles_special)
			for(k in T)
				if(istype(k, j))
					jun_2 |= i
					break

	handle_icon_junction(jun_1, jun_2)

// Special case for smoothing walls around multi-tile doors.
/obj/machinery/door/airlock/multi_tile/relativewall_neighbours()
	var/turf/T //The turf we are checking
	var/atom/k
	var/j

	if (dir == SOUTH)
		T = locate(x, y+2, z)
		for(j in tiles_with)
			if(istype(T, j))
				T.relativewall()
				break
			for(k in T)
				if(istype(k, j))
					k.relativewall()
					break

		T = locate(x, y-1, z)
		for(j in tiles_with)
			if(istype(T, j))
				T.relativewall()
				break
			for(k in T)
				if(istype(k, j))
					k.relativewall()
					break

	else if (dir == EAST)
		T = locate(x+2, y, z)
		for(j in tiles_with)
			if(istype(T, j))
				T.relativewall()
				break
			for(k in T)
				if(istype(k, j))
					k.relativewall()
					break

		T = locate(x-1, y, z)
		for(j in tiles_with)
			if(istype(T, j))
				T.relativewall()
				break
			for(k in T)
				if(istype(k, j))
					k.relativewall()
					break

// Not proud of this.
/obj/structure/mineral_door/resin/handle_icon_junction(junction)
	if(junction & (SOUTH|NORTH))
		dir = WEST
	else if(junction & (EAST|WEST))
		dir = NORTH

/obj/structure/window/framed/handle_icon_junction(jun_1, jun_2)
	icon_state = "[basestate][jun_2 ? jun_2 : jun_1]" //Use junction 2 if possible, junction 1 otherwise.
	if(jun_2)
		junction = jun_2
	else
		junction = jun_1

/obj/structure/window_frame/handle_icon_junction(jun_1, jun_2)
	icon_state = "[basestate][jun_2 ? jun_2 : jun_1]_frame" //Use junction 2 if possible, junction 1 otherwise.
	if(jun_2)
		junction = jun_2
	else
		junction = jun_1



/turf/closed/wall/handle_icon_junction(junction)
	icon_state = "[walltype][junction]"
	junctiontype = junction

/obj/structure/grille/almayer/handle_icon_junction(junction)
	icon_state = "grille[junction]"


/turf/open/floor/vault/relativewall()
	return

/turf/closed/wall/vault/relativewall()
	return

/turf/closed/shuttle/relativewall()
	//TODO: Make something for this and make it work with shuttle rotations
	return

/turf/open/shuttle/relativewall()
	return

/turf/closed/wall/indestructible/relativewall()
	return




