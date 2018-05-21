


//FLOORS-----------------------------------//
//Snow Floor
/turf/open/snow
	name = "snow layer"
	icon = 'icons/turf/snow2.dmi'
	icon_state = "snow_0"
	is_groundmap_turf = TRUE

	//PLACING/REMOVING/BUILDING
/turf/open/snow/attackby(var/obj/item/I, var/mob/user)

	//Light Stick
	if(istype(I, /obj/item/lightstick))
		var/obj/item/lightstick/L = I
		if(locate(/obj/item/lightstick) in get_turf(src))
			user << "There's already a [L]  at this position!"
			return

		user << "Now planting \the [L]."
		if(!do_after(user,20, TRUE, 5, BUSY_ICON_BUILD))
			return

		user.visible_message("\blue[user.name] planted \the [L] into [src].")
		L.anchored = 1
		L.icon_state = "lightstick_[L.s_color][L.anchored]"
		user.drop_held_item()
		L.x = x
		L.y = y
		L.pixel_x += rand(-5,5)
		L.pixel_y += rand(-5,5)
		L.SetLuminosity(2)
		playsound(user, 'sound/weapons/Genhit.ogg', 25, 1)



//Update icon and sides on start, but skip nearby check for turfs.
/turf/open/snow/New()
	..()
	update_icon(1,1)

/turf/open/snow/Entered(atom/movable/AM)
	if(slayer > 0)
		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			var/slow_amount = 0.75
			var/can_stuck = 1
			if(istype(C, /mob/living/carbon/Xenomorph)||isYautja(C))
				slow_amount = 0.25
				can_stuck = 0
			C.next_move_slowdown += slow_amount * slayer
			if(prob(2))
				C << "<span class='warning'>Moving through [src] slows you down.</span>" //Warning only
			else if(can_stuck && slayer == 3 && prob(2))
				C << "<span class='warning'>You get stuck in [src] for a moment!</span>"
				C.next_move_slowdown += 10
	..()


//Update icon
/turf/open/snow/update_icon(var/update_full, var/skip_sides)
	icon_state = "snow_[slayer]"
	dir = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
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
			for(var/dirn in alldirs)
				var/turf/open/snow/D = get_step(src,dirn)
				if(istype(D))
					//Update turfs that are near us, but only once
					D.update_icon(1,1)

		overlays.Cut()

		for(var/dirn in alldirs)
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
/turf/open/snow/ex_act(severity)
	switch(severity)
		if(1)
			if(slayer)
				slayer = 0
				update_icon(1, 0)
		if(2)
			if(prob(60) && slayer)
				slayer = max(slayer - 2, 0)
				update_icon(1, 0)
		if(3)
			if(prob(20) && slayer)
				slayer -= 1
				update_icon(1, 0)

//SNOW LAYERS-----------------------------------//
/turf/open/snow/layer0
	icon_state = "snow_0"
	slayer = 0

/turf/open/snow/layer1
	icon_state = "snow_1"
	slayer = 1

/turf/open/snow/layer2
	icon_state = "snow_2"
	slayer = 2

/turf/open/snow/layer3
	icon_state = "snow_3"
	slayer = 3



