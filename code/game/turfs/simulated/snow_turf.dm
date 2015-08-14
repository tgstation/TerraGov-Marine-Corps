/turf/simulated/floor/gm/snow
	name = "snow layer"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow0_0"
	slayer = 0 //Snow layer //Defined in /turf
	var/obj/item/lightstick/stick //light sticks

//Placing/Building/Removing
	attackby(var/obj/item/I, var/mob/user)
	/*	//Light Sticks
		if(istype(I, /obj/item/lightstick))
			if(stick)	return
			user.drop_item()
			stick = I
			I.loc = src
			user.visible_message("[user.name] sticks the [stick] into the [src].","You stick the [stick] into the [src].")
			playsound(user, 'shotgun_shell_insert.ogg', 40, 1)
			I.icon_state = "lightstick1"
			I.anchored = 1
*/

		//Snow Shovel
		if(istype(I, /obj/item/snow_shovel))
			var/obj/item/snow_shovel/S = I
			//Mode 0 + 1 -Removing snow + gaining snow
			if((S.mode == 0 || S.mode == 1) && !S.has_snow)
				if(S.working)
					user  << "\red You are already shoveling!"
					return
				if(!slayer)
					user  << "\red You can't shovel beyond this layer, the shovel will break!"
					return
				user.visible_message("[user.name] starts clearing out the snow layer.","You start removing some of the snow layer.")
				S.working = 1
				if(!do_after(user,50))
					user.visible_message("\red \The [user] decides not to clear out \the [src] anymore.")
					S.working = 0
					return
				user.visible_message("\blue \The [user] clears out \the [src].")
				slayer -= 1
				if(S.mode == 1)//Pick it up if we have it selected
					S.has_snow = 1
					S.update_icon()
				update_icon(1)
				S.working = 0

			//Mode 1 -Dispatching snow to the ground
			if(S.mode == 1 && S.has_snow)
				if(S.working)//If adding snow
					user  << "\red You are already shoveling!"
					return
				if(slayer == 3)
					user  << "\red You can't add any more snow here!"
					return
				if(S.has_snow)
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

			//Mode 2 -Making barricades
			if(S.mode == 2)
				if(S.working)//If adding snow
					user  << "\red You are already shoveling!"
					return
				if(!slayer)
					user  << "\red You can't build the barricade here, there must be more snow on that area!"
					return
				user.visible_message("[user.name] starts shaping the barricade.","You start shaping the barricade")
				S.working = 1
				if(!do_after(user,150))
					user.visible_message("\red \The [user] decides not to dump \the [S] anymore.")
					S.working = 0
					return

				var/obj/structure/snow/barricade/B = new/obj/structure/snow/barricade(src)
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



//LAYERS
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


//Ice walls
/turf/simulated/wall/gm/ice
	name = "thick ice"
	icon = 'icons/turf/snow.dmi'
	icon_state = "ice_wall"
	desc = "It is very thick."

/turf/simulated/wall/gm/ice/New()
	spawn(1)
		icon_state = "ice_wall"

//Items
/obj/item/weapon/storage/box/lightstick
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id"

	New()
		..()
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)
		new /obj/item/lightstick(src)

/obj/item/lightstick
	name = "blue lightstick"
	desc = "You can stick them in the ground"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lightstick0"

/*
	icon_state = "lightstick1"

	luminosity = 2
	l_color = "#47A3FF"
*/
/obj/item/snow_shovel
	name = "snow shovel"
	desc = "Not again..."
	icon = 'icons/obj/items.dmi'
	icon_state = "snow_shovel"
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
		if(mode == 0)
			mode = 1
			user  << "\blue You will take some of the snow layer/ dump snow to the ground!"

		else if(mode == 1)
			mode = 2
			user  << "\blue You will now make/remove snow barricades!"

		else if(mode == 2)
			mode = 0
			user  << "\blue You will now remove snow layers!"

	update_icon()
		if(has_snow)
			overlays.Cut()
			overlays += image('icons/turf/snow.dmi', "snow_shovel_overlay")
		else
			overlays.Cut()

//Snow barricade
/obj/structure/snow/barricade
	name = "snow barricade"
	desc = "It could be worse..."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow_barricade"
	var/health = 0
	climbable = 1
	density = 1


//Removing the barricades
	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, /obj/item/snow_shovel))
			var/obj/item/snow_shovel/S = I
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

//Hitting barricades
	proc/hit(var/damage)
		health = max(0, health - damage)
		if(health <= 0)
			del(src)

//Areas
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

/area/ice_colony/research_entrance/foyer
	name = "\improper IR Foyer"
	icon_state = "research"

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

/area/space/firealert()
	return

/area/space/readyalert()
	return

/area/space/partyalert()
	return



/obj/machinery/computer3/ice_colony
	spawn_files = list(/datum/file/data/text/researchlog)

