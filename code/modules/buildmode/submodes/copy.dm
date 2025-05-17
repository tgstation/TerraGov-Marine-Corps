/datum/buildmode_mode/copy
	key = "copy"

	/// The reference target to copy
	var/atom/movable/stored

/datum/buildmode_mode/copy/Destroy()
	stored = null
	return ..()

/datum/buildmode_mode/copy/show_help(client/user)
	to_chat(user, custom_boxed_message("purple_box",\
		"[span_bold("Spawn a copy of selected target")] -> Left Mouse Button on obj/turf/mob\n\
		[span_bold("Select target to copy")] -> Right Mouse Button on obj/mob"))

/datum/buildmode_mode/copy/handle_click(client/user, params, obj/object)
	var/list/modifiers = params2list(params)

	if(!LAZYACCESS(modifiers, LEFT_CLICK))
		if(ismovable(object)) // No copying turfs for now.
			to_chat(user, span_notice("[object] set as template."))
			stored = object
		return

	if(!stored)
		to_chat(user, span_warning("Nothing set as a copy target."))
		return

	var/turf/T = get_turf(object)
	duplicate_object(stored, spawning_location = T)
	log_admin("Build Mode: [key_name(user)] copied [stored] to [AREACOORD(object)]")
