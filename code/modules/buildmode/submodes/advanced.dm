/datum/buildmode_mode/advanced
	key = "advanced"

	/// The type selected for building
	var/atom/selected_type

/datum/buildmode_mode/advanced/show_help(client/user)
	to_chat(user, custom_boxed_message("purple_box",\
		"[span_bold("Set object type")] -> Right Mouse Button on buildmode button\n\
		[span_bold("Copy object type")] -> Left Mouse Button + Alt on turf/obj\n\
		[span_bold("Place objects")] -> Left Mouse Button on turf/obj\n\
		[span_bold("Delete objects")] -> Right Mouse Button\n\
		\n\
		Use the button in the upper left corner to change the direction of built objects."))

/datum/buildmode_mode/advanced/change_settings(client/user)
	var/target_path = input(user, "Enter typepath:", "Typepath", "/obj/structure/closet")
	selected_type = text2path(target_path)
	if(!ispath(selected_type))
		selected_type = pick_closest_path(target_path)
		if(!selected_type)
			tgui_alert(user, "No path was selected")
			return
		else if(ispath(selected_type, /area))
			selected_type = null
			tgui_alert(user, "That path is not allowed.")
			return
	BM.preview_selected_item(selected_type)

/datum/buildmode_mode/advanced/handle_click(client/user, params, obj/object)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(LAZYACCESS(modifiers, ALT_CLICK))
			if(istype(object, /turf) || istype(object, /obj) || istype(object, /mob))
				selected_type = object.type
				to_chat(user, span_notice("[initial(object.name)] ([object.type]) selected."))
				BM.preview_selected_item(selected_type)
				return
			to_chat(user, span_notice("[initial(object.name)] is not a turf, object, or mob! Please select again."))
			return

		if(isnull(selected_type))
			to_chat(user, span_warning("Select object type first."))
			return

		if(ispath(selected_type, /turf))
			var/turf/T = get_turf(object)
			if(!T)
				return
			log_admin("Build Mode: [key_name(user)] modified [T] in [AREACOORD(object)] to [selected_type]")
			T = T.ChangeTurf(selected_type)
			T.setDir(BM.build_dir)
			return

		if(ispath(selected_type, /obj/effect/turf_decal))
			var/turf/T = get_turf(object)
			//todo, decal element
			log_admin("Build Mode: [key_name(user)] in [AREACOORD(object)] added a [initial(selected_type.name)] decal with dir [BM.build_dir] to [T]")
			return

		var/obj/A = new selected_type(get_turf(object))
		A.setDir(BM.build_dir)
		log_admin("Build Mode: [key_name(user)] modified [A]'s [COORD(A)] dir to [BM.build_dir]")

		return

	if(isturf(object))
		var/turf/T = object
		T.ScrapeAway()
	else if(isobj(object))
		qdel(object)

	log_admin("Build Mode: [key_name(user)] deleted [object] at [AREACOORD(object)]")
	to_chat(user, span_notice("Success."))
