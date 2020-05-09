


//FLOORS-----------------------------------//
//Snow Floor
/turf/open/floor/plating/ground/snow
	name = "snow layer"
	icon = 'icons/turf/snow2.dmi'
	icon_state = "snow_0"
	hull_floor = TRUE

// Melting snow
/turf/open/floor/plating/ground/snow/fire_act(exposed_temperature, exposed_volume)
	slayer = 0
	update_icon(1, 0)

//Xenos digging up snow
/turf/open/floor/plating/ground/snow/attack_alien(mob/living/carbon/xenomorph/M)
	if(M.a_intent == INTENT_GRAB)

		if(!slayer)
			to_chat(M, "<span class='warning'>There is nothing to clear out!</span>")
			return FALSE

		M.visible_message("<span class='notice'>\The [M] starts clearing out \the [src].</span>", \
		"<span class='notice'>We start clearing out \the [src].</span>", null, 5)
		playsound(M.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
		if(!do_after(M, 25, FALSE, src, BUSY_ICON_BUILD))
			return FALSE

		if(!slayer)
			to_chat(M, "<span class='warning'>There is nothing to clear out!</span>")
			return

		M.visible_message("<span class='notice'>\The [M] clears out \the [src].</span>", \
		"<span class='notice'>We clear out \the [src].</span>", null, 5)
		slayer -= 1
		update_icon(1, 0)

	//PLACING/REMOVING/BUILDING
/turf/open/floor/plating/ground/snow/attackby(obj/item/I, mob/user, params)
	. = ..()
	//Light Stick
	if(istype(I, /obj/item/lightstick))
		var/obj/item/lightstick/L = I
		if(locate(/obj/item/lightstick) in get_turf(src))
			to_chat(user, "There's already a [L]  at this position!")
			return

		to_chat(user, "Now planting \the [L].")
		if(!do_after(user,20, TRUE, src, BUSY_ICON_BUILD))
			return

		user.visible_message("<span class='notice'>[user.name] planted \the [L] into [src].</span>")
		L.anchored = TRUE
		L.icon_state = "lightstick_[L.s_color][L.anchored]"
		user.drop_held_item()
		L.x = x
		L.y = y
		L.pixel_x += rand(-5,5)
		L.pixel_y += rand(-5,5)
		L.set_light(2)
		playsound(user, 'sound/weapons/genhit.ogg', 25, 1)



//Update icon and sides on start, but skip nearby check for turfs.
/turf/open/floor/plating/ground/snow/Initialize()
	. = ..()
	update_icon(1,1)

/turf/open/floor/plating/ground/snow/Entered(atom/movable/AM)
	if(slayer > 0)
		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			C.next_move_slowdown += (isxeno(C) ? 0.25 : 0.5) * slayer
			if(prob(1))
				to_chat(C, "<span class='warning'>Moving through [src] slows you down.</span>")
	..()


//Update icon
/turf/open/floor/plating/ground/snow/update_icon(update_full, skip_sides)
	icon_state = "snow_[slayer]"
	setDir(pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST))
	switch(slayer)
		if(0)
			name = "dirt floor"
		if(1)
			name = "shallow [initial(name)]"
		if(2)
			name = "deep [initial(name)]"
		if(3)
			name = "very deep [initial(name)]"

	//Update the side overlays
	if(update_full)
		var/turf/open/T
		if(!skip_sides)
			for(var/dirn in GLOB.alldirs)
				var/turf/open/floor/plating/ground/snow/D = get_step(src,dirn)
				if(istype(D))
					//Update turfs that are near us, but only once
					D.update_icon(1,1)

		overlays.Cut()

		for(var/dirn in GLOB.alldirs)
			T = get_step(src, dirn)
			if(istype(T))
				if(slayer > T.slayer && T.slayer < 1)
					var/image/I = new('icons/turf/snow2.dmi', "snow_[(dirn & (dirn-1)) ? "outercorner" : pick("innercorner", "outercorner")]", dir = dirn)
					switch(dirn)
						if(NORTH)
							I.pixel_y = 32
						if(SOUTH)
							I.pixel_y = -32
						if(EAST)
							I.pixel_x = 32
						if(WEST)
							I.pixel_x = -32
						if(NORTHEAST)
							I.pixel_x = 32
							I.pixel_y = 32
						if(SOUTHEAST)
							I.pixel_x = 32
							I.pixel_y = -32
						if(NORTHWEST)
							I.pixel_x = -32
							I.pixel_y = 32
						if(SOUTHWEST)
							I.pixel_x = -32
							I.pixel_y = -32

					I.layer = layer + 0.001 + slayer * 0.0001
					overlays += I


//Explosion act
/turf/open/floor/plating/ground/snow/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(slayer)
				slayer = 0
				update_icon(1, 0)
		if(EXPLODE_HEAVY)
			if(slayer && prob(60))
				slayer = max(slayer - 2, 0)
				update_icon(1, 0)
		if(EXPLODE_LIGHT)
			if(slayer && prob(20))
				slayer -= 1
				update_icon(1, 0)
	return ..()

//SNOW LAYERS-----------------------------------//
/turf/open/floor/plating/ground/snow/layer0
	icon_state = "snow_0"
	slayer = 0

/turf/open/floor/plating/ground/snow/layer1
	icon_state = "snow_1"
	slayer = 1

/turf/open/floor/plating/ground/snow/layer2
	icon_state = "snow_2"
	slayer = 2

/turf/open/floor/plating/ground/snow/layer3
	icon_state = "snow_3"
	slayer = 3



