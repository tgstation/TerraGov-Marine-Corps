/obj/structure/lattice
	desc = "A lightweight support lattice."
	name = "lattice"
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "latticefull"
	density = 0
	anchored = TRUE
	layer = LATTICE_LAYER
	//	flags = CONDUCT

/obj/structure/lattice/New()
	..()
	if(!isspaceturf(loc))
		qdel(src)
	for(var/obj/structure/lattice/LAT in src.loc)
		if(LAT != src)
			qdel(LAT)
	icon = 'icons/obj/smoothlattice.dmi'
	icon_state = "latticeblank"
	updateOverlays()
	for (var/dir in GLOB.cardinals)
		var/obj/structure/lattice/L
		if(locate(/obj/structure/lattice, get_step(src, dir)))
			L = locate(/obj/structure/lattice, get_step(src, dir))
			L.updateOverlays()

/obj/structure/lattice/Destroy()
	for (var/dir in GLOB.cardinals)
		var/obj/structure/lattice/L
		if(locate(/obj/structure/lattice, get_step(src, dir)))
			L = locate(/obj/structure/lattice, get_step(src, dir))
			L.updateOverlays(src.loc)
	. = ..()

/obj/structure/lattice/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			qdel(src)
			return
		if(3.0)
			return
		else
	return

/obj/structure/lattice/attackby(obj/item/C as obj, mob/user as mob)

	if (istype(C, /obj/item/stack/tile/plasteel))
		var/turf/T = get_turf(src)
		T.attackby(C, user) //BubbleWrap - hand this off to the underlying turf instead
		return
	if (iswelder(C))
		var/obj/item/tool/weldingtool/WT = C
		if(WT.remove_fuel(0, user))
			to_chat(user, "<span class='notice'>Slicing lattice joints ...</span>")
		new /obj/item/stack/rods(src.loc)
		qdel(src)

	return

/obj/structure/lattice/proc/updateOverlays()
	//if(!isspaceturf(loc))
	//	qdel(src)
	spawn(1)
		overlays = list()

		var/dir_sum = 0

		for (var/direction in GLOB.cardinals)
			if(locate(/obj/structure/lattice, get_step(src, direction)))
				dir_sum += direction
			else
				if(!isspaceturf(get_step(src, direction)))
					dir_sum += direction

		icon_state = "lattice[dir_sum]"
		return

/obj/structure/catwalk
	icon = 'icons/turf/catwalks.dmi'
	icon_state = "catwalk0"

/obj/structure/catwalk/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	if(istype(T, /turf/open))
		var/turf/open/O = T
		var/obj/effect/river_overlay/R = locate() in T // remove any river overlays
		if(R)
			qdel(R)
		O.has_catwalk = TRUE
		O.overlays += image(icon, T, icon_state, CATWALK_LAYER)
	return INITIALIZE_HINT_QDEL
