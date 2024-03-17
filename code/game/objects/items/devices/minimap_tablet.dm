///A player needs to be unbanned from ALL these roles in order to be able to use the minimap drawing tool
GLOBAL_LIST_INIT(roles_allowed_minimap_draw, list(SQUAD_LEADER, CAPTAIN, FIELD_COMMANDER, STAFF_OFFICER))
GLOBAL_PROTECT(roles_allowed_minimap_draw)
/// range that we can remove labels when we click near them with the removal tool
#define LABEL_REMOVE_RANGE 20
#define MINIMAP_DRAW_OFFSET 8

/obj/item/minimap_tablet
	name = "minimap tablet"
	desc = "A drawing tablet with included touch pen. While high command may treat you like a child, being able to plan effectively might be a worthy trade."
	icon = 'icons/Marine/marine-navigation.dmi'
	icon_state = "req_tablet_off"
	/// List of references to the tools we will be using to shape what the map looks like
	var/list/atom/movable/screen/drawing_tools = list(
		/atom/movable/screen/minimap_tool/draw_tool/red,
		/atom/movable/screen/minimap_tool/draw_tool/yellow,
		/atom/movable/screen/minimap_tool/draw_tool/purple,
		/atom/movable/screen/minimap_tool/draw_tool/blue,
		/atom/movable/screen/minimap_tool/draw_tool/erase,
		/atom/movable/screen/minimap_tool/label,
		/atom/movable/screen/minimap_tool/clear,
	)
	/// the Zlevel that this tablet will be allowed to edit
	var/editing_z = 2
	/// The minimap flag we will be allowing to edit
	var/minimap_flag = MINIMAP_FLAG_MARINE

/obj/item/minimap_tablet/Initialize(mapload)
	. = ..()
	var/list/atom/movable/screen/actions = list()
	for(var/path in drawing_tools)
		actions += new path(null, editing_z, minimap_flag)
	drawing_tools = actions

/obj/item/minimap_tablet/Destroy()
	. = ..()
	QDEL_LIST(drawing_tools)

/obj/item/minimap_tablet/examine(mob/user)
	. = ..()
	. += span_warning("Note that abuse may result in a command role ban.")

/obj/item/minimap_tablet/attack_self(mob/user)
	. = ..()
	if(!user.client)
		return
	if(user.skills.getRating(SKILL_LEADERSHIP) < SKILL_LEAD_EXPERT)
		user.balloon_alert(user, "Can't use that!")
		return
	if(is_banned_from(user.client.ckey, GLOB.roles_allowed_minimap_draw))
		to_chat(user, span_boldwarning("You have been banned from a command role. You may not use [src] until the ban has been lifted."))
		return
	var/atom/movable/screen/minimap/mini = SSminimaps.fetch_minimap_object(editing_z, minimap_flag)
	if(locate(mini) in user.client.screen)
		close_tablet(src, user)
		return
	icon_state = "req_tablet_on"
	user.client.screen += mini
	user.client.screen += drawing_tools
	RegisterSignal(src, COMSIG_ITEM_UNEQUIPPED, PROC_REF(close_tablet))

///Handles closing the tablet, including removing all on-screen indicators and similar
/obj/item/minimap_tablet/proc/close_tablet(datum/source, mob/unequipper, slot)
	SIGNAL_HANDLER
	icon_state = initial(icon_state)
	unequipper.client.screen -= SSminimaps.fetch_minimap_object(editing_z, minimap_flag)
	unequipper.client.screen -= drawing_tools
	unequipper.client.mouse_pointer_icon = null
	UnregisterSignal(src, COMSIG_ITEM_UNEQUIPPED)
	for(var/atom/movable/screen/minimap_tool/tool AS in drawing_tools)
		tool.UnregisterSignal(unequipper, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP))


/atom/movable/screen/minimap_tool
	icon = 'icons/UI_icons/minimap_buttons.dmi'
	///x offset of the minimap icon for this zlevel. mostly used for shorthand
	var/x_offset
	///y offset of the minimap icon for this zlevel. mostly used for shorthand
	var/y_offset
	///zlevel that this minimap tool applies to and which it will be drawing on
	var/zlevel
	/// active mouse icon when the tool is selected
	var/active_mouse_icon
	///one minimap flag that this tool will be drawing on
	var/minimap_flag
	/// reference to the icon we are manipulating when drawing, fetched during initialize
	var/image/drawn_image

/atom/movable/screen/minimap_tool/Initialize(mapload, zlevel, minimap_flag)
	. = ..()
	src.minimap_flag = minimap_flag
	src.zlevel = zlevel
	if(SSminimaps.initialized)
		set_zlevel(zlevel, minimap_flag)
		return
	LAZYADDASSOC(SSminimaps.earlyadds, "[zlevel]", CALLBACK(src, PROC_REF(set_zlevel), zlevel, minimap_flag))

///Setter for the offsets of the x and y of drawing based on the input z, and the drawn_image
/atom/movable/screen/minimap_tool/proc/set_zlevel(zlevel, minimap_flag)
	x_offset = SSminimaps.minimaps_by_z["[zlevel]"].x_offset
	y_offset = SSminimaps.minimaps_by_z["[zlevel]"].y_offset
	drawn_image = SSminimaps.get_drawing_image(zlevel, minimap_flag)

/atom/movable/screen/minimap_tool/MouseEntered(location, control, params)
	. = ..()
	add_filter("mouseover", 1, outline_filter(1, COLOR_LIME))
	if(desc)
		openToolTip(usr, src, params, title = name, content = desc)

/atom/movable/screen/minimap_tool/MouseExited(location, control, params)
	. = ..()
	remove_filter("mouseover")
	if(desc)
		closeToolTip(usr)

/atom/movable/screen/minimap_tool/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers[BUTTON] == LEFT_CLICK)
		RegisterSignal(usr, COMSIG_MOB_MOUSEDOWN, PROC_REF(on_mousedown))
		usr.client.mouse_pointer_icon = active_mouse_icon

/**
 * handles actions when the mouse is held down while the tool is active.
 * returns COMSIG_MOB_CLICK_CANCELED to continue handling, NONE to cancel
 */
/atom/movable/screen/minimap_tool/proc/on_mousedown(mob/source, atom/object, location, control, params)
	SIGNAL_HANDLER
	if(!(src in source.client.screen))
		UnregisterSignal(source, COMSIG_MOB_MOUSEDOWN)
		source.client.mouse_pointer_icon = null
		return NONE
	if(istype(object, /atom/movable/screen/minimap_tool))
		UnregisterSignal(usr, COMSIG_MOB_MOUSEDOWN)
		usr.client.mouse_pointer_icon = null
		return NONE
	return COMSIG_MOB_CLICK_CANCELED

/atom/movable/screen/minimap_tool/draw_tool
	icon_state = "draw"
	desc = "Draw using a color. Drag to draw a line, right click to place a dot. Right click this button to unselect."
	// color that this draw tool will be drawing in
	color = COLOR_PINK
	var/list/last_drawn
	///temporary existing list used to calculate a line between the start of a click and the end of a click
	var/list/starting_coords

/atom/movable/screen/minimap_tool/draw_tool/Click(location, control, params)
	. = ..()
	var/list/modifiers = params2list(params)
	if(modifiers[BUTTON] == RIGHT_CLICK && last_drawn)
		last_drawn += list(null)
		draw_line(arglist(last_drawn))
		last_drawn = null
		log_minimap_drawing("[key_name(usr)] undid the last [color] line")

/atom/movable/screen/minimap_tool/draw_tool/on_mousedown(mob/source, atom/object, location, control, params)
	. = ..()
	if(!.)
		return
	var/list/modifiers = params2list(params)
	var/list/pixel_coords = params2screenpixel(modifiers["screen-loc"])
	if(modifiers[BUTTON] == RIGHT_CLICK)
		var/icon/mona_lisa = icon(drawn_image.icon)
		pixel_coords = list(pixel_coords[1]-MINIMAP_DRAW_OFFSET, pixel_coords[2]+MINIMAP_DRAW_OFFSET)
		mona_lisa.DrawBox(color, pixel_coords[1], pixel_coords[2], ++pixel_coords[1], ++pixel_coords[2])
		drawn_image.icon = mona_lisa
		log_minimap_drawing("[key_name(source)] has made a dot at [pixel_coords[1]/2], [pixel_coords[2]/2]")
		return COMSIG_MOB_CLICK_CANCELED
	starting_coords = pixel_coords
	RegisterSignal(source, COMSIG_MOB_MOUSEUP, PROC_REF(on_mouseup))
	return COMSIG_MOB_CLICK_CANCELED

///Called when the mouse is released again to finish the drag-draw
/atom/movable/screen/minimap_tool/draw_tool/proc/on_mouseup(mob/living/source, atom/object, location, control, params)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOB_MOUSEUP)
	var/list/modifiers = params2list(params)
	var/list/end_coords = params2screenpixel(modifiers["screen-loc"])
	draw_line(starting_coords, end_coords)
	last_drawn = list(starting_coords, end_coords)
	log_minimap_drawing("[key_name(usr)] drew a [color] line from [starting_coords[1]], [starting_coords[2]] to [end_coords[1]], [end_coords[2]]")

/// proc for drawing a line from list(startx, starty) to list(endx, endy) on the screen. yes this is aa ripoff of [/proc/getline]
/atom/movable/screen/minimap_tool/draw_tool/proc/draw_line(list/start_coords, list/end_coords, draw_color = color)
	// converts these into the unscaled minimap version so we have to do less calculating
	var/halved_offset = MINIMAP_DRAW_OFFSET/2
	var/start_x = FLOOR(start_coords[1]/2, 1) - halved_offset
	var/start_y = FLOOR(start_coords[2]/2, 1) + halved_offset
	var/end_x = FLOOR(end_coords[1]/2, 1) - halved_offset
	var/end_y = FLOOR(end_coords[2]/2, 1) + halved_offset
	var/icon/mona_lisa = icon(drawn_image.icon)

	//special case 1, straight line
	if(start_x == end_x)
		mona_lisa.DrawBox(draw_color, start_x*2, start_y*2, start_x*2 + 1, end_y*2 + 1)
		drawn_image.icon = mona_lisa
		return
	if(start_y == end_y)
		drawn_image.icon = mona_lisa
		mona_lisa.DrawBox(draw_color, start_x*2, start_y*2, end_x*2 + 1, start_y*2 + 1)
		return

	mona_lisa.DrawBox(draw_color, start_x*2, start_y*2, start_x*2 + 1, start_y*2 + 1)

	var/abs_dx = abs(end_x - start_x)
	var/abs_dy = abs(end_y - start_y)
	var/sign_dx = SIGN(end_x - start_x)
	var/sign_dy = SIGN(end_y - start_y)

	//special case 2, perfectly diagonal line
	if(abs_dx == abs_dy)
		for(var/j = 1 to abs_dx)
			start_x += sign_dx
			start_y += sign_dy
			mona_lisa.DrawBox(draw_color, start_x*2, start_y*2, start_x*2 + 1, start_y*2 + 1)
		drawn_image.icon = mona_lisa
		return

	/*x_error and y_error represents how far we are from the ideal line.
	Initialized so that we will check these errors against 0, instead of 0.5 * abs_(dx/dy)*/
	//We multiply every check by the line slope denominator so that we only handles integers
	if(abs_dx > abs_dy)
		var/y_error = -(abs_dx >> 1)
		var/steps = abs_dx
		while(steps--)
			y_error += abs_dy
			if(y_error > 0)
				y_error -= abs_dx
				start_y += sign_dy
			start_x += sign_dx
			mona_lisa.DrawBox(draw_color, start_x*2, start_y*2, start_x*2 + 1, start_y*2 + 1)
	else
		var/x_error = -(abs_dy >> 1)
		var/steps = abs_dy
		while(steps--)
			x_error += abs_dx
			if(x_error > 0)
				x_error -= abs_dy
				start_x += sign_dx
			start_y += sign_dy
			mona_lisa.DrawBox(draw_color, start_x*2, start_y*2, start_x*2 + 1, start_y*2 + 1)
	drawn_image.icon = mona_lisa

/atom/movable/screen/minimap_tool/draw_tool/red
	screen_loc = "16,14"
	active_mouse_icon = 'icons/UI_Icons/minimap_mouse/draw_red.dmi'
	color = MINIMAP_DRAWING_RED

/atom/movable/screen/minimap_tool/draw_tool/yellow
	screen_loc = "16,13"
	active_mouse_icon = 'icons/UI_Icons/minimap_mouse/draw_yellow.dmi'
	color = MINIMAP_DRAWING_YELLOW

/atom/movable/screen/minimap_tool/draw_tool/purple
	screen_loc = "16,12"
	active_mouse_icon = 'icons/UI_Icons/minimap_mouse/draw_purple.dmi'
	color = MINIMAP_DRAWING_PURPLE

/atom/movable/screen/minimap_tool/draw_tool/blue
	screen_loc = "16,11"
	active_mouse_icon = 'icons/UI_Icons/minimap_mouse/draw_blue.dmi'
	color = MINIMAP_DRAWING_BLUE

/atom/movable/screen/minimap_tool/draw_tool/erase
	icon_state = "erase"
	desc = "Drag to erase a line, right click to erase a dot. Right click this button to unselect."
	active_mouse_icon = 'icons/UI_Icons/minimap_mouse/draw_erase.dmi'
	screen_loc = "16,10"
	color = null

/atom/movable/screen/minimap_tool/label
	icon_state = "label"
	desc = "Click to place a label. Rightclick a label to remove it. Right click this button to remove all labels."
	active_mouse_icon = 'icons/UI_Icons/minimap_mouse/label.dmi'
	screen_loc = "16,8"
	/// List of turfs that have labels attached to them. kept around so it can be cleared
	var/list/turf/labelled_turfs = list()

/atom/movable/screen/minimap_tool/label/Click(location, control, params)
	. = ..()
	var/list/modifiers = params2list(params)
	if(modifiers[BUTTON] == RIGHT_CLICK)
		clear_labels(usr)

///Clears all labels and logs who did it
/atom/movable/screen/minimap_tool/label/proc/clear_labels(mob/user)
	log_minimap_drawing("[key_name(usr)] has cleared current labels")
	for(var/turf/label AS in labelled_turfs)
		SSminimaps.remove_marker(label)

/atom/movable/screen/minimap_tool/label/on_mousedown(mob/source, atom/object, location, control, params)
	. = ..()
	if(!.)
		return
	INVOKE_ASYNC(src, PROC_REF(async_mousedown), source, object, location, control, params)
	return COMSIG_MOB_CLICK_CANCELED

///async mousedown for the actual label placement handling
/atom/movable/screen/minimap_tool/label/proc/async_mousedown(mob/source, atom/object, location, control, params)
	// this is really [/atom/movable/screen/minimap/proc/get_coords_from_click] copypaste since we
	// want to also cancel the click if they click src and I cant be bothered to make it even more generic rn
	var/list/modifiers = params2list(params)
	var/list/pixel_coords = params2screenpixel(modifiers["screen-loc"])
	var/x = (pixel_coords[1] - x_offset - MINIMAP_DRAW_OFFSET) / 2
	var/y = (pixel_coords[2] - y_offset + MINIMAP_DRAW_OFFSET) / 2
	var/c_x = clamp(CEILING(x, 1), 1, world.maxx)
	var/c_y = clamp(CEILING(y, 1), 1, world.maxy)
	var/turf/target = locate(c_x, c_y, zlevel)
	if(modifiers[BUTTON] == RIGHT_CLICK)
		var/curr_dist
		var/turf/nearest
		for(var/turf/label AS in labelled_turfs)
			var/dist = get_dist_euclide(label, target)
			if(dist > LABEL_REMOVE_RANGE)
				continue
			if(!curr_dist || curr_dist > dist)
				curr_dist = dist
				nearest = label
		if(nearest)
			SSminimaps.remove_marker(nearest)
		return
	var/label_text = MAPTEXT(tgui_input_text(source, title = "Label Name", max_length = 35))
	var/filter_result = CAN_BYPASS_FILTER(user) ? null : is_ic_filtered(label_text)
	if(filter_result)
		to_chat(source, span_warning("That label contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[label_text]\"</span>"))
		SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		REPORT_CHAT_FILTER_TO_USER(src, filter_result)
		log_filter("IC", label_text, filter_result)
		return
	if(!label_text)
		return
	var/atom/movable/screen/minimap/mini = SSminimaps.fetch_minimap_object(zlevel, minimap_flag)
	if(!locate(mini) in source.client?.screen)
		return

	var/mutable_appearance/textbox = new
	textbox.maptext_x = 5
	textbox.maptext_y = 5
	textbox.maptext_width = 64
	textbox.maptext = label_text

	labelled_turfs += target
	var/image/blip = image('icons/UI_icons/map_blips.dmi', null, "label")
	blip.overlays += textbox
	SSminimaps.add_marker(target, minimap_flag, blip)
	log_minimap_drawing("[key_name(source)] has added the label [label_text] at [c_x], [c_y]")

/atom/movable/screen/minimap_tool/clear
	icon_state = "clear"
	desc = "Remove all current labels and drawings."
	screen_loc = "16,9"

/atom/movable/screen/minimap_tool/clear/Click()
	drawn_image.icon = icon('icons/UI_icons/minimap.dmi')
	var/atom/movable/screen/minimap_tool/label/labels = locate() in usr.client?.screen
	labels?.clear_labels(usr)
	log_minimap_drawing("[key_name(usr)] has cleared the minimap")
