/turf/open/floor
	//Note to coders, the 'intact_tile' var can no longer be used to determine if the floor is a plating or not.
	//Use the is_plating(), is_plasteel_floor() and is_light_floor() procs instead. --Errorage
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

	baseturfs = /turf/open/floor/plating

	var/icon_regular_floor = "floor" //Used to remember what icon the tile should have by default
	var/icon_plating = "plating"
	var/broken = 0
	var/burnt = 0
	var/mineral = "metal"
	var/obj/item/stack/tile/floor_tile = new/obj/item/stack/tile/plasteel
	var/breakable_tile = TRUE
	var/burnable_tile = TRUE
	var/hull_floor = FALSE //invincible floor, can't interact with it
	var/image/wet_overlay




////////////////////////////////////////////



//This is so damaged or burnt tiles or platings don't get remembered as the default tile
GLOBAL_LIST_INIT(icons_to_ignore_at_floor_init, list("damaged1", "damaged2", "damaged3", "damaged4",
											"damaged5", "panelscorched", "floorscorched1", "floorscorched2", "platingdmg1", "platingdmg2",
											"platingdmg3", "plating", "light_on", "light_on_flicker1", "light_on_flicker2",
											"light_on_clicker3", "light_on_clicker4", "light_on_clicker5", "light_broken",
											"light_on_broken", "light_off", "grass1", "grass2", "grass3", "grass4",
											"asteroid", "asteroid_dug",
											"asteroid0", "asteroid1", "asteroid2", "asteroid3", "asteroid4",
											"asteroid5", "asteroid6", "asteroid7", "asteroid8", "asteroid9",
											"asteroid10", "asteroid11", "asteroid12",
											"oldburning", "light-on-r", "light-on-y", "light-on-g", "light-on-b", "wood", "wood-broken",
											"carpet", "carpetcorner", "carpetside", "carpet", "ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5",
											"ironsand6", "ironsand7", "ironsand8", "ironsand9", "ironsand10", "ironsand11",
											"ironsand12", "ironsand13", "ironsand14", "ironsand15"))

GLOBAL_LIST_INIT(wood_icons, list("wood", "wood-broken"))


/turf/open/floor/Initialize(mapload, ...)
	. = ..()
	if(icon_state in GLOB.icons_to_ignore_at_floor_init)//So damaged/burned tiles or plating icons aren't saved as the default
		icon_regular_floor = "floor"
	else
		icon_regular_floor = icon_state

/turf/open/floor/ex_act(severity)
	if(hull_floor)
		return ..()
	switch(severity)
		if(EXPLODE_DEVASTATE)
			break_tile_to_plating()
		if(EXPLODE_HEAVY)
			if(prob(80))
				break_tile_to_plating()
			else
				break_tile()
		if(EXPLODE_LIGHT)
			if(prob(50))
				break_tile()
	return ..()


/turf/open/floor/fire_act(exposed_temperature, exposed_volume)
	if(hull_floor)
		return
	if(!burnt && prob(5))
		burn_tile()
	else if(prob(1) && !is_plating())
		make_plating()
		burn_tile()


/turf/open/floor/ceiling_debris_check(size = 1)
	ceiling_debris(size)


/turf/open/floor/update_icon()
	if(is_plasteel_floor())
		if(!broken && !burnt)
			icon_state = icon_regular_floor
	else if(is_plating())
		if(!broken && !burnt)
			icon_state = icon_plating //Because asteroids are 'platings' too.
	else if(is_light_floor())
		var/obj/item/stack/tile/light/T = floor_tile
		if(T.on)
			switch(T.state)
				if(0)
					icon_state = "light_on"
					set_light(5,5)
				if(1)
					var/num = pick("1", "2", "3", "4")
					icon_state = "light_on_flicker[num]"
					set_light(5,5)
				if(2)
					icon_state = "light_on_broken"
					set_light(5,5)
				if(3)
					icon_state = "light_off"
					set_light(0)
		else
			set_light(0)
			icon_state = "light_off"
	else if(is_grass_floor())
		if(!broken && !burnt)
			if(!(icon_state in list("grass1", "grass2", "grass3", "grass4")))
				icon_state = "grass[pick("1", "2", "3", "4")]"
		shoefootstep = FOOTSTEP_GRASS
		barefootstep = FOOTSTEP_GRASS
		mediumxenofootstep = FOOTSTEP_GRASS
	else if(is_carpet_floor())
		if(!broken && !burnt)
			if(icon_state != "carpetsymbol")
				var/connectdir = 0
				for(var/direction in GLOB.cardinals)
					if(isfloorturf(get_step(src, direction)))
						var/turf/open/floor/FF = get_step(src, direction)
						if(FF.is_carpet_floor())
							connectdir |= direction

				//Check the diagonal connections for corners, where you have, for example, connections both north and east
				//In this case it checks for a north-east connection to determine whether to add a corner marker or not.
				var/diagonalconnect = 0 //1 = NE; 2 = SE; 4 = NW; 8 = SW

				//Northeast
				if(connectdir & NORTH && connectdir & EAST)
					if(istype(get_step(src,NORTHEAST),/turf/open/floor))
						var/turf/open/floor/FF = get_step(src,NORTHEAST)
						if(FF.is_carpet_floor())
							diagonalconnect |= 1

				//Southeast
				if(connectdir & SOUTH && connectdir & EAST)
					if(istype(get_step(src,SOUTHEAST),/turf/open/floor))
						var/turf/open/floor/FF = get_step(src,SOUTHEAST)
						if(FF.is_carpet_floor())
							diagonalconnect |= 2

				//Northwest
				if(connectdir & NORTH && connectdir & WEST)
					if(istype(get_step(src,NORTHWEST),/turf/open/floor))
						var/turf/open/floor/FF = get_step(src,NORTHWEST)
						if(FF.is_carpet_floor())
							diagonalconnect |= 4

				//Southwest
				if(connectdir & SOUTH && connectdir & WEST)
					if(istype(get_step(src,SOUTHWEST),/turf/open/floor))
						var/turf/open/floor/FF = get_step(src,SOUTHWEST)
						if(FF.is_carpet_floor())
							diagonalconnect |= 8

				icon_state = "carpet[connectdir]-[diagonalconnect]"
		shoefootstep = FOOTSTEP_CARPET
		barefootstep = FOOTSTEP_CARPET
		mediumxenofootstep = FOOTSTEP_CARPET

	else if(is_wood_floor())
		if(!broken && !burnt)
			if(!(icon_state in GLOB.wood_icons))
				icon_state = "wood"
		shoefootstep = FOOTSTEP_WOOD
		barefootstep = FOOTSTEP_WOOD
		mediumxenofootstep = FOOTSTEP_WOOD

/turf/open/floor/return_siding_icon_state()
	..()
	if(is_grass_floor())
		var/dir_sum = 0
		for(var/direction in GLOB.cardinals)
			var/turf/T = get_step(src,direction)
			if(!(T.is_grass_floor()))
				dir_sum += direction
		if(dir_sum)
			return "wood_siding[dir_sum]"
		else
			return 0

/turf/open/floor/proc/gets_drilled()
	return

/turf/open/floor/proc/break_tile_to_plating()
	if(!is_plating())
		make_plating()
	break_tile()

/turf/open/floor/is_plasteel_floor()
	if(istype(floor_tile,/obj/item/stack/tile/plasteel))
		return 1
	else
		return 0

/turf/open/floor/is_light_floor()
	if(istype(floor_tile,/obj/item/stack/tile/light))
		return 1
	else
		return 0

/turf/open/floor/is_grass_floor()
	if(istype(floor_tile,/obj/item/stack/tile/grass))
		return 1
	else
		return 0

/turf/open/floor/is_wood_floor()
	if(istype(floor_tile,/obj/item/stack/tile/wood))
		return 1
	else
		return 0

/turf/open/floor/is_carpet_floor()
	if(istype(floor_tile,/obj/item/stack/tile/carpet))
		return 1
	else
		return 0

/turf/open/floor/is_plating()
	if(!floor_tile)
		return 1
	return 0

/turf/open/floor/proc/break_tile()
	if(!breakable_tile || hull_floor) return
	if(broken) return
	broken = TRUE
	if(is_plasteel_floor())
		icon_state = "damaged[pick(1, 2, 3, 4, 5)]"
		broken = 1
	else if(is_light_floor())
		icon_state = "light_broken"
		broken = 1
	else if(is_plating())
		icon_state = "platingdmg[pick(1, 2, 3)]"
		broken = 1
	else if(is_wood_floor())
		icon_state = "wood-broken[pick(1,2,3,4,5,6,7)]"
		broken = 1
	else if(is_carpet_floor())
		icon_state = "carpet-broken"
		broken = 1
	else if(is_grass_floor())
		icon = 'icons/turf/ground_map.dmi'
		icon_state = "sand"
		broken = 1

/turf/open/floor/proc/burn_tile()
	if(!burnable_tile|| hull_floor) return
	if(broken || burnt) return
	burnt = TRUE
	if(is_plasteel_floor())
		icon_state = "damaged[pick(1, 2, 3, 4, 5)]"
		burnt = 1
	else if(is_plasteel_floor())
		icon_state = "floorscorched[pick(1, 2)]"
		burnt = 1
	else if(is_plating())
		icon_state = "panelscorched"
		burnt = 1
	else if(is_wood_floor())
		icon_state = "wood-broken1"
		burnt = 1
	else if(is_carpet_floor())
		icon_state = "carpet-broken"
		burnt = 1
	else if(is_grass_floor())
		icon_state = "sand[pick("1", "2", "3")]"
		burnt = 1

//This proc will delete the floor_tile and the update_iocn() proc will then change the icon_state of the turf
//This proc auto corrects the grass tiles' siding.
/turf/open/floor/proc/make_plating()

	if(is_grass_floor())
		for(var/direction in GLOB.cardinals)
			if(istype(get_step(src,direction),/turf/open/floor))
				var/turf/open/floor/FF = get_step(src,direction)
				FF.update_icon() //So siding get updated properly
	else if(is_carpet_floor())
		spawn(5)
			if(src)
				for(var/direction in list(1, 2, 4, 8, 5, 6, 9, 10))
					if(isfloorturf(get_step(src,direction)))
						var/turf/open/floor/FF = get_step(src,direction)
						FF.update_icon() //So siding get updated properly

	if(!floor_tile) return
	qdel(floor_tile)
	floor_tile = null
	icon_plating = "plating"
	set_light(0)
	intact_tile = 0
	broken = 0
	burnt = 0

	update_icon()
	levelupdate()

//This proc will make the turf a plasteel floor tile. The expected argument is the tile to make the turf with
//If none is given it will make a new object. dropping or unequipping must be handled before or after calling
//this proc.
/turf/open/floor/proc/make_plasteel_floor(obj/item/stack/tile/plasteel/newtile)
	broken = 0
	burnt = 0
	intact_tile = 1
	set_light(0)

	if(!istype(newtile))
		newtile = new

	floor_tile = newtile
	if (icon_regular_floor)
		icon_state = icon_regular_floor
	else
		icon_state = "floor"
		icon_regular_floor = icon_state
	update_icon()
	levelupdate()


//This proc will make the turf a light floor tile. The expected argument is the tile to make the turf with
//If none is given it will make a new object. dropping or unequipping must be handled before or after calling
//this proc.
/turf/open/floor/proc/make_light_floor(obj/item/stack/tile/light/newtile)
	broken = 0
	burnt = 0
	intact_tile = 1
	if(!istype(newtile))
		newtile = new

	floor_tile = newtile
	update_icon()
	levelupdate()


//This proc will make a turf into a grass patch. Fun eh? Insert the grass tile to be used as the argument
//If no argument is given a new one will be made.
/turf/open/floor/proc/make_grass_floor(obj/item/stack/tile/grass/T = null)
	broken = 0
	burnt = 0
	intact_tile = 1
	if(T)
		if(istype(T,/obj/item/stack/tile/grass))
			floor_tile = T
			update_icon()
			levelupdate()
			return
	//If you gave a valid parameter, it won't get thisf ar.
	floor_tile = new/obj/item/stack/tile/grass

	update_icon()
	levelupdate()

//This proc will make a turf into a wood floor. Fun eh? Insert the wood tile to be used as the argument
//If no argument is given a new one will be made. SOMEONE FIX THIS COPYPASTE BULLSHIT!!
/turf/open/floor/proc/make_wood_floor(obj/item/stack/tile/wood/T = null)
	broken = 0
	burnt = 0
	intact_tile = 1
	if(T)
		if(istype(T,/obj/item/stack/tile/wood))
			floor_tile = T
			update_icon()
			levelupdate()
			return
	//If you gave a valid parameter, it won't get thisf ar.
	floor_tile = new/obj/item/stack/tile/wood

	update_icon()
	levelupdate()

//This proc will make a turf into a carpet floor. Fun eh? Insert the carpet tile to be used as the argument
//If no argument is given a new one will be made.
/turf/open/floor/proc/make_carpet_floor(obj/item/stack/tile/carpet/T = null)
	broken = 0
	burnt = 0
	intact_tile = 1
	if(T)
		if(istype(T,/obj/item/stack/tile/carpet))
			floor_tile = T
			update_icon()
			levelupdate()
			return
	//If you gave a valid parameter, it won't get thisf ar.
	floor_tile = new/obj/item/stack/tile/carpet

	update_icon()
	levelupdate()

/turf/open/floor/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(hull_floor) //no interaction for hulls
		return

	else if(istype(I, /obj/item/light_bulb/bulb)) //Only for light tiles
		if(is_light_floor())
			var/obj/item/stack/tile/light/T = floor_tile
			if(!T.state)
				to_chat(user, span_notice("The lightbulb seems fine, no need to replace it."))
				return

			user.drop_held_item(I)
			qdel(I)
			T.state = I //Fixing it by bashing it with a light bulb, fun eh?
			update_icon()
			to_chat(user, span_notice("You replace the light bulb."))

	else if(iscrowbar(I) && !is_plating() && floor_tile)
		if(broken || burnt)
			to_chat(user, span_warning("You remove the broken plating."))
		else if(is_wood_floor())
			to_chat(user, span_warning("You forcefully pry off the planks, destroying them in the process."))
		else
			to_chat(user, span_warning("You remove the [floor_tile]."))
			new floor_tile.type(src)

		make_plating()
		playsound(src, 'sound/items/crowbar.ogg', 25, 1)

	else if(isscrewdriver(I) && is_wood_floor())
		if(broken || burnt)
			return

		if(is_wood_floor())
			to_chat(user, span_warning("You unscrew the planks."))
			new floor_tile.type(src)

		make_plating()
		playsound(src, 'sound/items/screwdriver.ogg', 25, 1)


	else if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(!is_plating())
			to_chat(user, span_warning("You must remove the plating first."))
			return

		if(R.get_amount() < 2)
			to_chat(user, span_warning("You need more rods."))
			return

		to_chat(user, span_notice("Reinforcing the floor."))
		if(!do_after(user, 30, TRUE, src, BUSY_ICON_BUILD) || !is_plating())
			return

		if(!R?.use(2))
			return

		ChangeTurf(/turf/open/floor/engine)
		playsound(src, 'sound/items/deconstruct.ogg', 25, 1)

	if(istype(I, /obj/item/stack/tile))
		if(!is_plating())
			return

		if(broken || burnt)
			to_chat(user, span_notice("This section is too damaged to support a tile. Use a welder to fix the damage."))
			return

		var/obj/item/stack/tile/T = I
		if(T.get_amount() < 1)
			return

		floor_tile = new T.type
		intact_tile = 1
		if(istype(T, /obj/item/stack/tile/light))
			var/obj/item/stack/tile/light/L = T
			var/obj/item/stack/tile/light/F = floor_tile
			F.state = L.state
			F.on = L.on
		else if(istype(T, /obj/item/stack/tile/grass))
			for(var/direction in GLOB.cardinals)
				if(isfloorturf(get_step(src, direction)))
					var/turf/open/floor/FF = get_step(src,direction)
					FF.update_icon() //so siding gets updated properly
		else if(istype(T, /obj/item/stack/tile/carpet))
			for(var/direction in list(1, 2, 4, 8, 5, 6, 9, 10))
				if(isfloorturf(get_step(src, direction)))
					var/turf/open/floor/FF = get_step(src,direction)
					FF.update_icon() //so siding gets updated properly
		T.use(1)
		update_icon()
		levelupdate()
		playsound(src, 'sound/weapons/genhit.ogg', 25, 1)

	else if(istype(I, /obj/item/tool/shovel))
		if(!is_grass_floor())
			to_chat(user, span_warning("You cannot shovel this."))
			return

		new /obj/item/ore/glass(src)
		new /obj/item/ore/glass(src) //Make some sand if you shovel grass
		to_chat(user, span_notice("You shovel the grass."))
		make_plating()

	else if(iswelder(I))
		var/obj/item/tool/weldingtool/welder = I
		if(!welder.isOn() || !is_plating())
			return

		if(!broken && !burnt)
			return

		if(!welder.remove_fuel(0, user))
			to_chat(user, span_warning("You need more welding fuel to complete this task."))
			return

		flick("floorweld", src)
		to_chat(user, span_warning("You fix some dents on the broken plating."))
		playsound(src, 'sound/items/welder.ogg', 25, 1)
		icon_state = "plating"
		burnt = FALSE
		broken = FALSE

/turf/open/floor/wet_floor(wet_level = FLOOR_WET_WATER)
	if(wet >= wet_level) return
	wet = wet_level
	if(wet_overlay)
		overlays -= wet_overlay
		wet_overlay = null
	wet_overlay = image('icons/effects/water.dmi',src,"wet_floor")
	overlays += wet_overlay

	var/oldtype = type
	spawn(800)
		if(type != oldtype)
			return
		if(wet == wet_level)
			wet = 0
			if(wet_overlay)
				overlays -= wet_overlay
				wet_overlay = null





