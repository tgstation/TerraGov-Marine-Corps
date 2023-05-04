/*
* Platforms
*/
/obj/structure/platform
	name = "platform"
	desc = "A square metal surface resting on four legs."
	icon = 'icons/obj/structures/platforms.dmi'
	icon_state = "platform"
	coverage = 10
	layer = OBJ_LAYER
	flags_atom = ON_BORDER
	resistance_flags = RESIST_ALL
	var/climb_slowdown = 0.5 SECONDS

/obj/structure/platform/gelida //toremove

/obj/structure/platform/Initialize(mapload)
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
		COMSIG_ATOM_ENTERED = PROC_REF(on_enter),
		COMSIG_ATOM_EXITED = PROC_REF(on_exit),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/platform/proc/on_enter(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(arrived.throwing)
		return NONE
	if((arrived.status_flags & INCORPOREAL))
		return
	if(!(flags_atom & ON_BORDER))
		return
	if(!ismob(arrived))
		return
	if(!isturf(old_loc))
		return
	if(get_dist(src, old_loc) != 1)
		return

	var/mob/arriving_mob = arrived
	var/old_loc_dir = get_dir(src, old_loc)
	if(old_loc_dir & dir)
		arriving_mob.client.move_delay += climb_slowdown

/obj/structure/platform/proc/on_exit(datum/source, atom/movable/exiting, direction, list/knownblockers)
	SIGNAL_HANDLER
	if(exiting.throwing)
		return NONE
	if((exiting.status_flags & INCORPOREAL))
		return
	if(!(flags_atom & ON_BORDER))
		return
	if(!ismob(exiting))
		return

	var/mob/exiting_mob = exiting
	if(direction & dir)
		exiting_mob.client.move_delay += climb_slowdown

/obj/structure/platform_decoration
	name = "platform"
	desc = "A square metal surface resting on four legs."
	icon_state = "platform_deco"
	layer = 3.5

/obj/structure/platform_decoration/Initialize(mapload)
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

/obj/structure/platform/rockcliff
	icon_state = "rockcliff"
	name = "rock cliff"
	desc = "A collection of stones and rocks that form a steep cliff, it looks climbable."

/obj/structure/platform_decoration/rockcliff_deco
	icon_state = "rockcliff_deco"
	name = "rock cliff"
	desc = "A collection of stones and rocks that form a steep cliff, it looks climbable."

/obj/structure/platform/rockcliff/icycliff
	icon_state = "icerock"

/obj/structure/platform_decoration/rockcliff_deco/icycliff_deco
	icon_state = "icerock_deco"

/obj/structure/platform/metalplatform
	icon_state = "metalplatform"

/obj/structure/platform_decoration/metalplatform_deco
	icon_state = "metalplatform_deco"

/obj/structure/platform/platform2
	icon_state = "platform2"

/obj/structure/platform_decoration/platform2_deco
	icon_state = "platform2_deco"

/obj/structure/platform/trench
	icon_state = "platformtrench"
	name = "trench wall"
	desc = "A group of roughly cut planks forming the side of a dug in trench."
	obj_integrity = 400
	max_integrity = 400

/obj/structure/fakeplatform
	name = "platform"
	desc = "A square metal surface resting on four legs."
	icon = 'icons/obj/structures/platforms.dmi'
	icon_state = "platform"
	anchored = TRUE
	density = FALSE //no density these platforms are for looks not for climbing
	coverage = 0
	layer = LATTICE_LAYER
	climb_delay = 20 //Leaping a barricade is universally much faster than clumsily climbing on a table or rack
	resistance_flags = XENO_DAMAGEABLE	//TEMP PATCH UNTIL XENO AI PATHFINDING IS BETTER, SET THIS TO INDESTRUCTIBLE ONCE IT IS - Tivi
	obj_integrity = 50	//Ditto
	max_integrity = 50	//Ditto

/obj/structure/fakeplatform/Initialize(mapload)
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

/obj/structure/fakeplatform/magmoor
	icon_state = "metalplatform"
	layer = LATTICE_LAYER
