/datum/buildmode_mode/throwing
	key = "throw"

	/// The atom currently selected for being thrown
	var/atom/movable/throw_atom

/datum/buildmode_mode/throwing/Destroy()
	throw_atom = null
	return ..()

/datum/buildmode_mode/throwing/show_help(client/user)
	to_chat(user, custom_boxed_message("purple_box",\
		"[span_bold("Select")] -> Left Mouse Button on turf/obj/mob\n\
		[span_bold("Throw")] -> Right Mouse Button on turf/obj/mob"))

/datum/buildmode_mode/throwing/handle_click(client/user, params, obj/object)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(isturf(object))
			return
		throw_atom = object
		to_chat(user, "Selected object '[throw_atom]'")
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(throw_atom)
			throw_atom.throw_at(object, 10, 1, user.mob)
			log_admin("Build Mode: [key_name(user)] threw [throw_atom] at [object] ([AREACOORD(object)])")
