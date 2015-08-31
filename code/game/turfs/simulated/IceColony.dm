//ELEVATOR SHAFT-----------------------------------//
/turf/simulated/floor/gm/empty
	name = "empty space"
	icon = 'icons/turf/floors.dmi'
	icon_state = "black"
	density = 1

//SNOW-----------------------------------//
/turf/simulated/floor/gm/snow
	name = "snow layer"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow0_0"
	slayer = 0 //Snow layer, Defined in /turf

	//PLACING/REMOVING/BUILDING-----------------------------------//
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
			L.icon_state = "lightstick[L.anchored]"
			L.SetLuminosity(2)
			user.drop_item()
			L.x = x
			L.y = y
			L.pixel_x += rand(-5,5)
			L.pixel_y += rand(-5,5)
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
				if(!do_after(user,50))
					user.visible_message("\red \The [user] decides not to clear out \the [src] anymore.")
					S.working = 0
					return

				user.visible_message("\blue \The [user] clears out \the [src].")
				slayer -= 1
				update_icon(1)
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
					if(!do_after(user,50))
						user.visible_message("\red \The [user] decides not to dump \the [S] anymore.")
						S.working = 0
						return

					user.visible_message("\blue \The [user] clears out \the [src].")
					slayer += 1
					S.has_snow = 0 //Remove snow from the shovel
					S.update_icon()
					update_icon(1)
					S.working = 0

				//Placing
				else
					if(slayer <= 0)
						user  << "\red There is no more snow to pick up!"
						return

					user.visible_message("[user.name] starts clearing out the [src].","You start removing some of the [src].")
					S.working = 1
					if(!do_after(user,50))
						user.visible_message("\red \The [user] decides not to clear out \the [src] anymore.")
						S.working = 0
						return

					user.visible_message("\blue \The [user] clears out \the [src].")
					slayer -= 1
					S.has_snow = 1
					S.update_icon()
					update_icon(1)
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
				if(!do_after(user,150))
					user.visible_message("\red \The [user] decides not to dump \the [S] anymore.")
					S.working = 0
					return

				var/obj/structure/barricade/snow/B = new/obj/structure/barricade/snow(src)
				user.visible_message("\blue \The [user] creates \the [B].")
				B.health = slayer * 25
				slayer = 0
				update_icon(1)
				S.working = 0


//Update icon on start
	New()
		..()
		update_icon(1)

//Update icon
//This code is so bad, it makes me wanna cry ;_;
//Needs to re recoded in total
	update_icon(var/update_sides)
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

		if(update_sides)
			var/turf/simulated/floor/gm/snow/T
			//turf/simulated/floor/gm/snow
			for(var/dirn in cardinal)
				var/turf/simulated/floor/gm/snow/D = get_step(src,dirn)
				if(istype(D))
					D.overlays.Cut()
			if(istype(get_step(src, NORTH), /turf/simulated/floor/gm/snow))
				T = get_step(src, NORTH)
				if (T && slayer > T.slayer)
					T.overlays += image('icons/turf/snow.dmi', "snow_overlay_[slayer]_[pick("0", "1", "2")]_n")
			if(istype(get_step(src, SOUTH), /turf/simulated/floor/gm/snow))
				T = get_step(src, SOUTH)
				if (T && slayer > T.slayer)
					T.overlays += image('icons/turf/snow.dmi', "snow_overlay_[slayer]_[pick("0", "1", "2")]_s")
			if(istype(get_step(src, EAST), /turf/simulated/floor/gm/snow))
				T = get_step(src, EAST)
				if (T && slayer > T.slayer)
					T.overlays += image('icons/turf/snow.dmi', "snow_overlay_[slayer]_[pick("0", "1", "2")]_e")
			if(istype(get_step(src, WEST), /turf/simulated/floor/gm/snow))
				T = get_step(src, WEST)
				if (T && slayer > T.slayer)
					T.overlays += image('icons/turf/snow.dmi', "snow_overlay_[slayer]_[pick("0", "1", "2")]_w")
			if(istype(get_step(src, NORTHWEST), /turf/simulated/floor/gm/snow))
				T = get_step(src, NORTHWEST)
				if (T && slayer > T.slayer)
					T.overlays += image('icons/turf/snow.dmi', "snow_overlay_[slayer]_0_nw")
			if(istype(get_step(src, NORTHEAST), /turf/simulated/floor/gm/snow))
				T = get_step(src, NORTHEAST)
				if (T && slayer > T.slayer)
					T.overlays += image('icons/turf/snow.dmi', "snow_overlay_[slayer]_0_ne")
			if(istype(get_step(src, SOUTHWEST), /turf/simulated/floor/gm/snow))
				T = get_step(src, SOUTHWEST)
				if (T && slayer > T.slayer)
					T.overlays += image('icons/turf/snow.dmi', "snow_overlay_[slayer]_0_sw")
			if(istype(get_step(src, SOUTHEAST), /turf/simulated/floor/gm/snow))
				T = get_step(src, SOUTHEAST)
				if (T && slayer > T.slayer)
					T.overlays += image('icons/turf/snow.dmi', "snow_overlay_[slayer]_0_se")



//SNOW LAYERS-----------------------------------//
/turf/simulated/floor/gm/snow/layer0
	icon_state = "snow0_0"
	slayer = 0

/turf/simulated/floor/gm/snow/layer1
	icon_state = "snow1_0"
	slayer = 1

/turf/simulated/floor/gm/snow/layer2
	icon_state = "snow2_0"
	slayer = 2

/turf/simulated/floor/gm/snow/layer3
	icon_state = "snow3_0"
	slayer = 3


//ICE WALLS-----------------------------------//
/turf/simulated/wall/gm/ice
	name = "thick ice"
	icon = 'icons/turf/snow.dmi'
	icon_state = "ice_wall"
	desc = "It is very thick."

	//Must override icon
	New()
		spawn(1)
			icon_state = "ice_wall"


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

//Lightsticks----------
/obj/item/lightstick
	name = "blue lightstick"
	desc = "You can stick them in the ground"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lightstick0"
	l_color = "#47A3FF"

	//Removing from turf
	attack_hand(mob/user)
		..()
		if(!anchored)//If planted
			return

		user << "You start pulling out \the [src]."
		if(!do_after(user,20))
			return

		anchored = 0
		user.visible_message("[user.name] removes \the [src] from the ground.","You stick the [src] into the ground.")
		icon_state = "lightstick[anchored]"
		SetLuminosity(0)
		pixel_x = 0
		pixel_y = 0
		playsound(user, 'sound/weapons/Genhit.ogg', 25, 1)

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
		if(has_snow)
			overlays.Cut()
			overlays += image('icons/turf/snow.dmi', "snow_shovel_overlay")
		else
			overlays.Cut()

	//Examine
	examine()
		..()
		if(mode == 0)
			usr << "\blue Selected mode: Removing snow."
		else
			usr << "\blue Selected mode: [mode ? "Collecting/Throwing snow" : "Building/Removing barricades"]."

//Snow barricade----------
/obj/structure/barricade/snow
	name = "snow barricade"
	desc = "It could be worse..."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow_barricade"
	var/health = 50 //Actual health depends on snow layer
	climbable = 1
	density = 1
	anchored = 1

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
				del(src)
				return

		//Attacking
		else
			switch(W.damtype)
				if("fire")
					src.health -= W.force
				if("brute")
					src.health -= W.force
				else
			if (src.health <= 0)
				visible_message("\red <B>The [src] falls apart!</B>")
				del(src)
			..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				visible_message("\red <B>The [src] is blown apart!</B>")
				del(src)
				return
			if(2.0)
				src.health -= rand(30,60)
				if (src.health <= 0)
					visible_message("\red <B>The [src] is blown apart!</B>")
					del(src)
				return
			if(3.0)
				src.health -= rand(10,30)
				if (src.health <= 0)
					visible_message("\red <B>The [src] is blown apart!</B>")
					del(src)
				return

	meteorhit()
		visible_message("\red <B>The [src] is blown apart!</B>")
		del(src)
		return

	blob_act()
		src.health -= 25
		if (src.health <= 0)
			visible_message("\red <B>The blob eats through the [src]!</B>")
			del(src)
		return

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)//So bullets will fly over and stuff.
		if(air_group || (height==0))
			return 1
		if(istype(mover) && mover.checkpass(PASSTABLE))
			return 1
		else
			return 0

	Crossed(atom/movable/O)
		..()
		if(istype(O,/mob/living/carbon/Xenomorph/Crusher))
			var/mob/living/carbon/Xenomorph/M = O
			if(!M.stat) //No dead xenos jumpin on the bed~
				visible_message("<span class='danger'>[O] plows straight through the [src]!</span>")
				del(src)


//AREAS-----------------------------------//
/area/ice_colony
	name = "\improper ice colony"

/area/ice_colony/storage
	name = "\improper Storage Unit"
	icon_state = "storage"

/area/ice_colony/doorms
	name = "\improper Doorms"
	icon_state = "yellow"

/area/ice_colony/outpost_foyer
	name = "\improper Outpost Foyer"
	icon_state = "hallC1"

/area/ice_colony/outpost_central
	name = "\improper Outpost Central"
	icon_state = "hallC2"

/area/ice_colony/outpost_hall
	name = "\improper Outpost Hallway"
	icon_state = "hallC3"

/area/ice_colony/medbay
	name = "\improper Medbay"
	icon_state = "medbay"

/area/ice_colony/medbay_foyer
	name = "\improper Medbay Foyer"
	icon_state = "medbay3"

/area/ice_colony/maintenance
	name = "\improper Maintenance Shaft"
	icon_state = "maintcentral"

/area/ice_colony/recreation
	name = "\improper Recreation Room"
	icon_state = "crew_quarters"

/area/ice_colony/hydroponics
	name = "\improper Hydroponics"
	icon_state = "hydro"

/area/ice_colony/garage_a
	name = "\improper Garage"
	icon_state = "east"

/area/ice_colony/garage_b
	name = "\improper Garage"
	icon_state = "west"

/area/ice_colony/hangar_a
	name = "\improper Hangar"
	icon_state = "east"

/area/ice_colony/hangar_b
	name = "\improper Hangar"
	icon_state = "west"

/area/ice_colony/relay
	name = "\improper Relay"
	icon_state = "tcomsatcham"

/area/ice_colony/disposal
	name = "\improper Disposal"
	icon_state = "disposal"

/area/ice_colony/power_plant
	name = "\improper Power Plant"
	icon_state = "engine"

/area/ice_colony/power_storage
	name = "\improper Power Storage"
	icon_state = "substation"

/area/ice_colony/water_pump
	name = "\improper Water Pump"
	icon_state = "substation"

/area/ice_colony/construction
	name = "\improper Construction Area"
	icon_state = "purple"

/area/ice_colony/research_entrance
	name = "\improper Interdyne Research Entrance"
	icon_state = "research"

//Research-------
/area/ice_colony/research
	name = "\improper Research"
	icon_state = "research"

/area/ice_colony/research/entrance
	name = "\improper WY Research Entrance"
	icon_state = "green"

/area/ice_colony/research/alien_research
	name = "\improper Xenobiology Lab"
	icon_state = "green"

/area/ice_colony/research/anomaly_research
	name = "\improper Anomaly Research Lab"
	icon_state = "purple"

/area/ice_colony/research/rd_private
	name = "\improper Research Director's Private Office"
	icon_state = "captain"

/area/ice_colony/research/armory
	name = "\improper Armory"
	icon_state = "armory"

/area/ice_colony/research/anomaly_research_foyer
	name = "\improper Research Lab Foyer"
	icon_state = "research"

/area/ice_colony/research/conference
	name = "\improper Conference Room"
	icon_state = "conference"

/area/ice_colony/research/rd_office
	name = "\improper Research Director's Office"
	icon_state = "head_quarters"

/area/ice_colony/research/security
	name = "\improper Security"
	icon_state = "security"

/area/ice_colony/research/maint_storage
	name = "\improper Maintenance Storage"
	icon_state = "storage"

/area/ice_colony/research/locker_room_maint
	name = "\improper Locker Room Maintenance"
	icon_state = "maint_locker"

/area/ice_colony/research/canteen
	name = "\improper Canteen"
	icon_state = "cafeteria"

/area/ice_colony/research/foyer
	name = "\improper Research Entrance Foyer"
	icon_state = "research"

/area/ice_colony/research/tool_storage_one
	name = "\improper Tool Storage I"
	icon_state = "primarystorage"

/area/ice_colony/research/locker_room
	name = "\improper Locker Room"
	icon_state = "locker"

/area/ice_colony/research/anomaly_storage_three
	name = "\improper Anomaly Storage III"
	icon_state = "north"

/area/ice_colony/research/anomaly_storage_hallway
	name = "\improper Research"
	icon_state = "anomaly"

/area/ice_colony/research/main_hall
	name = "\improper Research"
	icon_state = "hallC1"

/area/ice_colony/research/anomaly_storage_one
	name = "\improper Anomaly Storage I"
	icon_state = "west"

/area/ice_colony/research/anomaly_storage_four
	name = "\improper Anomaly Storage IV"
	icon_state = "east"

/area/ice_colony/research/tool_storage_two
	name = "\improper Tool Storage II"
	icon_state = "auxstorage"

/area/ice_colony/research/library
	name = "\improper Library"
	icon_state = "library"

/area/ice_colony/research/medbay
	name = "\improper Medbay"
	icon_state = "medbay"

/area/ice_colony/research/atmos
	name = "\improper Atmospherics"
	icon_state = "atmos"

/area/ice_colony/research/generator
	name = "\improper Generator"
	icon_state = "substation"

/area/ice_colony/research/medbay_main
	name = "\improper Medbay Maintenance"
	icon_state = "maint_medbay"

/area/ice_colony/research/foyer_maint
	name = "\improper Doorms Maintenance"
	icon_state = "maint_dormitory"

/area/ice_colony/research/doorms
	name = "\improper Doorms"
	icon_state = "crew_quarters"

/area/ice_colony/research/cooling
	name = "\improper Anomaly Storage Cooling Unit"
	icon_state = "yellow"

/area/ice_colony/research/anomaly_storage_two
	name = "\improper Anomaly Storage II"
	icon_state = "south"

/area/ice_colony/research/anomaly_storage_five
	name = "\improper Anomaly Storage V"
	icon_state = "southeast"

/area/ice_colony/research/disposal
	name = "\improper Disposal"
	icon_state = "disposal"

//Elevator-------
/area/shuttle/elevator1/ground
	name = "\improper Elevator I"
	icon_state = "shuttlered"

/area/shuttle/elevator1/underground
	name = "\improper Elevator I"
	icon_state = "shuttle"

/area/shuttle/elevator1/transit
	name = "\improper Elevator I"
	icon_state = "shuttle2"

/area/shuttle/elevator2/ground
	name = "\improper Elevator II"
	icon_state = "shuttle"

/area/shuttle/elevator2/underground
	name = "\improper Elevator II"
	icon_state = "shuttle2"

/area/shuttle/elevator2/transit
	name = "\improper Elevator II"
	icon_state = "shuttlered"

//Outside--------
/area/ice_colony/outside
	name = "\improper ice colony"
	icon_state = "green"
	requires_power = 1
	always_unpowered = 1
	lighting_use_dynamic = 1
	power_light = 0
	power_equip = 0
	power_environ = 0
	ambience = list('sound/ambience/ambispace.ogg','sound/music/title2.ogg','sound/music/space.ogg','sound/music/main.ogg','sound/music/traitor.ogg')

	//Nope
	firealert()
		return
	readyalert()
		return
	partyalert()
		return


/obj/machinery/computer3/ice_colony
	New()
		..()
		spawn_files += (/datum/file/data/text/researchlog)
		update_spawn_files()

/obj/machinery/computer/shuttle_control/elevator1
	name = "Elevator Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "elevator"
	shuttle_tag = "Elevator 1"
	unacidable = 1
	exproof = 1
	density = 0

/obj/machinery/computer/shuttle_control/elevator2
	name = "Elevator Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "elevator"
	shuttle_tag = "Elevator 2"
	unacidable = 1
	exproof = 1
	density = 0


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