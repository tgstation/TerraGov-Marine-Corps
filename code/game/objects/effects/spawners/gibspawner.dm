
/proc/gibs(atom/location)		//CARN MARKER
	new /obj/effect/spawner/gibspawner/generic(get_turf(location))

/proc/hgibs(atom/location, fleshcolor, bloodcolor)
	new /obj/effect/spawner/gibspawner/human(get_turf(location),fleshcolor,bloodcolor)

/proc/xgibs(atom/location)
	new /obj/effect/spawner/gibspawner/xeno(get_turf(location))

/proc/robogibs(atom/location)
	new /obj/effect/spawner/gibspawner/robot(get_turf(location))

/obj/effect/spawner/gibspawner
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "gibsmarker"
	var/sparks = 0 //whether sparks spread on Gib()
	var/list/gibtypes = list()
	var/list/gibamounts = list()
	var/list/gibdirections = list() //of lists
	var/fleshcolor //Used for gibbed humans.
	var/bloodcolor //Used for gibbed humans.

/obj/effect/spawner/gibspawner/Initialize(mapload, fleshcolor, bloodcolor)
	..()

	if(fleshcolor)
		src.fleshcolor = fleshcolor
	if(bloodcolor)
		src.bloodcolor = bloodcolor

	if(istype(loc,/turf)) //basically if a badmin spawns it
		Gib(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/gibspawner/proc/Gib(atom/location)
	if(gibtypes.len != gibamounts.len || gibamounts.len != gibdirections.len)
		CRASH("GIB LENGTH MISMATCH")

	var/obj/effect/decal/cleanable/blood/gibs/gib = null
	if(sparks)
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(2, 1, location)
		s.start()

	for(var/i = 1, i<= gibtypes.len, i++)
		if(gibamounts[i])
			for(var/j = 1, j<= gibamounts[i], j++)
				var/gibType = gibtypes[i]
				gib = new gibType(location)

				// Apply human species colouration to masks.
				if(fleshcolor)
					gib.fleshcolor = fleshcolor
				if(bloodcolor)
					gib.basecolor = bloodcolor

				gib.update_icon()

				var/list/directions = gibdirections[i]
				if(directions.len)
					gib.streak(directions)

	qdel(src)




/obj/effect/spawner/gibspawner

/obj/effect/spawner/gibspawner/generic
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/core)
	gibamounts = list(2,2,1)
	gibdirections = list(list(WEST, NORTHWEST, SOUTHWEST, NORTH),list(EAST, NORTHEAST, SOUTHEAST, SOUTH), list())

/obj/effect/spawner/gibspawner/human
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/down,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/core)
	gibamounts = list(1,1,1,1,1,1,1)

/obj/effect/spawner/gibspawner/human/Initialize()
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, GLOB.alldirs, list())
	gibamounts[6] = pick(0,1,2)
	return ..()

/obj/effect/spawner/gibspawner/xeno
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/xeno/up,/obj/effect/decal/cleanable/blood/gibs/xeno/down,/obj/effect/decal/cleanable/blood/gibs/xeno,/obj/effect/decal/cleanable/blood/gibs/xeno,/obj/effect/decal/cleanable/blood/gibs/xeno/body,/obj/effect/decal/cleanable/blood/gibs/xeno/limb,/obj/effect/decal/cleanable/blood/gibs/xeno/core)
	gibamounts = list(1,1,1,1,1,1,1)

/obj/effect/spawner/gibspawner/xeno/Initialize()
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, GLOB.alldirs, list())
	gibamounts[6] = pick(0,1,2)
	return ..()

/obj/effect/spawner/gibspawner/robot
	sparks = 1
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/robot/up,/obj/effect/decal/cleanable/blood/gibs/robot/down,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot/limb)
	gibamounts = list(1,1,1,1,1,1)

/obj/effect/spawner/gibspawner/robot/Initialize()
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, GLOB.alldirs)
	gibamounts[6] = pick(0,1,2)
	return ..()
