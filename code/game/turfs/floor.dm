/turf/open/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	baseturfs = /turf/open/floor/plating
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_OPEN_FLOOR, SMOOTH_GROUP_TURF_OPEN)
	///Number of icon state variation this turf has
	var/icon_variants = 1
	///If the turf has been physically damaged
	var/broken = FALSE
	///If the turf has been damaged by fire
	var/burnt = FALSE
	///the type of tile that makes this turf
	var/obj/item/stack/tile/floor_tile = /obj/item/stack/tile/plasteel
	///Can this turf be broken
	var/breakable_tile = TRUE
	///can this turf be burnt
	var/burnable_tile = TRUE
	///invincible floor, can't interact with it
	var/hull_floor = FALSE
	///holder for the wet floor overlay
	var/image/wet_overlay
	///turf dry timer
	var/drytimer_id

/turf/open/floor/Initialize(mapload)
	. = ..()
	update_icon()

/turf/open/floor/ex_act(severity)
	if(hull_floor)
		return ..()
	switch(severity)
		if(EXPLODE_DEVASTATE)
			make_plating()
		if(EXPLODE_HEAVY)
			if(prob(80))
				make_plating()
			else
				break_tile()
		if(EXPLODE_LIGHT)
			if(prob(50))
				break_tile()
	return ..()

/turf/open/floor/fire_act(burn_level)
	if(hull_floor)
		return
	if(!burnt && prob(5))
		burn_tile()
	else if(prob(1))
		make_plating()
		burn_tile()

/turf/open/floor/ceiling_debris_check(size = 1)
	ceiling_debris(size)

/turf/open/floor/ChangeTurf(path, list/new_baseturfs, flags)
	if(!isfloorturf(src))
		return ..() //fucking turfs switch the fucking src of the fucking running procs
	if(!ispath(path, /turf/open/floor))
		return ..()
	var/old_dir = dir
	var/turf/open/floor/W = ..()
	W.setDir(old_dir)
	W.update_icon() //maybe not needed
	return W

/turf/open/floor/update_icon_state()
	. = ..()
	if(broken)
		icon_state = broken_states()
	else if(burnt)
		icon_state = burnt_states()
	else
		icon_state = normal_states()

///Returns an undamaged icon state for this turf
/turf/open/floor/proc/normal_states()
	if(icon_variants < 2)
		return initial(icon_state)
	return "[initial(icon_state)]_[rand(1, icon_variants)]"

///Returns a list of icon_states to show this turf is broken
/turf/open/floor/proc/broken_states()
	return pick("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

///Returns a list of icon_states to show this turf is burnt
/turf/open/floor/proc/burnt_states()
	return pick("floorscorched1", "floorscorched2")

///Breaks the turf
/turf/open/floor/proc/break_tile()
	if(!breakable_tile || hull_floor)
		return
	if(broken)
		return
	broken = TRUE
	update_icon()

///Burns the turf
/turf/open/floor/burn_tile()
	if(!burnable_tile || hull_floor)
		return
	if(burnt)
		return
	burnt = TRUE
	update_icon()

/// Things seem to rely on this actually returning plating. Override it if you have other baseturfs.
/turf/open/floor/proc/make_plating()
	return ScrapeAway()

/turf/open/floor/attackby(obj/item/object, mob/living/user, params)
	if(!object || !user)
		return TRUE
	. = ..()
	if(.)
		return
	if(floor_tile && istype(object, /obj/item/stack/tile))
		try_replace_tile(object, user, params)
		return TRUE
	return FALSE

///swaps out an existing floor tile with another one
/turf/open/floor/proc/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	if(T.turf_type == type)
		return
	var/obj/item/tool/crowbar/user_crowbar = user.is_holding_item_of_type(/obj/item/tool/crowbar)
	if(!user_crowbar)
		return
	var/turf/open/floor/plating/P = pry_tile(user_crowbar, user, TRUE)
	if(!istype(P))
		return
	P.attackby(T, user, params)

/turf/open/floor/crowbar_act(mob/living/user, obj/item/I)
	if(floor_tile && !hull_floor && pry_tile(I, user))
		return TRUE

///Removes the floor tile from the turf via a tool
/turf/open/floor/proc/pry_tile(obj/item/I, mob/user, silent = FALSE)
	I.play_tool_sound(src, 80)
	return remove_tile(user, silent)

///Removes the floor tile from the turf
/turf/open/floor/proc/remove_tile(mob/user, silent = FALSE, make_tile = TRUE)
	if(broken || burnt)
		broken = FALSE
		burnt = FALSE
		if(user && !silent)
			to_chat(user, span_notice("You remove the broken plating."))
	else
		if(user && !silent)
			to_chat(user, span_notice("You remove the floor tile."))
		if(make_tile)
			spawn_tile()
	return make_plating()

///checks if this turf has a floor tile of some kind
/turf/open/floor/proc/has_tile()
	return floor_tile

///creates a loose floor tile
/turf/open/floor/proc/spawn_tile()
	if(!has_tile())
		return null
	return new floor_tile(src)

//todo: maybe redo this wet/dry stuff
/turf/open/floor/wet_floor(wet_level = FLOOR_WET_WATER)
	if(wet >= wet_level)
		return
	wet = wet_level
	switch(wet)
		if(FLOOR_WET_WATER)
			AddComponent(/datum/component/slippery, 0.5 SECONDS, 0.3 SECONDS, null, TRUE)

		if(FLOOR_WET_LUBE) //lube
			AddComponent(/datum/component/slippery, 1 SECONDS, 1 SECONDS, null, FALSE, TRUE, 4)

		if(FLOOR_WET_ICE) // Ice
			AddComponent(/datum/component/slippery, 0.4 SECONDS, 0.3 SECONDS, null, FALSE, TRUE, 1)

	if(wet_overlay)
		overlays -= wet_overlay
		wet_overlay = null
	wet_overlay = image('icons/effects/water.dmi', src, "wet_floor_static")
	overlays += wet_overlay

	drytimer_id = addtimer(CALLBACK(src, PROC_REF(dry), wet_level, type), 80 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/turf/open/floor/proc/dry(old_wet_level, oldtype)
	if(type != oldtype)
		return
	if(wet == old_wet_level)
		wet = 0
		qdel(GetComponent(/datum/component/slippery))
		if(wet_overlay)
			overlays -= wet_overlay
			wet_overlay = null
