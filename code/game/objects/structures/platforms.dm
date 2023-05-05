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

/obj/structure/platform/Initialize(mapload)
	. = ..()
	apply_overlays()
	icon_state = ""

	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_enter),
		COMSIG_ATOM_EXITED = PROC_REF(on_exit),
	)
	AddElement(/datum/element/connect_loc, connections)

///clears and sets overlays based on current dir
/obj/structure/platform/proc/apply_overlays()
	overlays.Cut()
	var/image/new_overlay
	//surely there is an easier way than this boilerplate
	if(dir & EAST)
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, EAST)
		new_overlay.pixel_x = 32
		overlays += new_overlay

	if(dir & WEST)
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, WEST)
		new_overlay.pixel_x = -32
		overlays += new_overlay

	if(dir & NORTH)
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, NORTH)
		new_overlay.pixel_y = 32
		new_overlay.layer = ABOVE_MOB_LAYER //perspective
		overlays += new_overlay

	if(dir & SOUTH)
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, SOUTH)
		new_overlay.pixel_y = -32
		overlays += new_overlay

	if(CHECK_MULTIPLE_BITFIELDS(dir, NORTHEAST))
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, NORTHEAST)
		new_overlay.pixel_y = 32
		new_overlay.pixel_x = 32
		new_overlay.layer = ABOVE_MOB_LAYER
		overlays += new_overlay

	if(CHECK_MULTIPLE_BITFIELDS(dir, NORTHWEST))
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, NORTHWEST)
		new_overlay.pixel_y = 32
		new_overlay.pixel_x = -32
		new_overlay.layer = ABOVE_MOB_LAYER
		overlays += new_overlay

	if(CHECK_MULTIPLE_BITFIELDS(dir, SOUTHEAST))
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, SOUTHEAST)
		new_overlay.pixel_y = -32
		new_overlay.pixel_x = 32
		overlays += new_overlay

	if(CHECK_MULTIPLE_BITFIELDS(dir, SOUTHWEST))
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, SOUTHWEST)
		new_overlay.pixel_y = -32
		new_overlay.pixel_x = -32
		overlays += new_overlay



///Applies slowdown when entering if applicable
/obj/structure/platform/proc/on_enter(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(arrived.throwing)
		return NONE
	if((arrived.status_flags & INCORPOREAL))
		return
	if(!ismob(arrived))
		return
	if(!isturf(old_loc))
		return
	if(get_dist(src, old_loc) != 1) //teleporter shenanigans
		return

	var/mob/arriving_mob = arrived
	var/old_loc_dir = get_dir(src, old_loc)
	if(old_loc_dir & dir)
		arriving_mob.client.move_delay = world.time + climb_slowdown //applied directly to client movedelay as mob delay would only apply after an additional movement
		arriving_mob.balloon_alert_to_viewers("enter")

///Applies slowdown when exiting if applicable
/obj/structure/platform/proc/on_exit(datum/source, atom/movable/exiting, direction, list/knownblockers)
	SIGNAL_HANDLER
	if(exiting.throwing)
		return NONE
	if((exiting.status_flags & INCORPOREAL))
		return
	if(!ismob(exiting))
		return

	var/mob/exiting_mob = exiting
	if(direction & dir)
		exiting_mob.client.move_delay = world.time + climb_slowdown
		exiting_mob.balloon_alert_to_viewers("exit")

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

/obj/structure/platform/trench
	icon_state = "platformtrench"
	name = "trench wall"
	desc = "A group of roughly cut planks forming the side of a dug in trench."
	obj_integrity = 400
	max_integrity = 400

/obj/structure/platform/magmoor
	icon_state = "metalplatform"
	layer = LATTICE_LAYER

//decorative corner platform bits
/obj/structure/platform_decoration
	name = "platform"
	desc = "A square metal surface resting on four legs."
	icon = 'icons/obj/structures/platforms.dmi'
	icon_state = "platform_deco"
	anchored = TRUE
	density = FALSE
	layer = OBJ_LAYER
	flags_atom = ON_BORDER
	resistance_flags = RESIST_ALL

/obj/structure/platform_decoration/Initialize(mapload)
	. = ..()
	switch(dir)
		if(NORTH)
			layer = ABOVE_MOB_LAYER
		if(SOUTH)
			layer = ABOVE_MOB_LAYER
		if(SOUTHEAST)
			layer = ABOVE_MOB_LAYER
		if(SOUTHWEST)
			layer = ABOVE_MOB_LAYER
