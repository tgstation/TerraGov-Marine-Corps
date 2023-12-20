/obj/machinery/computer/camera_advanced/shuttle_docker
	name = "navigation computer"
	desc = "Used to designate a precise transit location for a spacecraft."
	jump_action = null

	/// Action of rotating the shuttle around its center
	var/datum/action/innate/shuttledocker_rotate/rotate_action = new
	/// Action of placing the shuttle custom landing zone
	var/datum/action/innate/shuttledocker_place/place_action = new
	/// The id of the shuttle linked to this console
	var/shuttleId = ""
	/// The id of the custom docking port placed by this console
	var/shuttlePortId = ""
	/// The name of the custom docking port placed by this console
	var/shuttlePortName = "Custom Location"
	/// Hashset of ports to jump to and ignore for collision purposes
	var/list/jumpto_ports = list()
	/// The custom docking port placed by this console
	var/obj/docking_port/stationary/my_port
	/// The previous custom docking port that was safely landed at, for emergency landings
	var/obj/docking_port/stationary/last_valid_ground_port
	/// The mobile docking port of the connected shuttle
	var/obj/docking_port/mobile/shuttle_port
	/// Traits forbided for custom docking
	var/list/locked_traits = list(ZTRAIT_RESERVED, ZTRAIT_CENTCOM)
	/// Dimensions of the viewport when using this console
	var/view_range = 0
	/// Horizontal offset from the console of the origin tile when using it
	var/x_offset = 0
	/// Vertical offset from the console of the origin tile when using it
	var/y_offset = 0
	/// Turfs that can be landed on
	var/list/whitelist_turfs = list(/turf/open/ground, /turf/open/floor, /turf/open/liquid/water)
	/// Are we able to see hidden ports when using the console
	var/see_hidden = FALSE
	/// Delay of the place_action
	var/designate_time = 0
	/// Turf that was selected for landing
	var/turf/designating_target_loc
	/// The console is unusable when jammed
	var/jammed = FALSE
	/// If the user wants to see with night vision on
	var/nvg_vision_mode = FALSE

/obj/machinery/computer/camera_advanced/shuttle_docker/Initialize(mapload)
	. = ..()
	if(!mapload)
		connect_to_shuttle(SSshuttle.get_containing_shuttle(src))

		for(var/obj/docking_port/stationary/S AS in SSshuttle.stationary)
			if(S.id == shuttleId)
				jumpto_ports[S.id] = TRUE

	for(var/V in SSshuttle.stationary)
		if(!V)
			continue
		var/obj/docking_port/stationary/S = V
		if(jumpto_ports[S.id])
			z_lock |= S.z
	whitelist_turfs = typecacheof(whitelist_turfs)

/obj/machinery/computer/camera_advanced/shuttle_docker/Destroy()
	if(my_port?.get_docked())
		my_port.delete_after = TRUE
		my_port.id = null
		my_port.name = "Old [my_port.name]"
		my_port = null
	else
		QDEL_NULL(my_port)
	return ..()

/obj/machinery/computer/camera_advanced/shuttle_docker/attack_hand(mob/user)
	if(jammed)
		to_chat(user, span_warning("You can only see static on the console."))
		return
	if(!shuttle_port && !SSshuttle.getShuttle(shuttleId))
		to_chat(user,span_warning("Warning: Shuttle connection severed!"))
		return
	return ..()

/obj/machinery/computer/camera_advanced/shuttle_docker/interact(mob/user)
	if(!allowed(user))
		return
	..()

///Change the fly state of the shuttle, called when a new shuttle port is reached
/obj/machinery/computer/camera_advanced/shuttle_docker/proc/shuttle_arrived()
	return

/obj/machinery/computer/camera_advanced/shuttle_docker/give_actions(mob/living/user)
	if(length(jumpto_ports))
		jump_action = new /datum/action/innate/camera_jump/shuttle_docker
	..()
	if(rotate_action)
		rotate_action.target = user
		rotate_action.give_action(user)
		actions += rotate_action

	if(place_action)
		place_action.target = user
		place_action.give_action(user)
		actions += place_action

/obj/machinery/computer/camera_advanced/shuttle_docker/CreateEye()
	shuttle_port = SSshuttle.getShuttle(shuttleId)
	if(QDELETED(shuttle_port))
		shuttle_port = null
		return
	shuttle_port.shuttle_computer = src
	eyeobj = new /mob/camera/aiEye/remote/shuttle_docker(null, src)
	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	the_eye.setDir(shuttle_port.dir)
	var/turf/origin = locate(shuttle_port.x + x_offset, shuttle_port.y + y_offset, shuttle_port.z)
	for(var/V in shuttle_port.shuttle_areas)
		var/area/A = V
		for(var/turf/T in A)
			if(T.z != origin.z)
				continue
			var/image/I = image('icons/effects/alphacolors.dmi', origin, "red")
			var/x_off = T.x - origin.x
			var/y_off = T.y - origin.y
			I.loc = locate(origin.x + x_off, origin.y + y_off, origin.z) //we have to set this after creating the image because it might be null, and images created in nullspace are immutable.
			I.layer = ABOVE_NORMAL_TURF_LAYER
			I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			the_eye.placement_images[I] = list(x_off, y_off)

/obj/machinery/computer/camera_advanced/shuttle_docker/give_eye_control(mob/user)
	. = ..()
	if(QDELETED(user) || !user.client)
		return
	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	var/list/to_add = list()
	to_add += the_eye.placement_images
	to_add += the_eye.placed_images
	if(!see_hidden)
		to_add += SSshuttle.hidden_shuttle_turf_images
	user.client.images += to_add
	user.client.view_size.set_view_radius_to(view_range)

/obj/machinery/computer/camera_advanced/shuttle_docker/remove_eye_control(mob/living/user)
	. = ..()
	if(QDELETED(user) || !user.client || !eyeobj)
		return
	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	var/list/to_remove = list()
	to_remove += the_eye.placement_images
	to_remove += the_eye.placed_images
	if(!see_hidden)
		to_remove += SSshuttle.hidden_shuttle_turf_images
	user.client.images -= to_remove
	user.client.view_size.reset_to_default()

/// Handles the creation of the custom landing spot
/obj/machinery/computer/camera_advanced/shuttle_docker/proc/placeLandingSpot()
	if(designating_target_loc || !current_user)
		return

	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	var/landing_clear = checkLandingSpot()
	if(designate_time && (landing_clear != SHUTTLE_DOCKER_BLOCKED))
		to_chat(current_user, span_warning("Targeting transit location, please wait [DisplayTimeText(designate_time)]..."))
		designating_target_loc = the_eye.loc
		var/wait_completed = do_after(current_user, designate_time, NONE, designating_target_loc, extra_checks = CALLBACK(src, /obj/machinery/computer/camera_advanced/shuttle_docker/proc/canDesignateTarget))
		designating_target_loc = null
		if(!current_user)
			return
		if(!wait_completed)
			to_chat(current_user, span_warning("Operation aborted."))
			return
		landing_clear = checkLandingSpot()

	if(landing_clear != SHUTTLE_DOCKER_LANDING_CLEAR)
		switch(landing_clear)
			if(SHUTTLE_DOCKER_BLOCKED)
				to_chat(current_user, span_warning("Invalid transit location."))
			if(SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT)
				to_chat(current_user, span_warning("Unknown object detected in landing zone. Please designate another location."))
		return

	/// Create one use port that deleted after fly off, to not lose information that is needed to properly fly off.
	if(my_port?.get_docked())
		my_port.unregister()
		my_port.delete_after = TRUE
		my_port.id = null
		my_port.name = "Old [my_port.name]"
		my_port = null

	if(!my_port)
		my_port = new()
		my_port.unregister()
		my_port.name = shuttlePortName
		my_port.id = shuttlePortId
		my_port.height = shuttle_port.height
		my_port.width = shuttle_port.width
		my_port.dheight = shuttle_port.dheight
		my_port.dwidth = shuttle_port.dwidth
		my_port.hidden = shuttle_port.hidden
		my_port.register(TRUE)
	my_port.setDir(the_eye.dir)
	my_port.forceMove(locate(eyeobj.x - x_offset, eyeobj.y - y_offset, eyeobj.z))

	if(current_user.client)
		current_user.client.images -= the_eye.placed_images

	QDEL_LIST(the_eye.placed_images)

	for(var/V in the_eye.placement_images)
		var/image/I = V
		var/image/newI = image('icons/effects/alphacolors.dmi', the_eye.loc, "blue")
		newI.loc = I.loc //It is highly unlikely that any landing spot including a null tile will get this far, but better safe than sorry.
		newI.layer = ABOVE_OPEN_TURF_LAYER
		newI.plane = 0
		newI.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		the_eye.placed_images += newI

	if(current_user.client)
		current_user.client.images += the_eye.placed_images
		to_chat(current_user, span_notice("Transit location designated."))
	return TRUE

/// Checks if we are able to designate the target location
/obj/machinery/computer/camera_advanced/shuttle_docker/proc/canDesignateTarget()
	if(!designating_target_loc || !current_user || (eyeobj.loc != designating_target_loc) || (machine_stat & (NOPOWER|BROKEN)) )
		return FALSE
	return TRUE

/// Handles the rotation of the shuttle
/obj/machinery/computer/camera_advanced/shuttle_docker/proc/rotateLandingSpot()
	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	var/list/image_cache = the_eye.placement_images
	the_eye.setDir(turn(the_eye.dir, -90))
	for(var/i in 1 to length(image_cache))
		var/image/pic = image_cache[i]
		var/list/coords = image_cache[pic]
		var/Tmp = coords[1]
		coords[1] = coords[2]
		coords[2] = -Tmp
		pic.loc = locate(the_eye.x + coords[1], the_eye.y + coords[2], the_eye.z)
	var/Tmp = x_offset
	x_offset = y_offset
	y_offset = -Tmp
	checkLandingSpot()

/// Checks if the currently hovered area is accessible by the shuttle
/obj/machinery/computer/camera_advanced/shuttle_docker/proc/check_hovering_spot(turf/next_turf)
	if(!next_turf)
		return
	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	var/list/image_cache = the_eye.placement_images
	for(var/i in 1 to length(image_cache))
		var/image/I = image_cache[i]
		var/list/coords = image_cache[I]
		var/turf/T = locate(next_turf.x + coords[1], next_turf.y + coords[2], next_turf.z)
		var/area/A = get_area(T)
		if(!A)
			return FALSE
		if(A.ceiling == CEILING_NONE || A.ceiling == CEILING_GLASS || A.ceiling ==CEILING_METAL)
			continue
		return FALSE
	return TRUE


/// Checks if the currently hovered area is a valid landing spot
/obj/machinery/computer/camera_advanced/shuttle_docker/proc/checkLandingSpot()
	var/mob/camera/aiEye/remote/shuttle_docker/the_eye = eyeobj
	var/turf/eyeturf = get_turf(the_eye)
	if(!eyeturf)
		return SHUTTLE_DOCKER_BLOCKED
	if(!eyeturf.z || SSmapping.level_has_any_trait(eyeturf.z, locked_traits))
		return SHUTTLE_DOCKER_BLOCKED

	. = SHUTTLE_DOCKER_LANDING_CLEAR
	var/list/bounds = shuttle_port.return_coords(the_eye.x - x_offset, the_eye.y - y_offset, the_eye.dir)
	var/list/overlappers = SSshuttle.get_dock_overlap(bounds[1], bounds[2], bounds[3], bounds[4], the_eye.z)
	var/list/image_cache = the_eye.placement_images
	for(var/i in 1 to length(image_cache))
		var/image/I = image_cache[i]
		var/list/coords = image_cache[I]
		var/turf/T = locate(eyeturf.x + coords[1], eyeturf.y + coords[2], eyeturf.z)
		I.loc = T
		switch(checkLandingTurf(T, overlappers))
			if(SHUTTLE_DOCKER_LANDING_CLEAR)
				I.icon_state = "green"
			if(SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT)
				I.icon_state = "green"
				if(. == SHUTTLE_DOCKER_LANDING_CLEAR)
					. = SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT
			else
				I.icon_state = "red"
				. = SHUTTLE_DOCKER_BLOCKED

/// Checks if the turf is valid for landing
/obj/machinery/computer/camera_advanced/shuttle_docker/proc/checkLandingTurf(turf/T, list/overlappers)
	// Too close to the map edge is never allowed
	if(!T || T.x <= 10 || T.y <= 10 || T.x >= world.maxx - 10 || T.y >= world.maxy - 10)
		return SHUTTLE_DOCKER_BLOCKED
	var/area/turf_area = get_area(T)
	if(turf_area.ceiling >= CEILING_OBSTRUCTED)
		return SHUTTLE_DOCKER_BLOCKED
	// If it's one of our shuttle areas assume it's ok to be there
	if(shuttle_port.shuttle_areas[T.loc])
		return SHUTTLE_DOCKER_LANDING_CLEAR
	. = SHUTTLE_DOCKER_LANDING_CLEAR
	// See if the turf is hidden from us
	var/list/hidden_turf_info
	if(!see_hidden)
		hidden_turf_info = SSshuttle.hidden_shuttle_turfs[T]
		if(hidden_turf_info)
			. = SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT

	for(var/obj/O in T)
		if(CHECK_BITFIELD(O.resistance_flags, DROPSHIP_IMMUNE))
			return SHUTTLE_DOCKER_BLOCKED

	if(length(whitelist_turfs))
		var/turf_type = hidden_turf_info ? hidden_turf_info[2] : T.type
		if(!is_type_in_typecache(turf_type, whitelist_turfs))
			return SHUTTLE_DOCKER_BLOCKED

	// Checking for overlapping dock boundaries
	for(var/i in 1 to length(overlappers))
		var/obj/docking_port/port = overlappers[i]
		if(port == my_port)
			continue
		var/port_hidden = !see_hidden && port.hidden
		var/list/overlap = overlappers[port]
		var/list/xs = overlap[1]
		var/list/ys = overlap[2]
		if(xs["[T.x]"] && ys["[T.y]"])
			// The only hidden ports are for the crash ships
			if(port_hidden)
				. = SHUTTLE_DOCKER_LANDING_CLEAR
			else
				return SHUTTLE_DOCKER_BLOCKED

/obj/machinery/computer/camera_advanced/shuttle_docker/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	if(port)
		shuttleId = port.id
		shuttlePortId = "[port.id]_custom"
	if(dock)
		jumpto_ports[dock.id] = TRUE

/mob/camera/aiEye/remote/shuttle_docker
	visible_icon = FALSE
	use_static = FALSE
	var/list/placement_images = list()
	var/list/placed_images = list()
	/// If it is possible to have night vision, if false the user will get turf vision
	var/nvg_vision_possible = TRUE

/mob/camera/aiEye/remote/shuttle_docker/Initialize(mapload, obj/machinery/computer/camera_advanced/origin)
	src.origin = origin
	return ..()

/mob/camera/aiEye/remote/shuttle_docker/relaymove(mob/user, direct)
	var/turf/T = get_turf(get_step(src, direct))
	var/obj/machinery/computer/camera_advanced/shuttle_docker/console = origin
	if(console.check_hovering_spot(T) != nvg_vision_possible) //Cannot see in caves
		nvg_vision_possible = !nvg_vision_possible
		update_remote_sight(user)
	if(T)
		setLoc(T)

/mob/camera/aiEye/remote/shuttle_docker/setLoc(T)
	..()
	var/obj/machinery/computer/camera_advanced/shuttle_docker/console = origin
	console?.checkLandingSpot()

/mob/camera/aiEye/remote/shuttle_docker/update_remote_sight(mob/living/user)
	var/obj/machinery/computer/camera_advanced/shuttle_docker/console = origin
	if(nvg_vision_possible && console.nvg_vision_mode)
		user.see_in_dark = 6
		user.sight = 0
		user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		user.sync_lighting_plane_alpha()
		return TRUE
	user.see_in_dark = 0
	user.sight = BLIND|SEE_TURFS
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	user.sync_lighting_plane_alpha()
	return TRUE

/datum/action/innate/shuttledocker_rotate
	name = "Rotate"
	action_icon = 'icons/mecha/actions_mecha.dmi'
	action_icon_state = "mech_cycle_equip_off"

/datum/action/innate/shuttledocker_rotate/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/shuttle_docker/origin = remote_eye.origin
	origin.rotateLandingSpot()

/datum/action/innate/shuttledocker_place
	name = "Place"
	action_icon = 'icons/mecha/actions_mecha.dmi'
	action_icon_state = "mech_zoom_off"

/datum/action/innate/shuttledocker_place/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/shuttle_docker/origin = remote_eye.origin
	origin.placeLandingSpot(target)

/datum/action/innate/camera_jump/shuttle_docker
	name = "Jump to Location"
	action_icon_state = "camera_jump"

/datum/action/innate/camera_jump/shuttle_docker/Activate()
	if(QDELETED(target) || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/shuttle_docker/console = remote_eye.origin

	playsound(console, 'sound/machines/terminal_prompt_deny.ogg', 25, FALSE)

	var/list/L = list()
	for(var/V in SSshuttle.stationary)
		if(!V)
			stack_trace("SSshuttle.stationary have null entry!")
			continue
		var/obj/docking_port/stationary/S = V
		if(length(console.z_lock) && !(S.z in console.z_lock))
			continue
		if(console.jumpto_ports[S.id])
			L["([length(L)])[S.name]"] = S

	playsound(console, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
	var/selected = input("Choose location to jump to", "Locations", null) as null|anything in sortList(L)
	if(QDELETED(src) || QDELETED(target) || !isliving(target))
		return
	playsound(src, "terminal_type", 25, FALSE)
	if(selected)
		var/turf/T = get_turf(L[selected])
		if(T)
			playsound(console, 'sound/machines/terminal_prompt_confirm.ogg', 25, FALSE)
			remote_eye.setLoc(T)
			to_chat(target, span_notice("Jumped to [selected]."))
			C.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/noise)
			C.clear_fullscreen("flash", 3)
	else
		playsound(console, 'sound/machines/terminal_prompt_deny.ogg', 25, FALSE)
