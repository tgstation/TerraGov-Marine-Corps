/datum/buildmode_mode/selection/area_edit
	key = "areaedit"

	/// Holder variable for our currently selected area
	var/area/selected_area
	/// Holder variable for the image that is applied overlay on all of selected_area
	var/image/areaimage

/datum/buildmode_mode/selection/area_edit/New()
	areaimage = image('icons/turf/areas.dmi', null, "blue_selection")
	return ..()

/datum/buildmode_mode/selection/area_edit/show_help(client/user)
	to_chat(user, custom_boxed_message("purple_box",\
		"[span_bold("Select corner")] -> Left Mouse Button on obj/turf/mob\n\
		[span_bold("Pick area to expand")] -> Right Mouse Button on obj/turf/mob\n\
		[span_bold("Select area type to paint")] -> Right Mouse Button on buildmode button"))

/datum/buildmode_mode/selection/area_edit/enter_mode(datum/buildmode/BM)
	BM.holder.images += areaimage

/datum/buildmode_mode/selection/area_edit/exit_mode(datum/buildmode/BM)
	areaimage.loc = null // de-color the area
	BM.holder.images -= areaimage

/datum/buildmode_mode/selection/area_edit/Destroy()
	QDEL_NULL(areaimage)
	selected_area = null
	return ..()

/datum/buildmode_mode/selection/area_edit/change_settings(client/user)
	var/target_path = input(user, "Enter typepath:", "Typepath", "/area")
	var/area/chosen_area = pick_closest_path(target_path, make_types_fancy(subtypesof(/area)))
	if(!ispath(chosen_area, /area))
		to_chat(user, span_warning("Invalid area type."))
		return

	var/areaname = input(user, "Enter area name (leave \"Area\" for default name of the type):", "Area name", "Area")
	if(!length(areaname))
		return

	selected_area = new chosen_area
	selected_area.power_equip = 0
	selected_area.power_light = 0
	selected_area.power_environ = 0
	selected_area.always_unpowered = 0
	selected_area.name = (areaname == "Area" ? initial(chosen_area.name) : areaname)
	areaimage.loc = selected_area // color our area

/datum/buildmode_mode/selection/area_edit/handle_click(client/user, params, object)
	var/list/modifiers = params2list(params)

	if(!LAZYACCESS(modifiers, RIGHT_CLICK))
		return ..()

	var/turf/T = get_turf(object)
	selected_area = get_area(T)
	areaimage.loc = selected_area // color our area
	to_chat(user, span_notice("Succesfully selected area of type [selected_area.type]."))

/datum/buildmode_mode/selection/area_edit/handle_selected_area(client/user, params)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		var/choice = tgui_alert(user, "Are you sure you want to fill area?", "Area Fill Confirmation", list("Yes", "No"))
		if(choice != "Yes")
			return
		for(var/turf/T in block(get_turf(corner_a), get_turf(corner_b)))
			selected_area.contents.Add(T)
		to_chat(user, span_notice("Success."))
		log_admin("Build Mode: [key_name(user)] set the area of the region from [AREACOORD(corner_a)] through [AREACOORD(corner_b)] to [selected_area].")
