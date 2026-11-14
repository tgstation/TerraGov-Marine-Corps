GLOBAL_LIST_INIT(ventcrawl_machinery, typecacheof(list(
	/obj/machinery/atmospherics/components/unary/vent_pump,
	/obj/machinery/atmospherics/components/unary/vent_scrubber)))

/mob/proc/start_ventcrawl()
	var/atom/pipe
	var/list/pipes = list()
	for(var/obj/machinery/atmospherics/components/unary/U in range(1))
		if(is_type_in_list(U, GLOB.ventcrawl_machinery) && Adjacent(U))
			pipes |= U
	if(!pipes || !length(pipes))
		balloon_alert(src, "no pipes in range!")
		return
	if(length(pipes) == 1)
		pipe = pipes[1]
	else
		pipe = tgui_input_list(usr, "Crawl Through Vent", "Pick a pipe",  pipes)
	if(!incapacitated() && pipe)
		return pipe

/// Checks if the mob is able to enter the vent, and provides feedback if they are unable to.
/mob/living/proc/can_enter_vent(obj/machinery/atmospherics/ventcrawl_target, provide_feedback = TRUE)
	if(!Adjacent(ventcrawl_target))
		return
	if(!HAS_TRAIT(src, TRAIT_CAN_VENTCRAWL))
		return
	if(stat)
		if(provide_feedback)
			to_chat(src, span_warning("You must be conscious to do this!"))
		return
	if(HAS_TRAIT(src, TRAIT_IMMOBILE))
		if(provide_feedback)
			to_chat(src, span_warning("You currently can't move into the vent!"))
		return
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		if(provide_feedback)
			to_chat(src, span_warning("You need to be able to use your hands to ventcrawl!"))
		return
	if(length(buckled_mobs))
		if(provide_feedback)
			to_chat(src, span_warning("You can't vent crawl with other creatures on you!"))
		return
	if(buckled)
		if(provide_feedback)
			to_chat(src, span_warning("You can't vent crawl while buckled!"))
		return
	if(istype(ventcrawl_target, /obj/machinery/atmospherics/components))
		var/obj/machinery/atmospherics/components/component_target = ventcrawl_target
		if(component_target.welded)
			if(provide_feedback)
				// Add cooldown to prevent welded vent message spam during movement
				if(COOLDOWN_FINISHED(src, welded_vent_message_cd))
					to_chat(src, span_warning("You can't crawl around a welded vent!"))
					COOLDOWN_START(src, welded_vent_message_cd, 2 SECONDS)
			return

	if (!(ventcrawl_target.vent_movement & VENTCRAWL_ENTRANCE_ALLOWED))
		if(provide_feedback)
			to_chat(src, span_warning("You can't enter this vent!"))
		return

	return TRUE

/// Handles the entrance and exit on ventcrawling
/mob/living/proc/handle_ventcrawl(obj/machinery/atmospherics/components/ventcrawl_target)
	if(!can_enter_vent(ventcrawl_target))
		return

	var/has_client = !isnull(client) // clientless mobs can do this too! this is just stored in case the client disconnects while we sleep in do_after.
	if(length(do_actions))
		return

	//Handle the exit here
	if(HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) && istype(loc, /obj/machinery/atmospherics))
		var/turf/loc_turf = get_turf(ventcrawl_target)
		if(loc_turf.density)
			to_chat(src, span_notice("You cannot climb out, the exit is blocked!"))
			return
		to_chat(src, span_notice("You begin climbing out from the ventilation system..."))
		if(has_client && isnull(client))
			return

		var/silent_crawl = FALSE
		if(isxeno(src))
			var/mob/living/carbon/xenomorph/xeno_user = src
			silent_crawl = xeno_user.xeno_caste.silent_vent_crawl

		if(!silent_crawl) //Xenos with silent crawl can silently enter/exit/move through vents.
			ventcrawl_target.visible_message(span_warning("You hear something squeezing through the ducts."))

		if(!do_after(src, 2 SECONDS, target = ventcrawl_target))
			return
		if(ventcrawl_target.welded) // in case it got welded during our sleep
			to_chat(src, span_warning("You can't crawl around a welded vent!"))
			return
		visible_message(span_notice("[src] scrambles out from the ventilation ducts!"), span_notice("You scramble out from the ventilation ducts."))
		forceMove(ventcrawl_target.loc)
		REMOVE_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)
		update_pipe_vision()
		if(!silent_crawl)
			playsound(src, SFX_ALIEN_VENTPASS, 35, TRUE)

	//Entrance here
	else
		var/datum/pipeline/vent_parent = ventcrawl_target.parents[1]
		if(vent_parent && (vent_parent.members.len))
			visible_message(span_notice("[src] begins climbing into the ventilation system..."), span_notice("You begin climbing into the ventilation system..."))
			if(!do_after(src, get_ventcrawl_speed(), target = ventcrawl_target, extra_checks = CALLBACK(src, PROC_REF(can_enter_vent), ventcrawl_target)))
				return
			if(has_client && isnull(client))
				return
			if(ventcrawl_target.welded) // in case it got welded during our sleep
				to_chat(src, span_warning("You can't crawl around a welded vent!"))
				return
			visible_message(span_notice("[src] scrambles into the ventilation ducts!"), span_notice("You climb into the ventilation ducts."))
			move_into_vent(ventcrawl_target)
		else
			to_chat(src, span_warning("This ventilation duct is not connected to anything!"))

/**
 * Moves living mob directly into the vent as a ventcrawler
 *
 * Arguments:
 * * ventcrawl_target - The vent into which we are moving the mob
 */
/mob/living/proc/move_into_vent(obj/machinery/atmospherics/components/ventcrawl_target)
	forceMove(ventcrawl_target)
	ADD_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)
	update_pipe_vision()
	log_game("[src] Crawled into the vent at [AREACOORD(ventcrawl_target)]")

/**
 * Everything related to pipe vision on ventcrawling is handled by update_pipe_vision().
 * Called on exit, entrance, and pipenet differences (e.g. moving to a new pipenet).
 * One important thing to note however is that the movement of the client's eye is handled by the relaymove() proc in /obj/machinery/atmospherics.
 * We move first and then call update. Dont flip this around
 */
/mob/living/proc/update_pipe_vision(full_refresh = FALSE)
	if(isnull(client))
		return

	update_sight()

	// Take away all the pipe images if we're not doing anything with em
	if(isnull(client) || !HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) || !istype(loc, /obj/machinery/atmospherics))
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
		LAZYNULL(pipes_shown)
		pipetracker = null
		for(var/atom/movable/screen/plane_master/lighting as anything in hud_used.get_true_plane_masters(LIGHTING_PLANE))
			lighting.remove_atom_colour(TEMPORARY_COLOR_PRIORITY, "#4d4d4d")
		for(var/atom/movable/screen/plane_master/pipecrawl as anything in hud_used.get_true_plane_masters(PIPECRAWL_IMAGES_PLANE))
			pipecrawl.hide_plane(src)
		return

	// We're gonna color the lighting plane to make it darker while ventcrawling, so things look nicer
	// This is a bit hacky but it makes the background darker, which has a nice effect
	for(var/atom/movable/screen/plane_master/lighting as anything in hud_used.get_true_plane_masters(LIGHTING_PLANE))
		lighting.add_atom_colour("#4d4d4d", TEMPORARY_COLOR_PRIORITY)

	for(var/atom/movable/screen/plane_master/pipecrawl as anything in hud_used.get_true_plane_masters(PIPECRAWL_IMAGES_PLANE))
		pipecrawl.unhide_plane(src)

	var/obj/machinery/atmospherics/current_location = loc
	var/list/our_pipenets = current_location.return_pipenets()

	// We on occasion want to do a full rebuild. this lets us do that
	if(full_refresh)
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
		LAZYCLEARLIST(pipes_shown)
		pipetracker = null

	if(!pipetracker)
		LAZYINITLIST(pipes_shown)
		pipetracker = new()

	var/turf/our_turf = get_turf(src)
	// We're getting the smallest "range" arg we can pass to the spatial grid and still get all the stuff we need
	// We preload a bit more then we need so movement looks ok
	var/list/view_range = getviewsize(client.view)
	pipetracker.set_bounds(view_range[1] + 1, view_range[2] + 1)

	var/list/entered_exited_pipes = pipetracker.recalculate_type_members(our_turf, SPATIAL_GRID_CONTENTS_TYPE_ATMOS)
	var/list/pipes_gained = entered_exited_pipes[1]
	var/list/pipes_lost = entered_exited_pipes[2]

	for(var/obj/machinery/atmospherics/pipenet_part as anything in pipes_lost)
		if(!pipenet_part.pipe_vision_img)
			continue
		client.images -= pipenet_part.pipe_vision_img
		pipes_shown -= pipenet_part.pipe_vision_img

	for(var/obj/machinery/atmospherics/pipenet_part as anything in pipes_gained)
		// If the machinery is not part of our net or is not meant to be seen, continue
		var/list/thier_pipenets = pipenet_part.return_pipenets()
		if(!length(thier_pipenets & our_pipenets))
			continue
		if(!(pipenet_part.vent_movement & VENTCRAWL_CAN_SEE))
			continue

		if(!pipenet_part.pipe_vision_img)
			var/turf/their_turf = get_turf(pipenet_part)
			pipenet_part.pipe_vision_img = image(pipenet_part, pipenet_part.loc, dir = pipenet_part.dir)
			SET_PLANE(pipenet_part.pipe_vision_img, PIPECRAWL_IMAGES_PLANE, their_turf)
		client.images += pipenet_part.pipe_vision_img
		pipes_shown += pipenet_part.pipe_vision_img

///Returns how quickly this mob can enter a vent
/mob/living/proc/get_ventcrawl_speed()
	return XENO_DEFAULT_VENT_ENTER_TIME

/mob/living/carbon/xenomorph/get_ventcrawl_speed()
	return xeno_caste.ventcrawl_speed
