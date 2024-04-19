#define STAIR_TERMINATOR_AUTOMATIC 0
#define STAIR_TERMINATOR_NO 1
#define STAIR_TERMINATOR_YES 2

// dir determines the direction of travel to go upwards
// stairs require /turf/open/openspace as the tile above them to work, unless your stairs have 'force_open_above' set to TRUE
// multiple stair objects can be chained together; the Z level transition will happen on the final stair object in the chain

/obj/structure/stairs/multiz
	name = "stairs"
	icon_state = "stairs"
	anchored = TRUE

	var/force_open_above = FALSE // replaces the turf above this stair obj with /turf/open/openspace
	var/terminator_mode = STAIR_TERMINATOR_AUTOMATIC
	var/turf/listeningTo

/obj/structure/stairs/multiz/north
	dir = NORTH

/obj/structure/stairs/multiz/south
	dir = SOUTH

/obj/structure/stairs/multiz/east
	dir = EAST

/obj/structure/stairs/multiz/west
	dir = WEST

/obj/structure/stairs/multiz/Initialize(mapload)
	if(force_open_above)
		force_open_above()
		build_signal_listener()
	update_surrounding()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = .proc/on_exit,
	)

	AddElement(/datum/element/connect_loc, loc_connections)

	return ..()

/obj/structure/stairs/multiz/Destroy()
	listeningTo = null
	return ..()

/obj/structure/stairs/multiz/Move() //Look this should never happen but...
	. = ..()
	if(force_open_above)
		build_signal_listener()
	update_surrounding()

/obj/structure/stairs/multiz/proc/update_surrounding()
	update_icon()
	for(var/i in GLOB.cardinals)
		var/turf/T = get_step(get_turf(src), i)
		var/obj/structure/stairs/multiz/S = locate() in T
		if(S)
			S.update_icon()

/obj/structure/stairs/multiz/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving == src)
		return // Let's not block ourselves.

	if(!isobserver(leaving) && isTerminator() && direction == dir)
		INVOKE_ASYNC(src, .proc/stair_ascend, leaving)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/stairs/multiz/Cross(atom/movable/AM)
	if(isTerminator() && (get_dir(src, AM) == dir))
		return FALSE
	return ..()

/obj/structure/stairs/multiz/update_icon_state()
	icon_state = "stairs[isTerminator() ? "_t" : null]"
	return ..()

/obj/structure/stairs/multiz/proc/stair_ascend(atom/movable/AM)
	var/turf/checking = get_step_multiz(get_turf(src), UP)
	if(!istype(checking))
		return
	if(!checking.zPassIn(AM, UP, get_turf(src)))
		return
	var/turf/target = get_step_multiz(get_turf(src), (dir|UP))
	if(istype(target) && !target.can_zFall(AM, null, get_step_multiz(target, DOWN))) //Don't throw them into a tile that will just dump them back down.
		if(isliving(AM))
			var/mob/living/L = AM
			var/pulling = L.pulling
			if(pulling)
				L.pulling.forceMove(target)
			L.forceMove(target)
			L.start_pulling(pulling)
		else
			AM.forceMove(target)

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
	RegisterSignal(T, COMSIG_TURF_MULTIZ_NEW, .proc/on_multiz_new)
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

/obj/structure/stairs/multiz/intercept_zImpact(atom/movable/AM, levels = 1)
	. = ..()
	if(isTerminator())
		. |= FALL_INTERCEPTED | FALL_NO_MESSAGE

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

/obj/structure/stairs/multiz/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return
	stair_ascend(user)
