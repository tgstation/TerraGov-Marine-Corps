


//FLOORS-----------------------------------//
//Snow Floor
/turf/open/floor/plating/ground/snow
	name = "snow layer"
	icon = 'icons/turf/snow2.dmi'
	icon_state = "snow_0"
	hull_floor = TRUE
	shoefootstep = FOOTSTEP_SNOW
	barefootstep = FOOTSTEP_SNOW
	mediumxenofootstep = FOOTSTEP_SNOW
	minimap_color = MINIMAP_SNOW

/turf/open/floor/plating/ground/snow/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ACIDSPRAY_ACT, PROC_REF(acidspray_act))
	update_icon(TRUE,TRUE) //Update icon and sides on start, but skip nearby check for turfs.

// Melting snow
/turf/open/floor/plating/ground/snow/fire_act(exposed_temperature, exposed_volume)
	slayer = 0
	update_icon(TRUE, FALSE)

//Xenos digging up snow
/turf/open/floor/plating/ground/snow/attack_alien(mob/living/carbon/xenomorph/M, damage_amount = M.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(M.status_flags & INCORPOREAL)
		return

	if(M.a_intent == INTENT_GRAB)
		if(!slayer)
			to_chat(M, span_warning("There is nothing to clear out!"))
			return FALSE

		M.visible_message(span_notice("\The [M] starts clearing out \the [src]."), \
		span_notice("We start clearing out \the [src]."), null, 5)
		playsound(M.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
		if(!do_after(M, 0.5 SECONDS, IGNORE_HELD_ITEM, src, BUSY_ICON_BUILD))
			return FALSE

		if(!slayer)
			to_chat(M, span_warning("There is nothing to clear out!"))
			return

		M.visible_message(span_notice("\The [M] clears out \the [src]."), \
		span_notice("We clear out \the [src]."), null, 5)
		slayer = 0
		update_icon(TRUE, FALSE)

//PLACING/REMOVING/BUILDING
/turf/open/floor/plating/ground/snow/attackby(obj/item/I, mob/user, params)
	. = ..()
	//Light Stick
	if(istype(I, /obj/item/lightstick))
		var/obj/item/lightstick/L = I
		if(locate(/obj/item/lightstick) in get_turf(src))
			to_chat(user, "There's already a [L.name] at this position!")
			return

		to_chat(user, "Now planting \the [L].")
		if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_BUILD))
			return

		user.visible_message(span_notice("[user.name] planted \the [L] into [src]."))
		L.anchored = TRUE
		L.icon_state = "lightstick_[L.s_color][L.anchored]"
		user.drop_held_item()
		L.x = x
		L.y = y
		L.pixel_x += rand(-5,5)
		L.pixel_y += rand(-5,5)
		L.set_light(2,1)
		playsound(user, 'sound/weapons/genhit.ogg', 25, 1)


/turf/open/floor/plating/ground/snow/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(slayer > 0 && isxeno(arrived))
		var/mob/living/carbon/xenomorph/xeno = arrived
		if(xeno.is_charging >= CHARGE_ON) // chargers = snow plows
			slayer = 0
			update_icon(TRUE, FALSE)
	return ..()


//Update icon
/turf/open/floor/plating/ground/snow/update_icon(update_full, skip_sides)
	icon_state = "snow_[slayer]"
	setDir(pick(GLOB.alldirs))
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
					D.update_icon(TRUE, TRUE)

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
		if(EXPLODE_HEAVY)
			if(slayer && prob(60))
				slayer = max(slayer - 2, 0)
		if(EXPLODE_LIGHT)
			if(slayer && prob(20))
				slayer = max(slayer - 1, 0)

	update_icon(TRUE, FALSE)
	return ..()

//Fire act; fire now melts snow as it should; fire beats ice
/turf/open/floor/plating/ground/snow/flamer_fire_act(burnlevel)
	if(!slayer || !burnlevel) //Don't bother if there's no snow to melt or if there's no burn stacks
		return

	switch(burnlevel)
		if(1 to 10)
			slayer = max(0, slayer - 1)
		if(11 to 24)
			slayer = max(0, slayer - 2)
		if(25 to INFINITY)
			slayer = 0

	update_icon(TRUE, FALSE)

/turf/open/floor/plating/ground/snow/proc/acidspray_act()
	SIGNAL_HANDLER

	if(!slayer) //Don't bother if there's no snow to melt or if there's no burn stacks
		return

	slayer = max(0, slayer - 1) //Melt a layer
	update_icon(TRUE, FALSE)


//SNOW LAYERS-----------------------------------//
/turf/open/floor/plating/ground/snow/layer0
	icon_state = "snow_0"
	slayer = 0
	minimap_color = MINIMAP_DIRT

/turf/open/floor/plating/ground/snow/layer1
	icon_state = "snow_1"
	slayer = 1

/turf/open/floor/plating/ground/snow/layer2
	icon_state = "snow_2"
	slayer = 2

/turf/open/floor/plating/ground/snow/layer3
	icon_state = "snow_3"
	slayer = 3


