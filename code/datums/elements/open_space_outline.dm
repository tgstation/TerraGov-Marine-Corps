/// Element for turfs that shows living mobs with clients a outline around the turfs next to them that they would fall down from, given by open space to itself and the turfs around it
/datum/element/open_space_outline
	///Assoc list of viewer to an assoc list of turf to the outline image they are being shown
	var/list/shown_outlines = list()

/datum/element/open_space_outline/Attach(datum/target)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

/datum/element/open_space_outline/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
	for(var/mob/living/viewer in source)
		clear_outlines(viewer)

///Shows the outlines to living clients that step on us
/datum/element/open_space_outline/proc/on_entered(turf/source, atom/movable/arrived, atom/old_loc, list/old_locs)
	SIGNAL_HANDLER
	if(isliving(arrived))
		update_outlines(arrived)

///Hides the outlines to the client that stepped off us
/datum/element/open_space_outline/proc/on_exited(turf/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	if(shown_outlines[gone])
		update_outlines(gone)

///Shows viewer the outlines of the open space they are next to, and hides the ones they are no longer next to
/datum/element/open_space_outline/proc/update_outlines(mob/living/viewer)
	var/client/viewer_client = viewer.client
	var/list/turf/open_turfs = list()
	if(isturf(viewer.loc) && viewer_client?.prefs?.multiz_edge_outline && !istype(viewer_client.eye, /mob/camera))
		for(var/turf/nearby_turf AS in RANGE_TURFS(MULTIZ_EDGE_OUTLINE_RANGE, viewer.loc))
			if(nearby_turf.can_fall_through())
				open_turfs += nearby_turf

	var/list/outlines = shown_outlines[viewer]
	for(var/turf/outlined_turf AS in outlines)
		if(outlined_turf in open_turfs)
			continue
		var/image/old_outline = outlines[outlined_turf]
		outlines -= outlined_turf
		animate(old_outline, alpha = 0, time = MULTIZ_EDGE_OUTLINE_FADE_TIME)
		addtimer(CALLBACK(src, PROC_REF(remove_outline), old_outline, viewer.canon_client), MULTIZ_EDGE_OUTLINE_FADE_TIME)

	if(!length(open_turfs))
		clear_outlines(viewer)
		return
	if(!outlines)
		outlines = list()
		shown_outlines[viewer] = outlines
		RegisterSignals(viewer, list(COMSIG_MOB_LOGOUT, COMSIG_QDELETING), PROC_REF(clear_outlines))

	for(var/turf/open_turf AS in open_turfs)
		if(outlines[open_turf])
			continue
		var/image/outline = image('icons/effects/open_space_outline.dmi', open_turf, "blank", ABOVE_WEEDS_LAYER)
		//only the sides that border something that can be stood on
		for(var/direction in GLOB.cardinals)
			var/turf/side_turf = get_step(open_turf, direction)
			if(side_turf?.can_fall_through())
				continue
			outline.overlays += image('icons/effects/open_space_outline.dmi', "edge_[dir2text(direction)]")
		SET_PLANE_EXPLICIT(outline, FLOOR_PLANE, open_turf)
		outline.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		outline.alpha = 0
		outlines[open_turf] = outline
		viewer_client.images += outline
		animate(outline, alpha = 255, time = MULTIZ_EDGE_OUTLINE_FADE_TIME)

///Removes an outline from a client once it has faded out
/datum/element/open_space_outline/proc/remove_outline(image/outline, client/viewer_client)
	viewer_client?.images -= outline

///Removes every outline viewer is being shown and stops keeping track of them
/datum/element/open_space_outline/proc/clear_outlines(mob/living/viewer)
	SIGNAL_HANDLER
	var/list/outlines = shown_outlines[viewer]
	if(!outlines)
		return
	for(var/turf/outlined_turf AS in outlines)
		viewer.canon_client?.images -= outlines[outlined_turf]
	shown_outlines -= viewer
	UnregisterSignal(viewer, list(COMSIG_MOB_LOGOUT, COMSIG_QDELETING))

///Updates the open the open-space outlines that are shown, use when something other than moving changes visibility
/mob/living/proc/update_open_space_outlines()
	var/datum/element/open_space_outline/outline_element = SSdcs.GetElement(list(/datum/element/open_space_outline))
	outline_element.update_outlines(src)
