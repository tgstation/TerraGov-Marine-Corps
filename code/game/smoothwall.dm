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
/obj/structure/window/reinforced/almayer/relativewall()
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

/obj/structure/window/reinforced/almayer/handle_icon_junction(jun_1, jun_2)
	icon_state = "[basestate][jun_2 ? jun_2 : jun_1]" //Use junction 2 if possible, junction 1 otherwise.
	if(jun_2)
		junction = jun_2
	else
		junction = jun_1

/turf/simulated/wall/handle_icon_junction(junction)
	icon_state = "[walltype][junction]"

/obj/structure/grille/almayer/handle_icon_junction(junction)
	icon_state = "grille[junction]"


/turf/simulated/floor/vault/relativewall()
	return

/turf/simulated/wall/vault/relativewall()
	return

/turf/simulated/shuttle/wall/relativewall()
	//TODO: Make something for this and make it work with shuttle rotations
	return

/*

/atom/proc/relativewall() //atom because it should be useable both for walls and false walls
	if(istype(src,/turf/simulated/floor/vault)||istype(src,/turf/simulated/wall/vault)) //HACK!!!
		return

	var/junction = 0 //will be used to determine from which side the wall is connected to other walls

	if(!istype(src,/turf/simulated/shuttle/wall)) //or else we'd have wacky shuttle merging with walls action
		for(var/turf/simulated/wall/W in orange(src,1))
			if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
				junction |= get_dir(src,W)
		for(var/obj/structure/falsewall/W in orange(src,1))
			if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
				junction |= get_dir(src,W)
		for(var/obj/structure/falserwall/W in orange(src,1))
			if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
				junction |= get_dir(src,W)

	if(istype(src,/turf/simulated/wall))
		var/turf/simulated/wall/wall = src
		wall.icon_state = "[wall.walltype][junction]"
	else if (istype(src,/obj/structure/falserwall))
		src.icon_state = "rwall[junction]"
	else if (istype(src,/obj/structure/falsewall))
		var/obj/structure/falsewall/fwall = src
		fwall.icon_state = "[fwall.mineral][junction]"

	return

*/

/turf/simulated/wall/New()
	relativewall()
	relativewall_neighbours()
	..()


//turfs call del() when they're replaced by another turf, so we can't use Dispose() unfortunately.
/turf/simulated/wall/Del()
	spawn(10)
		for(var/turf/simulated/wall/W in range(src,1))
			W.relativewall()

	for(var/direction in cardinal)
		for(var/obj/effect/glowshroom/shroom in get_step(src,direction))
			if(!shroom.floor) //shrooms drop to the floor
				shroom.floor = 1
				shroom.icon_state = "glowshroomf"
				shroom.pixel_x = 0
				shroom.pixel_y = 0

	. = ..()