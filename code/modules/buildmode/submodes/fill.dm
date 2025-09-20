#define FILL_WARNING_MIN 150

/datum/buildmode_mode/selection/fill
	key = "fill"

	/// Holder variable for the preview
	var/atom/objholder

/datum/buildmode_mode/selection/fill/show_help(client/user)
	to_chat(user, custom_boxed_message("purple_box",\
		"[span_bold("Select corner")] -> Left Mouse Button on turf/obj/mob\n\
		[span_bold("Delete region")] -> Left Mouse Button + Alt on turf/obj/mob\n\
		[span_bold("Select object type")] -> Right Mouse Button on buildmode button"))

/datum/buildmode_mode/selection/fill/change_settings(client/user)
	var/target_path = input(user, "Enter typepath:" ,"Typepath","/obj/structure/closet")
	objholder = text2path(target_path)
	if(!ispath(objholder))
		objholder = pick_closest_path(target_path)
		if(!objholder)
			tgui_alert(user, "No path has been selected.")
			return
		if(ispath(objholder, /area))
			objholder = null
			tgui_alert(user, "Area paths are not supported for this mode, use the area edit mode instead.")
			return
	BM.preview_selected_item(objholder)
	deselect_region()

/datum/buildmode_mode/selection/fill/handle_click(client/user, params, obj/object)
	if(isnull(objholder))
		to_chat(user, span_warning("Select an object type first."))
		deselect_region()
		return
	return ..()

/datum/buildmode_mode/selection/fill/handle_selected_area(client/user, params)
	var/list/modifiers = params2list(params)

	if(!LAZYACCESS(modifiers, LEFT_CLICK))
		return

	if(LAZYACCESS(modifiers, ALT_CLICK))
		var/list/deletion_area = block(get_turf(corner_a), get_turf(corner_b))
		for(var/turf/turf_to_delete AS in deletion_area)
			for(var/atom/movable/AM in turf_to_delete)
				qdel(AM)
			turf_to_delete.ScrapeAway()
		log_admin("Build Mode: [key_name(user)] deleted turfs from [AREACOORD(corner_a)] through [AREACOORD(corner_b)]")
		return

	var/selection_size = abs(corner_a.x - corner_b.x) * abs(corner_a.y - corner_b.y)

	if(selection_size > FILL_WARNING_MIN) // Confirm fill if the number of tiles in the selection is greater than FILL_WARNING_MIN
		var/choice = alert("Your selected area is [selection_size] tiles! Continue?", "Large Fill Confirmation", "Yes", "No")
		if(choice != "Yes")
			return

	for(var/turf/T in block(get_turf(corner_a),get_turf(corner_b)))
		if(ispath(objholder,/turf))
			T = T.ChangeTurf(objholder)
			T.setDir(BM.build_dir)
		else
			var/obj/A = new objholder(T)
			A.setDir(BM.build_dir)
	log_admin("Build Mode: [key_name(user)] with path [objholder], filled the region from [AREACOORD(corner_a)] through [AREACOORD(corner_b)]")

#undef FILL_WARNING_MIN
