///Slowdown applied when exiting this structure's turf
#define ENTRY_SLOWDOWN (1<<0)
///Slowdown applied when entering this structure's turf
#define EXIT_SLOWDOWN (1<<1)


/obj/structure/platform
	name = "platform"
	desc = "A square metal surface resting on four legs."
	icon = 'icons/obj/structures/platforms.dmi'
	icon_state = "platform"
	coverage = 10
	layer = BELOW_OBJ_LAYER
	flags_atom = ON_BORDER
	resistance_flags = RESIST_ALL
	obj_flags = PROJ_IGNORE_DENSITY
	///How much slowdown is applied by this platform
	var/climb_slowdown = 0.5 SECONDS
	///Dictates the slowdown behavior of this platform
	var/platform_flags = ENTRY_SLOWDOWN|EXIT_SLOWDOWN


/obj/structure/platform/Initialize(mapload)
	. = ..()
	update_icon()
	icon_state = null

	if(!platform_flags)
		return

	var/static/list/entry_and_exit = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_enter),
		COMSIG_ATOM_EXITED = PROC_REF(on_exit),
	)

	var/static/list/entry_only = list(COMSIG_ATOM_ENTERED = PROC_REF(on_enter))

	var/static/list/exit_only = list(COMSIG_ATOM_EXITED = PROC_REF(on_exit))


	AddElement(/datum/element/connect_loc, (platform_flags & ENTRY_SLOWDOWN) ? (platform_flags & EXIT_SLOWDOWN) ? entry_and_exit : entry_only : exit_only)

/obj/structure/platform/update_overlays()
	. = ..()
	var/image/new_overlay

	if(dir & EAST)
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, EAST)
		new_overlay.pixel_x = 32
		. += new_overlay

	if(dir & WEST)
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, WEST)
		new_overlay.pixel_x = -32
		. += new_overlay

	if(dir & NORTH)
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, NORTH)
		new_overlay.pixel_y = 32
		new_overlay.layer = ABOVE_MOB_LAYER //perspective
		. += new_overlay

	if(dir & SOUTH)
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, SOUTH)
		new_overlay.pixel_y = -32
		. += new_overlay

	if(CHECK_MULTIPLE_BITFIELDS(dir, NORTHEAST))
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, NORTHEAST)
		new_overlay.pixel_y = 32
		new_overlay.pixel_x = 32
		new_overlay.layer = ABOVE_MOB_PLATFORM_LAYER
		. += new_overlay

	if(CHECK_MULTIPLE_BITFIELDS(dir, NORTHWEST))
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, NORTHWEST)
		new_overlay.pixel_y = 32
		new_overlay.pixel_x = -32
		new_overlay.layer = ABOVE_MOB_PLATFORM_LAYER
		. += new_overlay

	if(CHECK_MULTIPLE_BITFIELDS(dir, SOUTHEAST))
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, SOUTHEAST)
		new_overlay.pixel_y = -32
		new_overlay.pixel_x = 32
		. += new_overlay

	if(CHECK_MULTIPLE_BITFIELDS(dir, SOUTHWEST))
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, SOUTHWEST)
		new_overlay.pixel_y = -32
		new_overlay.pixel_x = -32
		. += new_overlay

///Applies slowdown when entering if applicable
/obj/structure/platform/proc/on_enter(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!ismob(arrived))
		return
	if(arrived.throwing)
		return NONE
	if((arrived.status_flags & INCORPOREAL))
		return
	if(!isturf(old_loc))
		return
	if(get_dist(src, old_loc) != 1) //teleporter shenanigans
		return

	var/mob/arriving_mob = arrived
	var/old_loc_dir = get_dir(src, old_loc)
	if(old_loc_dir & dir)
		arriving_mob.client.move_delay += climb_slowdown //applied directly to client movedelay as mob delay would only apply after an additional movement

///Applies slowdown when exiting if applicable
/obj/structure/platform/proc/on_exit(datum/source, atom/movable/exiting, direction, list/knownblockers)
	SIGNAL_HANDLER
	if(!ismob(exiting))
		return
	if(exiting.throwing)
		return NONE
	if((exiting.status_flags & INCORPOREAL))
		return

	var/mob/exiting_mob = exiting
	if(direction & dir)
		exiting_mob.client.move_delay += climb_slowdown

/obj/structure/platform/rockcliff
	icon_state = "rockcliff"
	name = "rock cliff"
	desc = "A collection of stones and rocks that form a steep cliff, it looks climbable."

/obj/structure/platform/rockcliff/icycliff
	icon_state = "icerock"

/obj/structure/platform/metalplatform
	icon_state = "metalplatform"

/obj/structure/platform/trench
	icon_state = "platformtrench"
	name = "trench wall"
	desc = "A group of roughly cut planks forming the side of a dug in trench."

//decorative corner platform bits
/obj/structure/platform_decoration
	name = "platform"
	desc = "A square metal surface resting on four legs."
	icon = 'icons/obj/structures/platforms.dmi'
	icon_state = "platform_deco"
	flags_atom = ON_BORDER
	resistance_flags = RESIST_ALL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/platform_decoration/Initialize(mapload)
	. = ..()
	switch(dir)
		if(NORTH)
			layer = ABOVE_MOB_PLATFORM_LAYER
		if(SOUTH)
			layer = ABOVE_MOB_PLATFORM_LAYER
		if(SOUTHEAST)
			layer = ABOVE_MOB_PLATFORM_LAYER
		if(SOUTHWEST)
			layer = ABOVE_MOB_PLATFORM_LAYER

/obj/structure/platform_decoration/rockcliff_deco
	icon_state = "rockcliff_deco"
	name = "rock cliff"
	desc = "A collection of stones and rocks that form a steep cliff, it looks climbable."

/obj/structure/platform_decoration/rockcliff_deco/icycliff_deco
	icon_state = "icerock_deco"

/obj/structure/platform_decoration/metalplatform_deco
	icon_state = "metalplatform_deco"
