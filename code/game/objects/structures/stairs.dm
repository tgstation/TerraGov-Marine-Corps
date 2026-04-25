#define STAIR_TERMINATOR_AUTOMATIC 0
#define STAIR_TERMINATOR_NO 1
#define STAIR_TERMINATOR_YES 2

// dir determines the direction of travel to go upwards
// stairs require /turf/open/openspace as the tile above them to work, unless your stairs have 'force_open_above' set to TRUE
// multiple stair objects can be chained together; the Z level transition will happen on the final stair object in the chain

/obj/structure/stairs/multiz
	name = "stairs"
	anchored = TRUE
	move_resist = INFINITY
	layer = ABOVE_WEEDS_LAYER
	resistance_flags = RESIST_ALL

	var/force_open_above = FALSE //! replaces the turf above this stair obj with /turf/open/openspace
	///helps us decide if we're the ending stair
	var/terminator_mode = STAIR_TERMINATOR_AUTOMATIC
	var/turf/listeningTo

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/stairs/multiz, 0)

/obj/structure/stairs/multiz/Initialize(mapload)
	GLOB.stairs += src
	if(force_open_above)
		force_open_above()
		build_signal_listener()
	update_surrounding()
	var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
	if(T && istype(T, /turf/open/openspace))
		SSminimaps.add_marker(T, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, "stairs_down", MINIMAP_LABELS_LAYER))
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, "stairs_up", MINIMAP_LABELS_LAYER))

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

	return ..()

/obj/structure/stairs/multiz/Destroy()
	listeningTo = null
	GLOB.stairs -= src
	return ..()

/obj/structure/stairs/multiz/Move() //Look this should never happen but...
	. = ..()
	if(force_open_above)
		build_signal_listener()
	update_surrounding()

/obj/structure/stairs/multiz/proc/update_surrounding()
	update_appearance()
	for(var/i in GLOB.cardinals)
		var/turf/T = get_step(get_turf(src), i)
		var/obj/structure/stairs/multiz/S = locate() in T
		if(S)
			S.update_appearance()

/obj/structure/stairs/multiz/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving == src)
		return //Let's not block ourselves.

	if(!isobserver(leaving) && isTerminator() && direction == dir)
		leaving.set_currently_z_moving(CURRENTLY_Z_ASCENDING)
		INVOKE_ASYNC(src, PROC_REF(stair_ascend), leaving)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/stairs/multiz/Cross(atom/movable/AM)
	if(isTerminator() && (get_dir(src, AM) == dir))
		return FALSE
	return ..()

/obj/structure/stairs/multiz/proc/stair_ascend(atom/movable/climber)
	var/turf/checking = get_step_multiz(get_turf(src), UP)
	if(!istype(checking))
		return
	// I'm only interested in if the pass is unobstructed, not if the mob will actually make it
	if(!climber.can_z_move(UP, get_turf(src), checking, z_move_flags = ZMOVE_ALLOW_BUCKLED))
		return
	var/turf/target = get_step_multiz(get_turf(src), (dir|UP))
	if(istype(target) && !climber.can_z_move(DOWN, target, z_move_flags = ZMOVE_FALL_FLAGS)) //Don't throw them into a tile that will just dump them back down.
		climber.zMove(target = target, z_move_flags = ZMOVE_STAIRS_FLAGS)
		/// Moves anything that's being dragged by src or anything buckled to it to the stairs turf.
		climber.pulling?.move_from_pull(climber, loc, climber.glide_size)
		for(var/mob/living/buckled as anything in climber.buckled_mobs)
			buckled.pulling?.move_from_pull(buckled, loc, buckled.glide_size)


/obj/structure/stairs/multiz/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name != NAMEOF(src, force_open_above))
		return
	if(!var_value)
		if(listeningTo)
			UnregisterSignal(listeningTo, COMSIG_TURF_MULTIZ_NEW)
			listeningTo = null
	else
		build_signal_listener()
		force_open_above()

/obj/structure/stairs/multiz/proc/build_signal_listener()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_TURF_MULTIZ_NEW)
	var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
	RegisterSignal(T, COMSIG_TURF_MULTIZ_NEW, PROC_REF(on_multiz_new))
	listeningTo = T

/obj/structure/stairs/multiz/proc/force_open_above()
	var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
	if(T && !istype(T))
		T.ChangeTurf(/turf/open/openspace)

/obj/structure/stairs/multiz/proc/on_multiz_new(turf/source, dir)
	SIGNAL_HANDLER

	if(dir == UP)
		var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
		if(T && !istype(T))
			T.ChangeTurf(/turf/open/openspace)

/obj/structure/stairs/multiz/intercept_zImpact(list/falling_movables, levels = 1)
	. = ..()
	if(levels == 1 && isTerminator()) // Stairs won't save you from a steep fall.
		. |= FALL_INTERCEPTED | FALL_NO_MESSAGE | FALL_RETAIN_PULL

/obj/structure/stairs/multiz/proc/isTerminator() //If this is the last stair in a chain and should move mobs up
	if(terminator_mode != STAIR_TERMINATOR_AUTOMATIC)
		return (terminator_mode == STAIR_TERMINATOR_YES)
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	var/turf/them = get_step(T, dir)
	if(!them)
		return FALSE
	for(var/obj/structure/stairs/multiz/S in them)
		if(S.dir == dir)
			return FALSE
	return TRUE
