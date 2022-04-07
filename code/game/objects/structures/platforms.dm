/*
* Platforms
*/
/obj/structure/platform
	name = "platform"
	desc = "A square metal surface resting on four legs."
	icon = 'icons/obj/structures/platforms.dmi'
	icon_state = "platform"
	climbable = TRUE
	anchored = TRUE
	density = TRUE
	coverage = 10
	layer = OBJ_LAYER
	climb_delay = 20 //Leaping a barricade is universally much faster than clumsily climbing on a table or rack
	flags_atom = ON_BORDER
	resistance_flags = XENO_DAMAGEABLE	//TEMP PATCH UNTIL XENO AI PATHFINDING IS BETTER, SET THIS TO INDESTRUCTIBLE ONCE IT IS - Tivi
	obj_integrity = 1000	//Ditto
	max_integrity = 1000	//Ditto

/obj/structure/platform/Initialize()
	. = ..()
	var/image/I = image(icon, src, "platform_overlay", LADDER_LAYER, dir)//ladder layer puts us just above weeds.
	switch(dir)
		if(SOUTH)
			layer = ABOVE_MOB_LAYER
			I.pixel_y = -16
		if(NORTH)
			I.pixel_y = 16
		if(EAST)
			I.pixel_x = 16
		if(WEST)
			I.pixel_x = -16
	overlays += I
	var/static/list/connections = list(
		COMSIG_ATOM_EXIT = .proc/on_try_exit
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/platform/proc/on_try_exit(datum/source, atom/movable/O, direction, list/knownblockers)
	SIGNAL_HANDLER
	if(O.throwing)
		return NONE
	if(!density || !(flags_atom & ON_BORDER) || !(direction & dir) || (O.status_flags & INCORPOREAL))
		return NONE
	knownblockers += src
	return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/platform/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(mover && mover.throwing)
		return TRUE

	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S && S.climbable && !(S.flags_atom & ON_BORDER) && climbable && isliving(mover)) //Climbable objects allow you to universally climb over others
		return TRUE

	if(!(flags_atom & ON_BORDER) || !(get_dir(loc, target) & dir))
		return TRUE

obj/structure/platform_decoration
	name = "platform"
	desc = "A square metal surface resting on four legs."
	icon = 'icons/obj/structures/platforms.dmi'
	icon_state = "platform_deco"
	anchored = TRUE
	density = FALSE
	throwpass = TRUE
	layer = 3.5
	flags_atom = ON_BORDER
	resistance_flags = UNACIDABLE

/obj/structure/platform_decoration/Initialize()
	. = ..()
	switch(dir)
		if (NORTH)
			layer = ABOVE_MOB_LAYER
		if (SOUTH)
			layer = ABOVE_MOB_LAYER
		if (SOUTHEAST)
			layer = ABOVE_MOB_LAYER
		if (SOUTHWEST)
			layer = ABOVE_MOB_LAYER
