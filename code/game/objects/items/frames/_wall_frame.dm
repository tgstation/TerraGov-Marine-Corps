/obj/item/wallframe
	icon = 'icons/obj/wallframes.dmi'
	flags_atom = CONDUCT
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(
		/datum/material/metal = 5,
		/datum/material/glass = 5,
	)
	var/result_path
	var/inverse = 0 // For inverse dir frames like light fixtures.
	var/pixel_shift //The amount of pixels

/obj/item/wallframe/proc/try_build(turf/on_wall, mob/user)
	if(get_dist(on_wall, user) > 1)
		return
	var/ndir = get_dir(on_wall, user)
	if(!(ndir in GLOB.cardinals))
		return
	var/turf/T = get_turf(user)
	var/area/A = get_area(T)
	if(!isfloorturf(T))
		to_chat(user, "<span class='warning'>You cannot place [src] on this spot!</span>")
		return
	if(A.always_unpowered)
		to_chat(user, "<span class='warning'>You cannot place [src] in this area!</span>")
		return
	if(gotwallitem(T, ndir, inverse*2))
		to_chat(user, "<span class='warning'>There's already an item on this wall!</span>")
		return

	return TRUE

/obj/item/wallframe/proc/attach(turf/on_wall, mob/user)
	if(result_path)
		playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
		user.visible_message("<span class='notice'>[user.name] attaches [src] to the wall.</span>",
			"<span class='notice'>You attach [src] to the wall.</span>",
			"<span class='hear'>You hear clicking.</span>")
		var/ndir = get_dir(on_wall,user)
		if(inverse)
			ndir = turn(ndir, 180)

		var/obj/O = new result_path(get_turf(user), ndir, TRUE)
		if(pixel_shift)
			switch(ndir)
				if(NORTH)
					O.pixel_y = pixel_shift
				if(SOUTH)
					O.pixel_y = -pixel_shift
				if(EAST)
					O.pixel_x = pixel_shift
				if(WEST)
					O.pixel_x = -pixel_shift
		after_attach(O)

	qdel(src)

/obj/item/wallframe/proc/after_attach(obj/O)
	return

/obj/item/wallframe/attackby(obj/item/W, mob/user, params)
	..()
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		// For camera-building borgs
		var/turf/T = get_step(get_turf(user), user.dir)
		if(iswallturf(T))
			T.attackby(src, user, params)

	var/metal_amt = materials[/datum/material/metal]
	var/glass_amt = materials[/datum/material/glass]

	if(W.tool_behaviour == TOOL_WRENCH && (metal_amt || glass_amt))
		to_chat(user, "<span class='notice'>You dismantle [src].</span>")
		if(metal_amt)
			new /obj/item/stack/sheet/metal(get_turf(src), metal_amt)
		if(glass_amt)
			new /obj/item/stack/sheet/glass(get_turf(src), glass_amt)
		qdel(src)

