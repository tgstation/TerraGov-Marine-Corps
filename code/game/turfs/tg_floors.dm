/// Anything above a lattice should go here.
/turf/open/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	base_icon_state = "floor"
	baseturfs = /turf/open/floor/plating

	//footstep = FOOTSTEP_FLOOR
	//barefootstep = FOOTSTEP_HARD_BAREFOOT
	//clawfootstep = FOOTSTEP_HARD_CLAW
	//heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	turf_flags = CAN_BE_DIRTY_1 | IS_SOLID

	tiled_dirt = TRUE


	overfloor_placed = TRUE
	damaged_dmi = 'icons/turf/damaged.dmi'
	/// Path of the tile that this floor drops
	var/floor_tile = null

/turf/open/floor/Initialize(mapload)
	. = ..()
	//if(mapload && prob(33))
	//	MakeDirty()


/turf/open/floor/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/burnt_states()
	return list()

/turf/open/floor/ex_act(severity, target)
	. = ..()

	if(target == src)
		ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	if(severity < EXPLODE_DEVASTATE && is_shielded())
		return FALSE

	if(target)
		severity = EXPLODE_LIGHT

	switch(severity)
		if(EXPLODE_DEVASTATE)
			ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
		if(EXPLODE_HEAVY)
			switch(rand(1, 3))
				if(1)
					if (!ispath(baseturf_at_depth(2), /turf/open/floor))
						attempt_lattice_replacement()
					else
						ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
					if(prob(33))
						new /obj/item/stack/sheet/iron(src)
				if(2)
					ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
				if(3)
					if(prob(80))
						ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
					else
						break_tile()
					hotspot_expose(1000,CELL_VOLUME)
					if(prob(33))
						new /obj/item/stack/sheet/iron(src)
		if(EXPLODE_LIGHT)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)

	return FALSE

/turf/open/floor/proc/break_tile_to_plating()
	var/turf/open/floor/plating/T = make_plating()
	if(!istype(T))
		return
	T.break_tile()

/// Things seem to rely on this actually returning plating. Override it if you have other baseturfs.
/turf/open/floor/proc/make_plating(force = FALSE)
	return ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

///For when the floor is placed under heavy load. Calls break_tile(), but exists to be overridden by floor types that should resist crushing force.
/turf/open/floor/proc/crush()
	break_tile()

/turf/open/floor/ChangeTurf(path, new_baseturfs, flags)
	if(!isfloorturf(src))
		return ..() //fucking turfs switch the fucking src of the fucking running procs
	if(!ispath(path, /turf/open/floor))
		return ..()
	var/old_dir = dir
	var/turf/open/floor/W = ..()
	W.setDir(old_dir)
	W.update_appearance()
	return W

/turf/open/floor/attackby(obj/item/object, mob/living/user, params)
	if(!object || !user)
		return TRUE
	. = ..()
	if(.)
		return .
	if(overfloor_placed && istype(object, /obj/item/stack/tile))
		try_replace_tile(object, user, params)
		return TRUE
	if(user.combat_mode && istype(object, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/sheets = object
		return sheets.on_attack_floor(user, params)
	return FALSE

/turf/open/floor/crowbar_act(mob/living/user, obj/item/I)
	if(overfloor_placed && pry_tile(I, user))
		return TRUE

/turf/open/floor/proc/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	if(T.turf_type == type && T.turf_dir == dir)
		return
	var/obj/item/crowbar/CB = user.is_holding_item_of_type(/obj/item/crowbar)
	if(!CB)
		return
	var/turf/open/floor/plating/P = pry_tile(CB, user, TRUE)
	if(!istype(P))
		return
	P.attackby(T, user, params)

/turf/open/floor/proc/pry_tile(obj/item/I, mob/user, silent = FALSE)
	I.play_tool_sound(src, 80)
	return remove_tile(user, silent)

/turf/open/floor/proc/remove_tile(mob/user, silent = FALSE, make_tile = TRUE, force_plating)
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
	return make_plating(force_plating)

/turf/open/floor/proc/has_tile()
	return floor_tile

/turf/open/floor/proc/spawn_tile()
	if(!has_tile())
		return null
	return new floor_tile(src)

/turf/open/floor/material
	name = "floor"
	icon_state = "materialfloor"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	floor_tile = /obj/item/stack/tile/material

/turf/open/floor/material/has_tile()
	return LAZYLEN(custom_materials)

/turf/open/floor/material/spawn_tile()
	. = ..()
	if(.)
		var/obj/item/stack/tile = .
		tile.set_mats_per_unit(custom_materials, 1)
