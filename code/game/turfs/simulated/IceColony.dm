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
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow0_0"
	slayer = 0 //Snow layer, Defined in /turf
	temperature = ICE_TEMPERATURE
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	oxygen = MOLES_O2STANDARD*1.15
	nitrogen = MOLES_N2STANDARD*1.15

	//PLACING/REMOVING/BUILDING
	attackby(var/obj/item/I, var/mob/user)

		//Light Stick
		if(istype(I, /obj/item/lightstick))
			var/obj/item/lightstick/L = I
			if(locate(/obj/item/lightstick) in get_turf(src))
				user << "There's already a [L]  at this position!"
				return

			user << "Now planting \the [L]."
			if(!do_after(user,20))
				return

			user.visible_message("\blue[user.name] planted \the [L] into [src].")
			L.anchored = 1
			L.icon_state = "lightstick_[L.s_color][L.anchored]"
			user.drop_item()
			L.x = x
			L.y = y
			L.pixel_x += rand(-5,5)
			L.pixel_y += rand(-5,5)
			L.SetLuminosity(2)
			playsound(user, 'sound/weapons/Genhit.ogg', 25, 1)

		//Snow Shovel
		if(istype(I, /obj/item/snow_shovel))
			var/obj/item/snow_shovel/S = I
			//Mode 0 -Removing snow
			if(S.mode == 0)
				if(S.working)
					user  << "\red You are already shoveling!"
					return

				if(!slayer)
					user  << "\red You can't shovel beyond this layer, the shovel will break!"
					return

				user.visible_message("[user.name] starts clearing out the [src].","You start removing some of the [src].")
				S.working = 1
				playsound(user, 'sound/weapons/Genhit.ogg', 25, 1)
				if(!do_after(user,50))
					user.visible_message("\red \The [user] decides not to clear out \the [src] anymore.")
					S.working = 0
					return

				if(!slayer)
					user  << "\red You can't shovel beyond this layer, the shovel will break!"
					return

				user.visible_message("\blue \The [user] clears out \the [src].")
				slayer -= 1
				update_icon(1,0)
				S.working = 0

			//Mode 1 -Taking/Placing snow
			if(S.mode == 1)
				if(S.working)
					user  << "\red You are already shoveling!"
					return

				//Taking
				if(S.has_snow)
					if(slayer == 3)
						user  << "\red You can't add any more snow here!"
						return

					if(locate(/obj/structure/barricade/snow) in get_turf(src))
						user  << "\red You can't place more snow on top of that barricade, deconstruct it first!"
						return

					user.visible_message("[user.name] starts throwing out the snow to the ground.","You start throwing out the snow to the ground.")
					S.working = 1
					playsound(user, 'sound/weapons/Genhit.ogg', 25, 1)
					if(!do_after(user,50))
						user.visible_message("\red \The [user] decides not to add any more snow to [S].")
						S.working = 0
						return

					if(slayer == 3)
						user  << "\red You can't add any more snow here!"
						S.working = 0
						return

					user.visible_message("\blue \The [user] clears out \the [src].")
					slayer += 1
					S.has_snow = 0 //Remove snow from the shovel
					S.update_icon()
					update_icon(1,0)
					S.working = 0

				//Placing
				else
					if(slayer <= 0)
						user  << "\red There is no more snow to pick up!"
						return

					user.visible_message("[user.name] starts clearing out the [src].","You start removing some of the [src].")
					S.working = 1
					playsound(user, 'sound/weapons/Genhit.ogg', 25, 1)
					if(!do_after(user,50))
						user.visible_message("\red \The [user] decides not to clear out \the [src] anymore.")
						S.working = 0
						return

					if(slayer <= 0)
						user  << "\red There is no more snow to pick up!"
						S.working = 0
						return

					user.visible_message("\blue \The [user] clears out \the [src].")
					slayer -= 1
					S.has_snow = 1
					S.update_icon()
					update_icon(1,0)
					S.working = 0

			//Mode 2 -Making barricades
			if(S.mode == 2)
				if(S.working)//If adding snow
					user  << "\red You are already shoveling!"
					return

				if(!slayer)
					user  << "\red You can't build the barricade here, there must be more snow on that area!"
					return

				if(locate(/obj/structure/barricade/snow) in get_turf(src))
					user  << "\red You can't build another barricade on the same spot!"
					return

				user.visible_message("[user.name] starts shaping the barricade.","You start shaping the barricade")
				S.working = 1
				playsound(user, 'sound/weapons/Genhit.ogg', 25, 1)
				if(!do_after(user,150))
					user.visible_message("\red \The [user] decides not to dump \the [S] anymore.")
					S.working = 0
					return

				if(!slayer)
					user  << "\red You can't build the barricade here, there must be more snow on that area!"
					S.working = 0
					return

				if(locate(/obj/structure/barricade/snow) in get_turf(src))
					user  << "\red You can't build another barricade on the same spot!"
					S.working = 0
					return

				var/obj/structure/barricade/snow/B = new/obj/structure/barricade/snow(src)
				user.visible_message("\blue \The [user] creates a [slayer < 3 ? "weak" : "decent"] [B].")
				B.health = slayer * 25
				slayer = 0
				update_icon(1,0)
				S.working = 0


	//Update icon and sides on start, but skip nearby check for turfs.
	New()
		..()
		update_icon(1,1)

	//Update icon
	update_icon(var/update_full, var/skip_sides)
		icon_state = "snow[slayer]_[pick("1","2","3")]"
		switch(slayer)
			if(0)
				name = "[initial(name)]"
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
	icon_state = "snow0_0"
	slayer = 0

/turf/unsimulated/floor/snow/layer1
	icon_state = "snow1_0"
	slayer = 1

/turf/unsimulated/floor/snow/layer2
	icon_state = "snow2_0"
	slayer = 2

/turf/unsimulated/floor/snow/layer3
	icon_state = "snow3_0"
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
		if (T && T.slayer < 3)
			T.slayer++
			T.update_icon(1,0)
			if (prob(2))
				intensity = rand(50, 200) //Change Speed
	//Repeat 4eva
	sleep(intensity)
	start_weather()

/obj/structure/snow_weather_effect/ex_act(severity)
	return

//Ice Floor
/turf/unsimulated/floor/ice
	name = "ice floor"
	icon = 'icons/turf/snow.dmi'
	icon_state = "ice_floor"
	temperature = ICE_TEMPERATURE
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	oxygen = MOLES_O2STANDARD*1.15
	nitrogen = MOLES_N2STANDARD*1.15

//ICE WALLS-----------------------------------//
//Ice Wall
/turf/unsimulated/wall/ice
	name = "dense ice wall"
	icon = 'icons/turf/snow.dmi'
	icon_state = "ice_wall"
	desc = "It is very thick."
	temperature = ICE_TEMPERATURE
	oxygen = MOLES_O2STANDARD*1.15
	nitrogen = MOLES_N2STANDARD*1.15
	slayer = 10 //To check where to put the overlay

	New()
		..()
		update_icon(1)

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


//Ice Thin Wall
/turf/unsimulated/wall/ice/thin
	name = "thin ice wall"
	icon_state = "ice_wall_thin"
	desc = "It is very thin."
	opacity = 0
	slayer = 9

//Ice Secret Wall
/turf/unsimulated/wall/ice/secret
	icon_state = "ice_wall_0"
	desc = "There is something inside..."

//Icy Rock
/turf/unsimulated/wall/ice_rock
	name = "Icy rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock_ice"
	temperature = ICE_TEMPERATURE
	oxygen = MOLES_O2STANDARD*1.15
	nitrogen = MOLES_N2STANDARD*1.15

//ITEMS-----------------------------------//
/obj/item/weapon/storage/box/lightstick
	name = "box of lightsticks"
	desc = "Contains blue lightsticks."
	icon_state = "lightstick"

	New()
		..()
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)

/obj/item/weapon/storage/box/lightstick/red
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
						Del()
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
		if(!do_after(user,20))
			return

		anchored = 0
		user.visible_message("[user.name] removes \the [src] from the ground.","You remove the [src] from the ground.")
		icon_state = "lightstick_[s_color][anchored]"
		SetLuminosity(0)
		pixel_x = 0
		pixel_y = 0
		playsound(user, 'sound/weapons/Genhit.ogg', 25, 1)

	//Remove lightsource
	Del()
		SetLuminosity(0)
		..()

//Red
/obj/item/lightstick/red
	name = "red lightstick"
	l_color = "#CC3300"
	icon_state = "lightstick_red0"
	s_color = "red"

//Snow Shovel----------
/obj/item/snow_shovel
	name = "snow shovel"
	desc = "I had enough winter for this year!"
	icon = 'icons/obj/items.dmi'
	icon_state = "snow_shovel"
	item_state = "shovel"
	w_class = 4.0
	force = 5.0
	throwforce = 3.0
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	var/working = 0
	var/mode = 0
		//0 = remove
		//1 = take/put
		//2 = make/remove barricade
	var/has_snow = 0//Do we have snow on it?

	//Switch modes
	attack_self(mob/user as mob)
		if(working)
			user  << "\red Finish the task first!"
			return
		has_snow = 0
		update_icon()

		if(mode == 0)
			mode = 1
			user  << "\blue You will now collect the snow so you can place it on another pile!"

		else if(mode == 1)
			mode = 2
			user  << "\blue You will now make/remove snow barricades! The deeper the layer, the stronger it is!"

		else if(mode == 2)
			mode = 0
			user  << "\blue You will now remove snow layers!"

	//Update overlay
	update_icon()
		overlays.Cut()
		if(has_snow)
			overlays += image('icons/turf/snow.dmi', "snow_shovel_overlay")

	//Examine
	examine()
		..()
		if(mode == 0)
			usr << "\blue Selected mode: Removing snow."
		else
			usr << "\blue Selected mode: [mode == 1 ? "Collecting/Throwing snow" : "Building/Removing barricades"]."

//Snow barricade----------
/obj/structure/barricade/snow
	name = "snow barricade"
	desc = "It could be worse..."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow_barricade_0"
	var/health = 50 //Actual health depends on snow layer
	climbable = 1
	density = 1
	anchored = 1
	layer = 2.9

	//Item Attack
	attackby(obj/item/W as obj, mob/user as mob)
		//Removing the barricades
		if(istype(W, /obj/item/snow_shovel))
			var/obj/item/snow_shovel/S = W
			if(S.mode == 2)
				if(S.working)
					user  << "\red You are already shoveling!"
					return
				user.visible_message("[user.name] starts clearing out \the [src].","You start removing \the [src].")
				S.working = 1
				if(!do_after(user,100))
					user.visible_message("\red \The [user] decides not to clear out \the [src] anymore.")
					S.working = 0
					return
				user.visible_message("\blue \The [user] clears out \the [src].")
				S.working = 0
				health_check(1)
				return

		//Attacking
		else
			switch(W.damtype)
				if("fire")
					src.health -= W.force * 0.6
				if("brute")
					src.health -= W.force * 0.3
				else
			health_check()
			..()

	//Constructed
	New()
		update_nearby_icons()

	//Check Health
	proc/health_check(var/die)
		if(health < 1 || die)
			update_nearby_icons()
			visible_message("\red <B>The [src] falls apart!</B>")
			del(src)

	//Explosion Act
	ex_act(severity)
		switch(severity)
			if(1.0)
				visible_message("\red <B>The [src] is blown apart!</B>")
				src.update_nearby_icons()
				del(src)
				return
			if(2.0)
				src.health -= rand(30,60)
				if (src.health <= 0)
					visible_message("\red <B>The [src] is blown apart!</B>")
					src.update_nearby_icons()
					del(src)
				return
			if(3.0)
				src.health -= rand(10,30)
				if (src.health <= 0)
					visible_message("\red <B>The [src] is blown apart!</B>")
					src.update_nearby_icons()
					del(src)
				return

	meteorhit()
		visible_message("\red <B>The [src] is blown apart!</B>")
		health_check(1)
		return

	blob_act()
		src.health -= 25
		visible_message("\red <B>The blob eats through the [src]!</B>")
		src.health_check()
		return

	//Bullet Passable
	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group || (height==0)) return 1
		if(istype(mover,/obj/item/projectile))
			return (check_cover(mover,target))
		if(istype(mover) && mover.checkpass(PASSTABLE))
			return 1
		if(locate(/obj/structure/barricade/snow) in get_turf(mover))
			return 1


	//checks if projectile 'P' from turf 'from' can hit whatever is behind the barricade. Returns 1 if it can, 0 if bullet stops.
	proc/check_cover(obj/item/projectile/P, turf/from)
		var/turf/cover = get_step(loc, get_dir(from, loc))
		if (get_dist(P.starting, loc) <= 1) //Barricades won't help you if people are THIS close
			return 1
		if (get_turf(P.original) == cover)
			var/chance = 40
			if (ismob(P.original))
				var/mob/M = P.original
				if (M.lying)
					chance += 20				//Lying down lets you catch less bullets
			if(prob(chance))
				health -= P.damage/4
				visible_message("<span class='warning'>[P] hits \the [src]!</span>")
				health_check()
				return 0
		return 1

	//Crusher
	Crossed(atom/movable/O)
		..()
		if(istype(O,/mob/living/carbon/Xenomorph/Crusher))
			var/mob/living/carbon/Xenomorph/M = O
			if(!M.stat) //No dead xenos jumpin on the bed~
				visible_message("<span class='danger'>[O] plows straight through the [src]!</span>")
				health_check(1)

	//Update Sides
	proc/update_nearby_icons()
		update_icon()
		for(var/direction in cardinal)
			for(var/obj/structure/barricade/snow/B in get_step(src,direction))
				B.update_icon()

	//Update Icons
	update_icon()
		spawn(2)
			if(!src)
				return
			var/junction = 0 //will be used to determine from which side the barricade is connected to other barricades
			for(var/obj/structure/barricade/snow/B in orange(src,1))
				if(abs(x-B.x)-abs(y-B.y) ) 		//doesn't count barricades, placed diagonally to src
					junction |= get_dir(src,B)

			icon_state = "snow_barricade_[junction]"
			return


/obj/machinery/computer/shuttle_control/elevator1
	name = "Elevator Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "elevator"
	shuttle_tag = "Elevator 1"
	unacidable = 1
	exproof = 1
	density = 0
	alerted = 0

/obj/machinery/computer/shuttle_control/elevator2
	name = "Elevator Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "elevator"
	shuttle_tag = "Elevator 2"
	unacidable = 1
	exproof = 1
	density = 0
	alerted = 0

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

//CLOTHING-----------------------//
//MASK-----------------------//
//Rebreather
/obj/item/clothing/mask/rebreather
	desc = "A close-fitting device that instantly heats or cools down air when you inhale so it doesn't damage your lungs."
	name = "rebreather"
	icon_state = "rebreather"
	item_state = "rebreather"
	flags = FPRINT | TABLEPASS | MASKCOVERSMOUTH
	body_parts_covered = 0
	w_class = 2

//Scarf
/obj/item/clothing/mask/rebreather/scarf
	desc = "A close-fitting cap that covers the top, back, and sides of the head. Can also be adjusted to cover the lower part of the face so it keeps the user warm in harsh conditions."
	name = "Heat Absorbent Coif"
	icon_state = "coif"
	item_state = "coif"

//SUITS-----------------------//
//Snow Armor
/obj/item/clothing/suit/storage/marine/snow
	name = "M3 Pattern Marine Snow Armor"
	desc = "A standard Colonial Marines M3 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage. It's extremely thick insulation can protect the wearer from extreme temperatures down to 220K (-53°C)."
	icon_state = "s_1"
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = 220
	armor = list(melee = 45, bullet = 65, laser = 65, energy = 20, bomb = 20, bio = 0, rad = 0)

//Snow Suit
/obj/item/clothing/suit/storage/snow_suit
	name = "Snow Suit"
	desc = "A standard snow suit. It can protect the wearer from extreme temperatures down to 220K (-53°C)."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "snowsuit_alpha"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 15, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	min_cold_protection_temperature = 220
	blood_overlay_type = "armor"
	siemens_coefficient = 0.7

//Doctor Snow Suit
/obj/item/clothing/suit/storage/snow_suit/doctor
	name = "Doctor's Snow Suit"
	icon_state = "snowsuit_doctor"
	armor = list(melee = 25, bullet = 35, laser = 35, energy = 20, bomb = 10, bio = 0, rad = 0)

//Engineer Snow Suit
/obj/item/clothing/suit/storage/snow_suit/engineer
	name = "Engineer's Snow Suit"
	icon_state = "snowsuit_engineer"
	armor = list(melee = 25, bullet = 35, laser = 35, energy = 20, bomb = 10, bio = 0, rad = 0)

//B18 Snow Armor
/obj/item/clothing/suit/storage/marine/marine_spec_armor/snow
	name = "B18 Defensive Snow Armor"
	icon_state = "s_xarmor"
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = 220
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

//B12 Leader Snow Armor
/obj/item/clothing/suit/storage/marine/marine_leader_armor/snow
	name = "B12 Pattern Leader Snow Armor"
	icon_state = "s_7"
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = 220
	heat_protection = UPPER_TORSO|LOWER_TORSO

//M56 Combat Snow Harness
/obj/item/clothing/suit/storage/marine_smartgun_armor/snow
	name = "M56 Combat Snow Harness"
	icon_state = "s_8"
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = 220
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE

//Sniper Armor
/obj/item/clothing/suit/storage/marine/sniper/snow
	name = "M3 Pattern Sniper Snow Armor"
	icon_state = "s_marine_sniper" //NEEDS ICON
	item_state = "s_marine_sniper"
	min_cold_protection_temperature = 220
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

//HELMETS-----------------------//
//Snow Helmet
/obj/item/clothing/head/helmet/marine/snow
	name = "M10 Pattern Marine Snow Helmet"
	min_cold_protection_temperature = 220
	icon_state = "helmet_snow"
	item_state = "helmet_snow"

//Snow Engineer Helmet
/obj/item/clothing/head/helmet/marine/tech/snow
	name = "M10 Technician Snow Helmet"
	icon_state = "s_helmet-tech"
	item_color = "s_helmet-tech"
	cold_protection = HEAD
	min_cold_protection_temperature = 220

//Snow Medic Helmet
/obj/item/clothing/head/helmet/marine/medic/snow
	name = "M10 Medic Snow Helmet"
	icon_state = "s_helmet-medic" //NEEDS ICON
	item_color = "s_helmet-medic"
	cold_protection = HEAD
	min_cold_protection_temperature = 220

//Snow SpecRag (?What?)
/obj/item/clothing/head/helmet/specrag/snow
	icon_state = "s_spec"
	item_state = "s_spec"
	item_color = "s_spec"
	min_cold_protection_temperature = 220
	cold_protection = HEAD

//B12 Snow Helmet
/obj/item/clothing/head/helmet/marine/heavy/snow
	name = "B18 Snow Helmet"
	icon_state = "s_xhelm"
	min_cold_protection_temperature = 220
	cold_protection = HEAD

//M11 Snow Helmet
/obj/item/clothing/head/helmet/marine/leader/snow
	name = "M11 Pattern Leader Snow Helmet"
	icon_state = "s_xhelm"
	min_cold_protection_temperature = 220
	cold_protection = HEAD

//UNIFORM-----------------------//
//Snow Uniform
/obj/item/clothing/under/marine_jumpsuit/snow
	name = "USCM Snow Uniform"
	icon_state = "marine_jumpsuit_snow"
	item_state = "marine_jumpsuit_snow"
	item_color = "marine_jumpsuit_snow"

//Snow Medic Uniform
/obj/item/clothing/under/marine/fluff/marineengineer/snow
	name = "Marine Engineer Snow Uniform"
	icon_state = "marine_engineer_snow"
	item_state = "marine_engineer_snow"
	item_color = "marine_engineer_snow"

//Snow Engineer Uniform
/obj/item/clothing/under/marine/fluff/marinemedic/snow
	name = "Marine Medic Snow Uniform"
	icon_state = "marine_medic_snow"
	item_state = "marine_medic_snow"
	item_color = "marine_medic_snow"
//SHOES

//Snow Shoes
/obj/item/clothing/shoes/snow
	name = "snow boots"
	desc = "When you feet are as cold as your heart"
	icon_state = "swat"
	siemens_coefficient = 0.6

	cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

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
	for(var/obj/machinery/door/poddoor/M in world)
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
	spawn_parts = list(/obj/item/part/computer/storage/hdd, /obj/item/part/computer/storage/removable)


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

/obj/item/weapon/disk/file/test
	spawn_files = list(/datum/file/program/door_control/aces_storage)

//-----ACES Research Reports
/datum/file/program/data/text/aces_log
	name = "ACES Research Report"
	extension = "txt"
	image = 'icons/ntos/file.png'
	dat = ""
	active_state = "text"
	var/list/logs = list(
	"Research Log I" = "<b>Research Log I</b><br><br>This log is very nice looking!",
	"Research Log II" = "<b>Research Log II</b><br><br>This log is very nice looking!",
	"Research Log III" = "<b>Research Log III</b><br><br>This log is very nice looking!",
	"Research Log IV" = "<b>Research Log IV</b><br><br>This log is very nice looking!",
	"Research Log V" = "<b>Research Log V</b><br><br>This log is very nice looking!"
	)


/*
	New()
		..()
		for(var/i in logs)
			world << "[i] = [logs[i]]"
			world << "<a href=\"byond://?show_help=[i]\">[i]</a>"
			world << "_____________________"

			//"[topic_link(src,"log_1","Log I")]<br>[topic_link(src,"log_2","Log II")]<br>[topic_link(src,"log_3","Log III")]<br>[topic_link(src,"log_4","Log IV")]<br>[topic_link(src,"log_5","Log V")]"
*/

/datum/file/program/data/text/aces_log/Topic(href, list/href_list)
	if(!interactable() || ..(href,href_list))
		return
	..()
	if ("log_1" in href_list)
		dat = "<b>Research Log I</b><br><br>This log is very nice looking!"
		dat += "<br><br>[topic_link(src,"return","Return")]"
	if ("log_2" in href_list)
		dat = "<b>Research Log II</b><br><br>This log is very nice looking!"
		dat += "<br><br>[topic_link(src,"return","Return")]"
	if ("log_3" in href_list)
		dat = "<b>Research Log III</b><br><br>This log is very nice looking!"
		dat += "<br><br>[topic_link(src,"return","Return")]"
	if ("log_4" in href_list)
		dat = "<b>Research Log IV</b><br><br>This log is very nice looking!"
		dat += "<br><br>[topic_link(src,"return","Return")]"
	if ("log_5" in href_list)
		dat = "<b>Research Log V</b><br><br>This log is very nice looking!"
		dat += "<br><br>[topic_link(src,"return","Return")]"
	if ("return" in href_list)
		dat = "[initial(dat)]"




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