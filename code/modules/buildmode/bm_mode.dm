/datum/buildmode_mode
	/// This variable determines the name and icon state of a build mode button
	var/key = "yell at coders"
	/// The holder for the master build mode datum itself
	var/datum/buildmode/BM

/datum/buildmode_mode/New(datum/buildmode/BM)
	src.BM = BM
	return ..()

/datum/buildmode_mode/Destroy()
	BM = null
	return ..()

/// Called upon the user entering build mode, for additional behaviour on the subtype.
/datum/buildmode_mode/proc/enter_mode(datum/buildmode/BM)
	return

/// Called upon the user exiting build mode, for additional behaviour on the subtype.
/datum/buildmode_mode/proc/exit_mode(datum/buildmode/BM)
	return

/// Returns the icon_state the build mode button should have, because we don't have a button type for every type of build mode.
/datum/buildmode_mode/proc/get_button_iconstate()
	return "buildmode_[key]"

/// Called when the user clicks the question mark button, prints usage instructions to chat.
/datum/buildmode_mode/proc/show_help(client/user)
	CRASH("No help defined, yell at a coder")

/// Allows us to change the way the selected build mode functions.
/datum/buildmode_mode/proc/change_settings(client/user)
	to_chat(user, span_warning("There is no configuration available for this mode"))

/// Called whenever the user clicks on something with build mode active.
/datum/buildmode_mode/proc/handle_click(client/user, params, object)
	return

#define AREASELECT_CORNER_A "corner A"
#define AREASELECT_CORNER_B "corner B"

/datum/buildmode_mode/selection
	/// Holds a list of preview overlay images
	var/list/preview = list()
	/// The first corner of the selection
	var/turf/corner_a
	/// The second corner of the selection
	var/turf/corner_b

/datum/buildmode_mode/selection/Destroy()
	corner_a = null
	corner_b = null
	BM.holder.images -= preview
	QDEL_LIST_NULL(preview)
	return ..()

/datum/buildmode_mode/selection/handle_click(client/user, params, object)
	var/list/modifiers = params2list(params)
	if(!LAZYACCESS(modifiers, LEFT_CLICK))
		to_chat(user, span_notice("Region selection canceled!"))
		deselect_region()
		return

	if(!corner_a)
		corner_a = apply_overlay_image(get_turf(object), AREASELECT_CORNER_A)
		return

	if(corner_a && !corner_b)
		corner_b = apply_overlay_image(get_turf(object), AREASELECT_CORNER_B)
		to_chat(user, span_boldwarning("Region selected, if you're happy with your selection left click again, otherwise right click."))
		return

	handle_selected_area(user, params)
	deselect_region()

/// Applies the overlay image over the tile passed as an argument. Returns target_turf for convinience.
/datum/buildmode_mode/selection/proc/apply_overlay_image(turf/target_turf, corner_to_select)
	BM.holder.images -= preview
	var/image/overlay_image
	switch(corner_to_select)
		if(AREASELECT_CORNER_A)
			overlay_image = image('icons/turf/overlays.dmi', target_turf, "greenOverlay")
		if(AREASELECT_CORNER_B)
			overlay_image = image('icons/turf/overlays.dmi', target_turf, "blueOverlay")

	SET_PLANE(overlay_image, ABOVE_LIGHTING_PLANE, target_turf)
	preview += overlay_image
	BM.holder.images += preview
	return target_turf

/// Does everything associated with deselecting
/datum/buildmode_mode/selection/proc/deselect_region()
	BM.holder.images -= preview
	preview.Cut()
	corner_a = null
	corner_b = null

/// Used for determining what to do with the selected area after both corners have been selected
/datum/buildmode_mode/selection/proc/handle_selected_area(client/user, params)
	return

#undef AREASELECT_CORNER_A
#undef AREASELECT_CORNER_B
