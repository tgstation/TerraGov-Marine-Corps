#define ICE_TEMPERATURE 223
//ELEVATOR SHAFT-----------------------------------//
/turf/simulated/floor/gm/empty
	name = "empty space"
	icon = 'icons/turf/floors.dmi'
	icon_state = "black"
	density = 1

//FLOORS-----------------------------------//
//Snow Floor
/turf/unsimulated/floor/snow
	name = "snow layer"
	icon = 'icons/turf/snow2.dmi'
	icon_state = "snow_0"
	slayer = 0 //Snow layer, Defined in /turf
	temperature = ICE_TEMPERATURE
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	oxygen = MOLES_O2STANDARD*1.15
	nitrogen = MOLES_N2STANDARD*1.15
	is_groundmap_turf = TRUE

	//PLACING/REMOVING/BUILDING
	attackby(var/obj/item/I, var/mob/user)

		//Light Stick
		if(istype(I, /obj/item/lightstick))
			var/obj/item/lightstick/L = I
			if(locate(/obj/item/lightstick) in get_turf(src))
				user << "There's already a [L]  at this position!"
				return

			user << "Now planting \the [L]."
			if(!do_after(user,20, TRUE, 5, BUSY_ICON_CLOCK))
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

		//Snow Shovel
		if(istype(I, /obj/item/tool/snow_shovel))
			var/obj/item/tool/snow_shovel/S = I
			if(user.action_busy)
				user  << "\red You are already shoveling!"
				return
			switch(S.mode)
				if(0)//Mode 0 -Removing snow
					if(!slayer)
						user  << "\red You can't shovel beyond this layer, the shovel will break!"
						return

					user.visible_message("[user.name] starts clearing out the [src].","You start removing some of the [src].")
					playsound(user, 'sound/weapons/Genhit.ogg', 25, 1)
					if(!do_after(user,50, TRUE, 5, BUSY_ICON_CLOCK))
						user.visible_message("\red \The [user] decides not to clear out \the [src] anymore.")
						return

					if(!slayer)
						user  << "\red You can't shovel beyond this layer, the shovel will break!"
						return

					user.visible_message("\blue \The [user] clears out \the [src].")
					slayer -= 1
					update_icon(1,0)


				if(1) //Mode 1 -Taking/Placing snow
					if(user.action_busy)
						user  << "\red You are already shoveling!"
						return

					//Placing
					if(S.has_snow)
						if(slayer > 2)
							user  << "\red You can't add any more snow here!"
							return

						if(locate(/obj/structure/barricade/snow) in get_turf(src))
							user  << "\red You can't place more snow on top of that barricade, deconstruct it first!"
							return

						user.visible_message("[user.name] starts throwing out the snow to the ground.","You start throwing out the snow to the ground.")
						playsound(user, 'sound/weapons/Genhit.ogg', 25, 1)
						if(!do_after(user,50, TRUE, 5, BUSY_ICON_CLOCK))
							user.visible_message("\red \The [user] decides not to add any more snow to [S].")
							return

						if(slayer > 2)
							user  << "\red You can't add any more snow here!"
							return

						user.visible_message("\blue \The [user] clears out \the [src].")
						slayer += 1
						S.has_snow = 0 //Remove snow from the shovel
						S.update_icon()
						update_icon(1,0)

					//Taking
					else
						if(slayer < 1)
							user  << "\red There is no more snow to pick up!"
							return

						user.visible_message("[user.name] starts clearing out the [src].","You start removing some of the [src].")
						playsound(user, 'sound/weapons/Genhit.ogg', 25, 1)
						if(!do_after(user,50, TRUE, 5, BUSY_ICON_CLOCK))
							user.visible_message("\red \The [user] decides not to clear out \the [src] anymore.")
							return

						if(slayer < 1)
							user  << "\red There is no more snow to pick up!"
							return

						user.visible_message("\blue \The [user] clears out \the [src].")
						slayer -= 1
						S.has_snow = 1
						S.update_icon()
						update_icon(1,0)


				if(2)//Mode 2 -Making barricades

					if(!slayer || slayer == 0)
						user  << "\red You can't build the barricade here, there must be more snow on that area!"
						return

					if(locate(/obj/structure/barricade/snow) in get_turf(src))
						user  << "\red You can't build another barricade on the same spot!"
						return

					user.visible_message("[user.name] starts shaping the barricade.","You start shaping the barricade")
					playsound(user, 'sound/weapons/Genhit.ogg', 25, 1)
					if(!do_after(user,150, TRUE, 5, BUSY_ICON_CLOCK))
						user.visible_message("\red \The [user] decides not to dump \the [S] anymore.")
						return

					if(!slayer || slayer == 0)
						user  << "\red You can't build the barricade here, there must be more snow on that area!"
						return

					if(locate(/obj/structure/barricade/snow) in get_turf(src))
						user  << "\red You can't build another barricade on the same spot!"
						return

					var/obj/structure/barricade/snow/B = new(src)
					user.visible_message("\blue \The [user] creates a [slayer < 3 ? "weak" : "decent"] [B.name].")
					B.icon_state = "barricade_[slayer]"
					B.health = slayer * 25
					B.dir = user.dir
					B.update_icon()
					slayer = 0
					update_icon(1,0)



	//Update icon and sides on start, but skip nearby check for turfs.
	New()
		..()
		update_icon(1,1)

	Entered(atom/movable/AM)
		if(slayer > 0)
			if(iscarbon(AM))
				var/mob/living/carbon/C = AM
				var/slow_amount = 0.75
				var/can_stuck = 1
				if(istype(C, /mob/living/carbon/Xenomorph))
					slow_amount = 0.25
					can_stuck = 0
				C.next_move_slowdown += slow_amount * slayer
				if(prob(2))
					C << "<span class='warning'>Moving through [src] slows you down.</span>" //Warning only
				else if(can_stuck && slayer == 3 && prob(2))
					C << "<span class='warning'>You get stuck in [src] for a moment!</span>"
					C.next_move_slowdown += 10

	//Update icon
	update_icon(var/update_full, var/skip_sides)
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
			var/turf/T
			if(!skip_sides)
				for(var/dirn in alldirs)
					var/turf/unsimulated/floor/snow/D = get_step(src,dirn)
					if(istype(D))
						//Update turfs that are near us, but only once
						D.update_icon(1,1)



			overlays.Cut()
			if(istype(get_step(src, NORTH),/turf/unsimulated/floor) || istype(get_step(src, NORTH),/turf/simulated/floor))
				T = get_step(src, NORTH)
				if (T && slayer > T.slayer && T.slayer < 1)
					var/image/I = new('icons/turf/snow2.dmi', "snow_[pick("innercorner", "outercorner")]", dir = NORTH)
					I.pixel_y = src.pixel_y + 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I

			if(istype(get_step(src, SOUTH),/turf/unsimulated/floor) || istype(get_step(src, SOUTH),/turf/simulated/floor))
				T = get_step(src, SOUTH)
				if (T && slayer > T.slayer && T.slayer < 1)
					var/image/I = new('icons/turf/snow2.dmi', "snow_[pick("innercorner", "outercorner")]", dir = SOUTH)
					I.pixel_y = src.pixel_y - 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I

			if(istype(get_step(src, EAST),/turf/unsimulated/floor) || istype(get_step(src, EAST),/turf/simulated/floor))
				T = get_step(src, EAST)
				if (T && slayer > T.slayer && T.slayer < 1)
					var/image/I = new('icons/turf/snow2.dmi', "snow_[pick("innercorner", "outercorner")]", dir = EAST)
					I.pixel_x = src.pixel_x + 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I

			if(istype(get_step(src, WEST),/turf/unsimulated/floor) || istype(get_step(src, WEST),/turf/simulated/floor))
				T = get_step(src, WEST)
				if (T && slayer > T.slayer && T.slayer < 1)
					var/image/I = new('icons/turf/snow2.dmi', "snow_[pick("innercorner", "outercorner")]", dir = WEST)
					I.pixel_x = src.pixel_x - 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I

			if(istype(get_step(src, NORTHWEST),/turf/unsimulated/floor) || istype(get_step(src, NORTHWEST),/turf/simulated/floor))
				T = get_step(src, NORTHWEST)
				if (T && slayer > T.slayer && T.slayer < 1)
					var/image/I = new('icons/turf/snow2.dmi', "snow_outercorner", dir = NORTHWEST)
					I.pixel_x = src.pixel_x - 32
					I.pixel_y = src.pixel_y + 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I

			if(istype(get_step(src, NORTHEAST),/turf/unsimulated/floor) || istype(get_step(src, NORTHEAST),/turf/simulated/floor))
				T = get_step(src, NORTHEAST)
				if (T && slayer > T.slayer && T.slayer < 1)
					var/image/I = new('icons/turf/snow2.dmi', "snow_outercorner", dir = NORTHEAST)
					I.pixel_x = src.pixel_x + 32
					I.pixel_y = src.pixel_y + 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I

			if(istype(get_step(src, SOUTHWEST),/turf/unsimulated/floor) || istype(get_step(src, SOUTHWEST),/turf/simulated/floor))
				T = get_step(src, SOUTHWEST)
				if (T && slayer > T.slayer && T.slayer < 1)
					var/image/I = new('icons/turf/snow2.dmi', "snow_outercorner", dir = SOUTHWEST)
					I.pixel_x = src.pixel_x - 32
					I.pixel_y = src.pixel_y - 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I

			if(istype(get_step(src, SOUTHEAST),/turf/unsimulated/floor) || istype(get_step(src, SOUTHEAST),/turf/simulated/floor))
				T = get_step(src, SOUTHEAST && T.slayer < 1)
				if (T && slayer > T.slayer)
					var/image/I = new('icons/turf/snow2.dmi', "snow_outercorner]", dir = SOUTHEAST)
					I.pixel_x = src.pixel_x + 32
					I.pixel_y = src.pixel_y - 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I


			/* OLD ICE COLONY CODE
			overlays.Cut()
			if(istype(get_step(src, NORTH),/turf/unsimulated/floor) || istype(get_step(src, NORTH),/turf/simulated/floor))
				T = get_step(src, NORTH)
				if (T && slayer > T.slayer)
					var/image/I = new('icons/turf/snow.dmi', "snow_overlay_[slayer]_[pick("0", "1", "2")]_n")
					I.pixel_y = src.pixel_y + 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I

			if(istype(get_step(src, SOUTH),/turf/unsimulated/floor) || istype(get_step(src, SOUTH),/turf/simulated/floor))
				T = get_step(src, SOUTH)
				if (T && slayer > T.slayer)
					var/image/I = new('icons/turf/snow.dmi', "snow_overlay_[slayer]_[pick("0", "1", "2")]_s")
					I.pixel_y = src.pixel_y - 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I

			if(istype(get_step(src, EAST),/turf/unsimulated/floor) || istype(get_step(src, EAST),/turf/simulated/floor))
				T = get_step(src, EAST)
				if (T && slayer > T.slayer)
					var/image/I = new('icons/turf/snow.dmi', "snow_overlay_[slayer]_[pick("0", "1", "2")]_e")
					I.pixel_x = src.pixel_x + 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I

			if(istype(get_step(src, WEST),/turf/unsimulated/floor) || istype(get_step(src, WEST),/turf/simulated/floor))
				T = get_step(src, WEST)
				if (T && slayer > T.slayer)
					var/image/I = new('icons/turf/snow.dmi', "snow_overlay_[slayer]_[pick("0", "1", "2")]_w")
					I.pixel_x = src.pixel_x - 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I

			if(istype(get_step(src, NORTHWEST),/turf/unsimulated/floor) || istype(get_step(src, NORTHWEST),/turf/simulated/floor))
				T = get_step(src, NORTHWEST)
				if (T && slayer > T.slayer)
					var/image/I = new('icons/turf/snow.dmi', "snow_overlay_[slayer]_0_nw")
					I.pixel_x = src.pixel_x - 32
					I.pixel_y = src.pixel_y + 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I

			if(istype(get_step(src, NORTHEAST),/turf/unsimulated/floor) || istype(get_step(src, NORTHEAST),/turf/simulated/floor))
				T = get_step(src, NORTHEAST)
				if (T && slayer > T.slayer)
					var/image/I = new('icons/turf/snow.dmi', "snow_overlay_[slayer]_0_ne")
					I.pixel_x = src.pixel_x + 32
					I.pixel_y = src.pixel_y + 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I

			if(istype(get_step(src, SOUTHWEST),/turf/unsimulated/floor) || istype(get_step(src, SOUTHWEST),/turf/simulated/floor))
				T = get_step(src, SOUTHWEST)
				if (T && slayer > T.slayer)
					var/image/I = new('icons/turf/snow.dmi', "snow_overlay_[slayer]_0_sw")
					I.pixel_x = src.pixel_x - 32
					I.pixel_y = src.pixel_y - 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I

			if(istype(get_step(src, SOUTHEAST),/turf/unsimulated/floor) || istype(get_step(src, SOUTHEAST),/turf/simulated/floor))
				T = get_step(src, SOUTHEAST)
				if (T && slayer > T.slayer)
					var/image/I = new('icons/turf/snow.dmi', "snow_overlay_[slayer]_0_se")
					I.pixel_x = src.pixel_x + 32
					I.pixel_y = src.pixel_y - 32
					I.layer = src.layer + 0.001 + slayer * 0.0001
					overlays += I
			*/

	//Explosion act
	ex_act(severity)
		switch(severity)
			if(1.0)
				if(src.slayer)
					src.slayer = 0
					src.update_icon(1,0)
			if(2.0)
				if(prob(60) && src.slayer)
					src.slayer -= 1
					src.update_icon(1,0)
			if(3.0)
				if(prob(20) && src.slayer)
					src.slayer -= 1
					src.update_icon(1,0)
		return

//SNOW LAYERS-----------------------------------//
/turf/unsimulated/floor/snow/layer0
	icon_state = "snow_0"
	slayer = 0

/turf/unsimulated/floor/snow/layer1
	icon_state = "snow_1"
	slayer = 1

/turf/unsimulated/floor/snow/layer2
	icon_state = "snow_2"
	slayer = 2

/turf/unsimulated/floor/snow/layer3
	icon_state = "snow_3"
	slayer = 3


//Simple weather object. Every 5-10 seconds, it selects a snow turf at random coords and adds 1 layer of snow to it if possible.

/obj/structure/snow_weather_effect
	name = "This should not show"
	density = 0
	opacity = 0
	unacidable = 1
	var/intensity = 600

/obj/structure/snow_weather_effect/New()
	spawn(2800)//Wait till the game ticker is done
		if (istype(ticker.mode,/datum/game_mode/ice_colony))
			intensity = rand(50, 200)
			start_weather()

/obj/structure/snow_weather_effect/proc/start_weather()
	x = rand(90,245)
	y = rand(10,245)
	var/turf/unsimulated/floor/snow/T
	if (istype(src.loc,/turf/unsimulated/floor/snow)) //Find the snow turf at random coords
		T = src.loc
		if (T && T.slayer < 2)
			T.slayer++
			T.update_icon(1,0)
			if (prob(2))
				intensity = rand(50, 200) //Change Speed
	//Repeat 4eva
	sleep(intensity)
	start_weather()

/obj/structure/snow_weather_effect/ex_act(severity)
	return

//Dirt Floor
/turf/unsimulated/floor/dirt
	name = "dirt floor"
	icon = 'icons/turf/snow2.dmi'
	icon_state = "dirt"
	temperature = ICE_TEMPERATURE
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	oxygen = MOLES_O2STANDARD*1.15
	nitrogen = MOLES_N2STANDARD*1.15

	//Randomize dirt floor sprite
	New()
		..()
		dir = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)

//Ice Floor
/turf/unsimulated/floor/ice
	name = "ice floor"
	icon = 'icons/turf/ice.dmi'
	icon_state = "ice_floor"
	temperature = ICE_TEMPERATURE
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	oxygen = MOLES_O2STANDARD*1.15
	nitrogen = MOLES_N2STANDARD*1.15

	//Randomize ice floor sprite
	New()
		..()
		dir = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)


//ICE WALLS-----------------------------------//
//Ice Wall
/turf/unsimulated/wall/ice
	name = "dense ice wall"
	icon = 'icons/turf/icewall.dmi'
	icon_state = "Single"
	desc = "It is very thick."
	temperature = ICE_TEMPERATURE
	oxygen = MOLES_O2STANDARD*1.15
	nitrogen = MOLES_N2STANDARD*1.15
	slayer = 10 //To check where to put the overlay

/turf/unsimulated/wall/ice/single
	icon_state = "Single"

/turf/unsimulated/wall/ice/end
	icon_state = "End"

/turf/unsimulated/wall/ice/straight
	icon_state = "Straight"

/turf/unsimulated/wall/ice/corner
	icon_state = "Corner"

/turf/unsimulated/wall/ice/junction
	icon_state = "T_Junction"

/turf/unsimulated/wall/ice/intersection
	icon_state = "Intersection"

		//update_icon(1)

	/*
	update_icon(var/skip_sides)
		//Update the side overlays
		var/turf/T
		if(!skip_sides)
			for(var/dirn in cardinal)
				var/turf/unsimulated/wall/ice/D = get_step(src,dirn)
				if(istype(D))
					//Update turfs that are near us, but only once
					D.update_icon(1)

		overlays.Cut()
		if(istype(get_step(src, NORTH),/turf))
			T = get_step(src, NORTH)
			if (T && slayer > T.slayer)
				var/image/I = new('icons/turf/snow.dmi', "ice_wall_[slayer]_n")
				I.pixel_y = src.pixel_y + 32
				I.layer = src.layer + 0.001
				overlays += I


		if(istype(get_step(src, SOUTH),/turf))
			T = get_step(src, SOUTH)
			if (T && slayer > T.slayer)
				var/image/I = new('icons/turf/snow.dmi', "ice_wall_[slayer]_s")
				I.pixel_y = src.pixel_y - 32
				I.layer = src.layer + 0.001
				overlays += I


		if(istype(get_step(src, EAST),/turf))
			T = get_step(src, EAST)
			if (T && slayer > T.slayer)
				var/image/I = new('icons/turf/snow.dmi', "ice_wall_[slayer]_e")
				I.pixel_x = src.pixel_x + 32
				I.layer = src.layer + 0.001
				overlays += I


		if(istype(get_step(src, WEST),/turf))
			T = get_step(src, WEST)
			if (T && slayer > T.slayer)
				var/image/I = new('icons/turf/snow.dmi', "ice_wall_[slayer]_w")
				I.pixel_x = src.pixel_x - 32
				I.layer = src.layer + 0.001
				overlays += I
		*/


//Ice Thin Wall
/turf/unsimulated/wall/ice/thin
	name = "thin ice wall"
	icon = 'icons/turf/icewalllight.dmi'
	icon_state = "Single"
	desc = "It is very thin."
	slayer = 9
	opacity = 0

/turf/unsimulated/wall/ice/thin/single
	icon_state = "Single"

/turf/unsimulated/wall/ice/thin/end
	icon_state = "End"

/turf/unsimulated/wall/ice/thin/straight
	icon_state = "Straight"

/turf/unsimulated/wall/ice/thin/corner
	icon_state = "Corner"

/turf/unsimulated/wall/ice/thin/junction
	icon_state = "T_Junction"

/turf/unsimulated/wall/ice/thin/intersection
	icon_state = "Intersection"

//Ice Secret Wall
/turf/unsimulated/wall/ice/secret
	icon_state = "ice_wall_0"
	desc = "There is something inside..."

//ROCK WALLS------------------------------//

//Icy Rock
/turf/unsimulated/wall/ice_rock
	name = "Icy rock"
	icon = 'icons/turf/rockwall.dmi'
	temperature = ICE_TEMPERATURE
	oxygen = MOLES_O2STANDARD*1.15
	nitrogen = MOLES_N2STANDARD*1.15

/turf/unsimulated/wall/ice_rock/single
	icon_state = "single"

/turf/unsimulated/wall/ice_rock/singlePart
	icon_state = "single_part"

/turf/unsimulated/wall/ice_rock/singleT
	icon_state = "single_tshape"

/turf/unsimulated/wall/ice_rock/singleEnd
	icon_state = "single_ends"

/turf/unsimulated/wall/ice_rock/fourway
	icon_state = "4-way"

/turf/unsimulated/wall/ice_rock/corners
	icon_state = "full_corners"

//Directional walls each have 4 possible sprites and are
//randomized on New().
/turf/unsimulated/wall/ice_rock/northWall
	icon_state = "north_wall"
	New()
		..()
		dir = pick(NORTH,SOUTH,EAST,WEST)

/turf/unsimulated/wall/ice_rock/southWall
	icon_state = "south_wall"
	New()
		..()
		dir = pick(NORTH,SOUTH,EAST,WEST)

/turf/unsimulated/wall/ice_rock/westWall
	icon_state = "west_wall"
	New()
		..()
		dir = pick(NORTH,SOUTH,EAST,WEST)

/turf/unsimulated/wall/ice_rock/eastWall
	icon_state = "east_wall"
	New()
		..()
		dir = pick(NORTH,SOUTH,EAST,WEST)

/turf/unsimulated/wall/ice_rock/cornerOverlay
	icon_state = "corner_overlay"

//ITEMS-----------------------------------//
/obj/item/storage/box/lightstick
	name = "box of lightsticks"
	desc = "Contains blue lightsticks."
	icon_state = "lightstick"
	can_hold = list(/obj/item/lightstick)

	New()
		..()
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)

/obj/item/storage/box/lightstick/red
	desc = "Contains red lightsticks."
	icon_state = "lightstick2"

	New()
		..()
		new /obj/item/lightstick/red(src)
		new /obj/item/lightstick/red(src)
		new /obj/item/lightstick/red(src)
		new /obj/item/lightstick/red(src)
		new /obj/item/lightstick/red(src)
		new /obj/item/lightstick/red(src)
		new /obj/item/lightstick/red(src)

//Lightsticks----------
//Blue
/obj/item/lightstick
	name = "blue lightstick"
	desc = "You can stick them in the ground"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lightstick_blue0"
	l_color = "#47A3FF" //Blue
	var/s_color = "blue"

	Crossed(var/mob/living/O)
		if(anchored && prob(20))
			if(!istype(O,/mob/living/carbon/Xenomorph/Larva))
				visible_message("<span class='danger'>[O] tramples the [src]!</span>")
				playsound(src, 'sound/weapons/Genhit.ogg', 25, 1)
				if(istype(O,/mob/living/carbon/Xenomorph))
					if(prob(40))
						cdel(src)
					else
						anchored = 0
						icon_state = "lightstick_[s_color][anchored]"
						SetLuminosity(0)
						pixel_x = 0
						pixel_y = 0
				else
					anchored = 0
					icon_state = "lightstick_[s_color][anchored]"
					SetLuminosity(0)
					pixel_x = 0
					pixel_y = 0

	//Removing from turf
	attack_hand(mob/user)
		..()
		if(!anchored)//If planted
			return

		user << "You start pulling out \the [src]."
		if(!do_after(user,20, TRUE, 5, BUSY_ICON_CLOCK))
			return

		anchored = 0
		user.visible_message("[user.name] removes \the [src] from the ground.","You remove the [src] from the ground.")
		icon_state = "lightstick_[s_color][anchored]"
		SetLuminosity(0)
		pixel_x = 0
		pixel_y = 0
		playsound(user, 'sound/weapons/Genhit.ogg', 25, 1)

	//Remove lightsource
	Dispose()
		SetLuminosity(0)
		. = ..()

//Red
/obj/item/lightstick/red
	name = "red lightstick"
	l_color = "#CC3300"
	icon_state = "lightstick_red0"
	s_color = "red"



/obj/machinery/computer/shuttle_control/elevator1
	name = "Elevator Console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "elevator"
	shuttle_tag = "Elevator 1"
	unacidable = 1
	exproof = 1
	density = 0
	req_access = null

/obj/machinery/computer/shuttle_control/elevator2
	name = "Elevator Console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "elevator"
	shuttle_tag = "Elevator 2"
	unacidable = 1
	exproof = 1
	density = 0
	req_access = null

/obj/machinery/computer/shuttle_control/elevator3
	name = "Elevator Console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "elevator"
	shuttle_tag = "Elevator 3"
	unacidable = 1
	exproof = 1
	density = 0
	req_access = null

/obj/machinery/computer/shuttle_control/elevator4
	name = "Elevator Console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "elevator"
	shuttle_tag = "Elevator 4"
	unacidable = 1
	exproof = 1
	density = 0
	req_access = null

//RESEARCH DECORATION-----------------------//
//Most of icons made by ~Morrinn
obj/structure/xenoautopsy
	name = "Research thingies"
	icon = 'icons/obj/alien_autopsy.dmi'
	icon_state = "jarshelf_9"

obj/structure/xenoautopsy/jar_shelf
	name = "jar shelf"
	icon_state = "jarshelf_0"
	var/randomise = 1 //Random icon

	New()
		if(randomise)
			icon_state = "jarshelf_[rand(0,9)]"

obj/structure/xenoautopsy/tank
	name = "cryo tank"
	icon_state = "tank_empty"
	desc = "It is empty."

obj/structure/xenoautopsy/tank/broken
	name = "cryo tank"
	icon_state = "tank_broken"
	desc = "Something broke it..."

obj/structure/xenoautopsy/tank/alien
	name = "cryo tank"
	icon_state = "tank_alien"
	desc = "There is something big inside..."

obj/structure/xenoautopsy/tank/hugger
	name = "cryo tank"
	icon_state = "tank_hugger"
	desc = "There is something spider-like inside..."

obj/structure/xenoautopsy/tank/larva
	name = "cryo tank"
	icon_state = "tank_larva"
	desc = "There is something worm-like inside..."

obj/item/alienjar
	name = "sample jar"
	icon = 'icons/obj/alien_autopsy.dmi'
	icon_state = "jar_sample"
	desc = "Used to store organic samples inside for preservation."

	New()
		var/image/I
		I = image('icons/obj/alien_autopsy.dmi', "sample_[rand(0,11)]")
		I.layer = src.layer - 0.1
		overlays += I
		pixel_x += rand(-3,3)
		pixel_y += rand(-3,3)

//TESTING
/datum/file/program/door_control
	name = "Door control"
	desc = "This program can control doors on range."
	active_state = "comm_log"
	var/id = null
	var/range = 10
	var/normaldoorcontrol = CONTROL_POD_DOORS
		//0 = Pod Doors
		//1 = Normal Doors
		//2 = Emmiters
	var/desiredstate = 0
		//0 = Closed
		//1 = Open
		//2 = Toggle
	var/specialfunctions = 1
		//Bitflag, 	1 = Open
		//			2 = IDscan
		//			4 = Bolts
		//			8 = Shock
		//			16 = Door safties
	var/door_name = "" // Used for data only
	var/action_name = "" // Used for button name

/datum/file/program/door_control/interact()
	if(!interactable())
		return

	var/dat = ""
	dat += "<b>[door_name]</b> access control"
	dat += "<br><b>Controls: </b>"
	dat += "<br><b>[topic_link(src,"doorcontrol","[action_name]")]"
	popup.set_content(dat)
	popup.open()

/datum/file/program/door_control/proc/handle_door()
	for(var/obj/machinery/door/airlock/D in range(range))
		if(D.id_tag == src.id)
			if(specialfunctions & OPEN)
				if (D.density)
					spawn(0)
						D.open()
						return
				else
					spawn(0)
						D.close()
						return
			switch(desiredstate)
				//Close
				if(0)
					if(specialfunctions & IDSCAN)
						D.aiDisabledIdScanner = 0
					if(specialfunctions & BOLTS)
						if(!D.isWireCut(4) && D.arePowerSystemsOn())
							D.unlock()
					if(specialfunctions & SHOCK)
						D.secondsElectrified = 0
					if(specialfunctions & SAFE)
						D.safe = 1
				//Open
				if(1)
					if(specialfunctions & IDSCAN)
						D.aiDisabledIdScanner = 1
					if(specialfunctions & BOLTS)
						D.lock()
					if(specialfunctions & SHOCK)
						D.secondsElectrified = -1
					if(specialfunctions & SAFE)
						D.safe = 0
				//Toggle
				if(2)
					if(specialfunctions & IDSCAN && D.aiDisabledIdScanner == 0)
						D.aiDisabledIdScanner = 1
					else
						D.aiDisabledIdScanner = 0
					if(specialfunctions & BOLTS && D.locked == 0)
						D.lock()
					else
						D.unlock()
					if(specialfunctions & SHOCK && D.secondsElectrified == 0)
						D.secondsElectrified = -1
					else
						D.secondsElectrified = 0
					if(specialfunctions & SAFE && D.safe == 0)
						D.safe = 1
					else
						D.safe = 0

/datum/file/program/door_control/proc/handle_pod()
	for(var/obj/machinery/door/poddoor/M in machines)
		if(M.id == src.id)
			if(M.density)
				spawn(0)
					M.open()
					return
			else
				spawn(0)
					M.close()
					return

/datum/file/program/door_control/proc/handle_emitters()
	for(var/obj/machinery/power/emitter/E in range(range))
		if(E.id == src.id)
			spawn(0)
				E.activate()
				return

/datum/file/program/door_control/Topic(href, list/href_list)
	if(!interactable() || ..(href,href_list))
		return
	..()
	if ("doorcontrol" in href_list)
		switch(normaldoorcontrol)
			if(CONTROL_NORMAL_DOORS)
				handle_door()
			if(CONTROL_POD_DOORS)
				handle_pod()
			//if(CONTROL_EMITTERS)
				//handle_emitters()



//ICE LAPTOPS
//Generic Ice planet laptop
/obj/machinery/computer3/laptop/ice_planet
	spawn_parts = list(/obj/item/computer3_part/storage/hdd, /obj/item/computer3_part/storage/removable)


//XENOBIO LAB-----
//-----Laptop-----
/obj/machinery/computer3/laptop/ice_planet/xenobio_lab

	New()
		..()
		spawn_files += (/datum/file/program/data/text/xenobio_log)
		update_spawn_files()

//-----Xenobio Lab Research Reports
/datum/file/program/data/text/xenobio_log
	name = "Xenobio Research Report"
	extension = "txt"
	image = 'icons/ntos/file.png'
	dat = "text goes here!"
	active_state = "text"



//ANOMALY LAB-----
//-----Laptop-----
/obj/machinery/computer3/laptop/ice_planet/anomaly_lab

	New()
		..()
		spawn_files += (/datum/file/program/data/text/anomaly_log)
		update_spawn_files()

//-----Anomaly Lab Research Reports
/datum/file/program/data/text/anomaly_log
	name = "Anomaly Research Report"
	extension = "txt"
	image = 'icons/ntos/file.png'
	dat = "text goes here!"
	active_state = "text"

//ACES LAB-----
//-----Laptop-----
/obj/machinery/computer3/laptop/ice_planet/aces_lab

	New()
		..()
		spawn_files += (/datum/file/program/data/text/aces_log)
		spawn_files += (/datum/file/program/door_control/aces_storage)
		update_spawn_files()

/obj/item/disk/file/test
	spawn_files = list(/datum/file/program/door_control/aces_storage)

//-----ACES Research Reports
/datum/file/program/data/text/aces_log
	name = "ACES Research Reports"
	extension = "txt"
	image = 'icons/ntos/file.png'
	dat = "<b><font face=\"verdana\" color=\"green\">ACES Research Reports</font></b><br>"
	active_state = "text"
	logs = list(
				"Research Log I" = "<b><font face=\"verdana\" color=\"green\">Research Log I</font></b><br><br>This log is very nice looking!"
				)


//-----ACES Storage Access Program
/datum/file/program/door_control/aces_storage
	name = "ACES Storage Access"
	desc = "This program can control doors on range."
	active_state = "comm_log"
	id = "aces_secure"
	range = 20
	normaldoorcontrol = 0
	desiredstate = 2
	specialfunctions = 1
	door_name = "ACES Lab Storage Secure Door"
	action_name = "Toggle Door"

//-----PaperWork-----


//RD OFFICE-----
//-----Laptop-----
/obj/machinery/computer3/laptop/ice_planet/rd

	New()
		..()
		spawn_files += (/datum/file/program/data/text/rd_log)
		spawn_files += (/datum/file/program/door_control/armory)
		update_spawn_files()

//-----Research Director Reports
/datum/file/program/data/text/rd_log
	name = "Research Director's Report"
	extension = "txt"
	image = 'icons/ntos/file.png'
	dat = "text goes here!"
	active_state = "text"

//-----Armory Access Program
/datum/file/program/door_control/armory
	name = "Armory Access"
	desc = "This program can control doors on range."
	active_state = "comm_log"
	id = "armory_secure"
	range = 20
	normaldoorcontrol = 0
	desiredstate = 2
	specialfunctions = 1
	door_name = "Armory Secure Door"
	action_name = "Toggle Door"
