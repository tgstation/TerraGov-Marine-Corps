/atom/movable/screen/movable/pic_in_pic
	name = "Picture-in-picture"
	screen_loc = "CENTER"
	plane = FLOOR_PLANE
	var/atom/center
	var/width = 0
	var/height = 0
	var/list/shown_to = list()
	var/list/viewing_turfs = list()
	var/atom/movable/screen/component_button/button_x
	var/atom/movable/screen/component_button/button_expand
	var/atom/movable/screen/component_button/button_shrink
	var/atom/movable/screen/component_button/button_pop
	var/atom/movable/screen/map_view/popup_screen

	var/mutable_appearance/standard_background
	var/const/max_dimensions = 10

/atom/movable/screen/movable/pic_in_pic/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	make_backgrounds()
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(multiz_offset_increase))
	multiz_offset_increase(SSmapping)
	popup_screen = new
	popup_screen.generate_view("camera-[REF(src)]_map")

/atom/movable/screen/movable/pic_in_pic/proc/multiz_offset_increase(datum/source)
	SIGNAL_HANDLER
	SET_PLANE_W_SCALAR(src, initial(plane), SSmapping.max_plane_offset)

/atom/movable/screen/movable/pic_in_pic/Destroy()
	for(var/C in shown_to)
		unshow_to(C)
	QDEL_NULL(button_x)
	QDEL_NULL(button_shrink)
	QDEL_NULL(button_expand)
	QDEL_NULL(button_pop)
	QDEL_NULL(popup_screen)
	return ..()


/atom/movable/screen/movable/pic_in_pic/component_click(atom/movable/screen/component_button/component, params)
	if(component == button_x)
		usr.client?.close_popup("camera-[REF(src)]")
		qdel(src)
	else if(component == button_expand)
		set_view_size(width+1, height+1)
	else if(component == button_shrink)
		set_view_size(width-1, height-1)
	else if(component == button_pop)
		pop_to_screen()


/atom/movable/screen/movable/pic_in_pic/proc/make_backgrounds()
	standard_background = new /mutable_appearance()
	standard_background.icon = 'icons/misc/pic_in_pic.dmi'
	standard_background.icon_state = "background"
	standard_background.layer = LOWER_FLOOR_LAYER
	standard_background.appearance_flags = PIXEL_SCALE


/atom/movable/screen/movable/pic_in_pic/proc/add_buttons()
	var/static/mutable_appearance/move_tab
	if(!move_tab)
		move_tab = new /mutable_appearance()
		//all these properties are always the same, and since adding something to the overlay
		//list makes a copy, there is no reason to make a new one each call
		move_tab.icon = 'icons/misc/pic_in_pic.dmi'
		move_tab.icon_state = "move"
		move_tab.plane = HUD_PLANE
	var/matrix/M = matrix()
	M.Translate(0, (height + 0.25) * ICON_SIZE_Y)
	move_tab.transform = M
	add_overlay(move_tab)

	if(!button_x)
		button_x = new /atom/movable/screen/component_button(null, null, src)
		var/mutable_appearance/MA = new /mutable_appearance()
		MA.name = "close"
		MA.icon = 'icons/misc/pic_in_pic.dmi'
		MA.icon_state = "x"
		MA.plane = HUD_PLANE
		button_x.appearance = MA
	M = matrix()
	M.Translate((max(4, width) - 0.75) * ICON_SIZE_Y, (height + 0.25) * ICON_SIZE_Y)
	button_x.transform = M
	vis_contents += button_x

	if(!button_expand)
		button_expand = new /atom/movable/screen/component_button(null, null, src)
		var/mutable_appearance/MA = new /mutable_appearance()
		MA.name = "expand"
		MA.icon = 'icons/misc/pic_in_pic.dmi'
		MA.icon_state = "expand"
		MA.plane = HUD_PLANE
		button_expand.appearance = MA
	M = matrix()
	M.Translate(ICON_SIZE_Y, (height + 0.25) * ICON_SIZE_Y)
	button_expand.transform = M
	vis_contents += button_expand

	if(!button_shrink)
		button_shrink = new /atom/movable/screen/component_button(null, null, src)
		var/mutable_appearance/MA = new /mutable_appearance()
		MA.name = "shrink"
		MA.icon = 'icons/misc/pic_in_pic.dmi'
		MA.icon_state = "shrink"
		MA.plane = HUD_PLANE
		button_shrink.appearance = MA
	M = matrix()
	M.Translate(2 * ICON_SIZE_X, (height + 0.25) * ICON_SIZE_Y)
	button_shrink.transform = M
	vis_contents += button_shrink

	if(!button_pop)
		button_pop = new /atom/movable/screen/component_button(null, null, src)
		var/mutable_appearance/MA = new /mutable_appearance()
		MA.name = "pop"
		MA.icon = 'icons/misc/pic_in_pic.dmi'
		MA.icon_state = "pop"
		MA.plane = HUD_PLANE
		button_pop.appearance = MA
	M = matrix()
	M.Translate((max(4, width) - 0.75) * ICON_SIZE_X, (height + 0.25) * ICON_SIZE_Y + 16)
	button_pop.transform = M
	vis_contents += button_pop


/atom/movable/screen/movable/pic_in_pic/proc/add_background()
	if((width > 0) && (height > 0))
		var/matrix/M = matrix()
		M.Scale(width + 0.5, height + 0.5)
		M.Translate((width-1)/2 * ICON_SIZE_X, (height-1)/2 * ICON_SIZE_Y)
		standard_background.transform = M
		add_overlay(standard_background)


/atom/movable/screen/movable/pic_in_pic/proc/set_view_size(width, height, do_refresh = TRUE)
	width = clamp(width, 0, max_dimensions)
	height = clamp(height, 0, max_dimensions)
	src.width = width
	src.height = height

	y_off = (-height * ICON_SIZE_Y) - (ICON_SIZE_Y / 2)

	cut_overlays()
	add_background()
	add_buttons()
	if(do_refresh)
		refresh_view()


/atom/movable/screen/movable/pic_in_pic/proc/set_view_center(atom/target, do_refresh = TRUE)
	center = target
	if(do_refresh)
		refresh_view()


/atom/movable/screen/movable/pic_in_pic/proc/refresh_view()
	vis_contents -= viewing_turfs
	if(!width || !height)
		return
	viewing_turfs = get_visible_turfs()
	vis_contents += viewing_turfs
	if (popup_screen)
		popup_screen.vis_contents.Cut()
		popup_screen.vis_contents += viewing_turfs


/atom/movable/screen/movable/pic_in_pic/proc/get_visible_turfs()
	var/turf/T = get_turf(center)
	if(!T)
		return list()
	var/turf/lowerleft = locate(max(1, T.x - round(width/2)), max(1, T.y - round(height/2)), T.z)
	var/turf/upperright = locate(min(world.maxx, lowerleft.x + width - 1), min(world.maxy, lowerleft.y + height - 1), lowerleft.z)
	return block(lowerleft, upperright)


/atom/movable/screen/movable/pic_in_pic/proc/show_to(client/C)
	if(C)
		shown_to[C] = 1
		C.screen += src


/atom/movable/screen/movable/pic_in_pic/proc/unshow_to(client/C)
	if(C)
		shown_to -= C
		C.screen -= src

/atom/movable/screen/movable/pic_in_pic/proc/pop_to_screen()
	if(usr.client.screen_maps["camera-[REF(src)]_map"])
		return
	usr.client.setup_popup("camera-[REF(src)]", width, height, 2, "1984")
	popup_screen.display_to(usr)
	RegisterSignal(usr.client, COMSIG_POPUP_CLEARED, PROC_REF(on_popup_clear))

/atom/movable/screen/movable/pic_in_pic/proc/on_popup_clear(client/source, window)
	SIGNAL_HANDLER
	if (window == "camera-[REF(src)]")
		UnregisterSignal(usr.client, COMSIG_POPUP_CLEARED)
		popup_screen.hide_from(usr)
