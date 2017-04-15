//Separate dm because it relates to two types of atoms + ease of removal in case it's needed.
//Also assemblies.dm for falsewall checking for this when used.
//I should really make the shuttle wall check run every time it's moved, but centcom uses unsimulated floors so !effort

/atom
	//A list of paths only that each turf should tile with
	var/list/tiles_with = list()

/atom/proc/relativewall() //atom because it should be useable both for walls, false walls, doors, windows, etc

	var/junction = 0 //flag used for icon_state

	var/i //iterator
	var/turf/T //The turf we are checking
	var/j //second iterator
	var/k //third iterator (I know, that's a lot, but I'm trying to make this modular, so bear with me)

	checking_tiles:
		for(i in cardinal) //For all cardinal dir turfs
			T = get_step(src, i)
			if(!istype(T)) continue
			for(j in src.tiles_with) //And for all types that we tile with
				if(istype(T, j))
					junction |= get_dir(src, T) //If we tile this type, junction it
					continue checking_tiles

				else if(istype(T, /turf)) //Should always be true, but just in case
					for(k in T)
						if(istype(k, j))
							junction |= get_dir(src, T) //get_dir to i, since k is something inside the turf T
							continue checking_tiles

				else throw EXCEPTION("Error: Expected turfs in list things_to_check but recieved something else. Error code: MSD_SW_IWNAT")

	handle_icon_junction(junction)

	return

/atom/proc/handle_icon_junction(var/junction)
	return

/turf/simulated/wall/handle_icon_junction(var/junction)
	icon_state = "[walltype][junction]"

/obj/structure/falserwall/handle_icon_junction(var/junction)
	icon_state = "rwall[junction]"

/obj/structure/falsewall/handle_icon_junction(var/junction)
	icon_state = "[mineral][junction]"


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

/atom/proc/relativewall_neighbours()

	var/i //iterator
	var/turf/T //The turf we are checking
	var/j //second iterator
	var/atom/k //third iterator (I know, that's a lot, but I'm trying to make this modular, so bear with me)

	checking_tiles:
		for(i in cardinal) //For all cardinal dir turfs
			T = get_step(src, i)
			if(!istype(T)) continue
			for(j in src.tiles_with) //And for all types that we tile with
				if(istype(T, j))
					T.relativewall() //If we tile this type, junction it
					continue checking_tiles

				else if(istype(T, /turf)) //Should always be true, but just in case
					for(k in T)
						if(istype(k, j))
							k.relativewall() //get_dir to i, since k is something inside the turf T
							continue checking_tiles

				else throw EXCEPTION("Error: Expected turfs in list things_to_check but recieved something else. Error code: MSD_SW_IWNAT")

	return

/turf/simulated/wall/New()
	relativewall_neighbours()
	..()

/turf/simulated/wall/Del()
	spawn(10)
		for(var/turf/simulated/wall/W in range(src,1))
			W.relativewall()

		for(var/obj/structure/falsewall/W in range(src,1))
			W.relativewall()

	for(var/direction in cardinal)
		for(var/obj/effect/glowshroom/shroom in get_step(src,direction))
			if(!shroom.floor) //shrooms drop to the floor
				shroom.floor = 1
				shroom.icon_state = "glowshroomf"
				shroom.pixel_x = 0
				shroom.pixel_y = 0

	..()

/turf/simulated/wall/relativewall()
	if(istype(src,/turf/simulated/wall/vault)) //HACK!!!
		return

	var/junction = 0 //will be used to determine from which side the wall is connected to other walls

	for(var/turf/simulated/wall/W in orange(src,1))
		if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
			if(src.mineral == W.mineral)//Only 'like' walls connect -Sieve
				junction |= get_dir(src,W)
	for(var/obj/structure/falsewall/W in orange(src,1))
		if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
			if(src.mineral == W.mineral)
				junction |= get_dir(src,W)
	for(var/obj/structure/falserwall/W in orange(src,1))
		if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
			if(src.mineral == W.mineral)
				junction |= get_dir(src,W)
	var/turf/simulated/wall/wall = src
	wall.icon_state = "[wall.walltype][junction]"
	return