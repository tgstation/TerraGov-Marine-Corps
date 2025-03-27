/turf/open/openspace
	name = "open space"
	desc = "Watch your step!"
	// We don't actually draw openspace, but it needs to have color
	// In its icon state so we can count it as a "non black" tile
	icon_state = MAP_SWITCH("pure_white", "transparent")
	baseturfs = /turf/open/openspace
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = TRANSPARENT_FLOOR_PLANE
	layer = SPACE_LAYER
	var/can_cover_up = TRUE
	var/can_build_on = TRUE

// Reminder, any behavior code written here needs to be duped to /turf/open/space/openspace
// I am so sorry
/turf/open/openspace/Initialize(mapload) // handle plane and layer here so that they don't cover other obs/turfs in Dream Maker
	. = ..()
	if(PERFORM_ALL_TESTS(focus_only/openspace_clear) && !GET_TURF_BELOW(src))
		stack_trace("[src] was inited as openspace with nothing below it at ([x], [y], [z])")
	RegisterSignal(src, COMSIG_ATOM_INITIALIZED_ON, PROC_REF(on_atom_created))
	RegisterSignal(src, COMSIG_TURF_JUMP_ENDED_HERE, PROC_REF(on_jump_land))
	return INITIALIZE_HINT_LATELOAD

/turf/open/openspace/LateInitialize()
	ADD_TURF_TRANSPARENCY(src, INNATE_TRAIT)

/turf/open/openspace/ChangeTurf(path, list/new_baseturfs, flags)
	UnregisterSignal(src, list(COMSIG_ATOM_INITIALIZED_ON, COMSIG_TURF_JUMP_ENDED_HERE))
	return ..()

/**
 * Prepares a moving movable to be precipitated if Move() is successful.
 * This is done in Enter() and not Entered() because there's no easy way to tell
 * if the latter was called by Move() or forceMove() while the former is only called by Move().
 */
/turf/open/openspace/Enter(atom/movable/movable, atom/oldloc)
	. = ..()
	if(.)
		//higher priority than CURRENTLY_Z_FALLING so the movable doesn't fall on Entered()
		movable.set_currently_z_moving(CURRENTLY_Z_FALLING_FROM_MOVE)

///Makes movables fall when forceMove()'d to this turf.
/turf/open/openspace/Entered(atom/movable/movable)
	. = ..()
	if(movable.set_currently_z_moving(CURRENTLY_Z_FALLING))
		zFall(movable, falling_from_move = TRUE)
/**
 * Drops movables spawned on this turf after they are successfully initialized.
 * so that spawned movables that should fall to gravity, will fall.
 */
/turf/open/openspace/proc/on_atom_created(datum/source, atom/created_atom)
	SIGNAL_HANDLER
	if(ismovable(created_atom))
		zfall_if_on_turf(created_atom)

///Drops movables spawned on this turf after they ended their jump here
/turf/open/openspace/proc/on_jump_land(datum/source, atom/movable/landing_atom)
	SIGNAL_HANDLER
	zfall_if_on_turf(landing_atom)

/turf/open/openspace/proc/zfall_if_on_turf(atom/movable/movable)
	if(QDELETED(movable) || movable.loc != src)
		return
	zFall(movable)

/turf/open/openspace/can_have_cabling()
	if(locate(/obj/structure/catwalk, src))
		return TRUE
	return FALSE

/turf/open/openspace/zPassIn(direction)
	if(direction == DOWN)
		for(var/obj/contained_object in contents)
			if(contained_object.obj_flags & BLOCK_Z_IN_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/contained_object in contents)
			if(contained_object.obj_flags & BLOCK_Z_IN_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/open/openspace/zPassOut(direction)
	if(direction == DOWN)
		for(var/obj/contained_object in contents)
			if(contained_object.obj_flags & BLOCK_Z_OUT_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/contained_object in contents)
			if(contained_object.obj_flags & BLOCK_Z_OUT_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/open/openspace/proc/CanCoverUp()
	return can_cover_up

/turf/open/openspace/proc/CanBuildHere()
	return can_build_on

/turf/open/openspace/attackby(obj/item/C, mob/user, params)
	..()
	if(!CanBuildHere())
		return
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		var/obj/structure/catwalk/W = locate(/obj/structure/catwalk, src)
		if(W)
			to_chat(user, span_warning("There is already a catwalk here!"))
			return
		if(L)
			if(R.use(1))
				qdel(L)
				to_chat(user, span_notice("You construct a catwalk."))
				playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
				new /obj/structure/catwalk(src)
			else
				to_chat(user, span_warning("You need two rods to build a catwalk!"))
			return
		if(R.use(1))
			to_chat(user, span_notice("You construct a lattice."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			ReplaceWithLattice()
		else
			to_chat(user, span_warning("You need one rod to build a lattice."))
		return
	if(istype(C, /obj/item/stack/tile/light))
		if(!CanCoverUp())
			return
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/light/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
				to_chat(user, span_notice("You build a floor."))
				PlaceOnTop(/turf/open/floor/plating)
			else
				to_chat(user, span_warning("You need one floor tile to build a floor!"))
		else
			to_chat(user, span_warning("The plating is going to need some support! Place iron rods first."))

/*
/turf/open/openspace/can_cross_safely(atom/movable/crossing)
	return HAS_TRAIT(crossing, TRAIT_MOVE_FLYING) || !crossing.can_z_move(DOWN, src, z_move_flags = ZMOVE_FALL_FLAGS)
*/
