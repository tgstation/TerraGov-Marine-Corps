
/obj/structure/periscope
	name = "tank periscope"
	desc = "A periscope for viewing the outside of the vehicle. Resist or move to stop looking through it."
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	icon_state = "periscope"
	density = FALSE
	resistance_flags = RESIST_ALL
	///owner of this object, assigned during interior linkage
	var/obj/vehicle/sealed/armored/owner
	///The mob currently using this
	var/mob/viewer
	///how much tiles the zoom offsets to the direction it zooms to.
	var/zoom_tile_offset = 0
	///how much tiles the zoom zooms out, 7 is the default view.
	var/zoom_viewsize = 7

/obj/structure/periscope/Destroy()
	owner = null
	viewer = null
	return ..()

/obj/structure/periscope/link_interior(datum/interior/link)
	owner = link.container

/obj/structure/periscope/interact(mob/user)
	if(viewer)
		return
	. = ..()
	viewer = user
	user.reset_perspective(owner)
	ADD_TRAIT(user, TRAIT_SEE_IN_DARK, VEHICLE_TRAIT)
	user.update_sight()
	user.client.view_size.add(zoom_viewsize)
	change_zoom_offset(user, zoom_offset = zoom_tile_offset)
	RegisterSignals(user, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DO_RESIST, COMSIG_MOB_LOGOUT), PROC_REF(stop_looking))
	RegisterSignal(user, COMSIG_MOB_FACE_DIR, PROC_REF(change_zoom_offset))

/obj/structure/periscope/on_unset_interaction(mob/user)
	. = ..()
	viewer = null
	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DO_RESIST, COMSIG_MOB_LOGOUT, COMSIG_MOB_FACE_DIR))
	user.reset_perspective()
	REMOVE_TRAIT(user, TRAIT_SEE_IN_DARK, VEHICLE_TRAIT)
	if(user.client)
		user.client.view_size.reset_to_default()
		user.client.pixel_x = 0
		user.client.pixel_y = 0
	user.update_sight()

///signal handler for canceling the looking
/obj/structure/periscope/proc/stop_looking(mob/source)
	SIGNAL_HANDLER
	source.unset_interaction()

///applies the offset of the zooming, using animate for smoothing.
/obj/structure/periscope/proc/change_zoom_offset(mob/user, newdir, zoom_offset)
	SIGNAL_HANDLER
	if(!istype(user))
		return

	var/viewoffset = zoom_tile_offset * 32
	if(zoom_offset)
		viewoffset = zoom_offset * 32

	var/zoom_offset_time = 3*((viewoffset/32)/7)
	var/dirtooffset = newdir ? newdir : user.dir

	switch(dirtooffset)
		if(NORTH)
			animate(user.client, pixel_x = 0, pixel_y = viewoffset, time = zoom_offset_time)
		if(SOUTH)
			animate(user.client, pixel_x = 0, pixel_y = -viewoffset, time = zoom_offset_time)
		if(EAST)
			animate(user.client, pixel_x = viewoffset, pixel_y = 0, time = zoom_offset_time)
		if(WEST)
			animate(user.client, pixel_x = -viewoffset, pixel_y = 0, time = zoom_offset_time)

/obj/structure/periscope/apc
	name = "apc periscope"

/obj/structure/periscope/som
	icon = 'icons/obj/armored/3x4/som_interior_small_props.dmi'
	icon_state = "periscope"
	layer = MOB_BELOW_PIGGYBACK_LAYER
	pixel_x = -5

/obj/structure/periscope/som/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/periscope/som/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", src)

/obj/structure/periscope/fire_support
	name = "command periscope"
	interaction_flags = parent_type::interaction_flags|INTERACT_ALLOW_UNIQUE_ACTION
	zoom_tile_offset = 11
	zoom_viewsize = 12

/obj/structure/periscope/fire_support/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/fire_support)
