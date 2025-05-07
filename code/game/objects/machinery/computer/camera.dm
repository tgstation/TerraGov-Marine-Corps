#define DEFAULT_MAP_SIZE 15

/obj/machinery/computer/camera
	name = "security camera console"
	desc = "Used to access the various cameras on the station."
	icon_state = "computer_small"
	screen_overlay = "cameras"
	broken_icon = "computer_small_red_broken"
	circuit = /obj/item/circuitboard/computer/security
	light_color = COLOR_RED

	interaction_flags = INTERACT_MACHINE_TGUI

	var/list/network = list("marinemainship", "dropship1", "dropship2")
	var/obj/machinery/camera/active_camera
	var/list/concurrent_users = list()

	// Stuff needed to render the map
	var/const/default_map_size = 15
	var/atom/movable/screen/map_view/camera/cam_screen

/obj/machinery/computer/camera/Initialize(mapload)
	. = ..()
	// Map name has to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	// I wasted 6 hours on this. :agony:
	var/map_name = "camera_console_[REF(src)]_map"
	// Convert networks to lowercase
	for(var/i in network)
		network -= i
		network += lowertext(i)
	// Initialize map objects

	cam_screen = new
	cam_screen.generate_view(map_name)

/obj/machinery/computer/camera/Destroy()
	QDEL_NULL(cam_screen)
	return ..()

/obj/machinery/computer/camera/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	for(var/i in network)
		network -= i
		network += "[idnum][i]"

/obj/machinery/computer/camera/ui_interact(mob/user, datum/tgui/ui)
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui)
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		cam_screen.show_camera_static()
	if(!ui)
		var/user_ref = REF(user)
		var/is_living = isliving(user)
		// Ghosts shouldn't count towards concurrent users, which produces
		// an audible terminal_on click.
		if(is_living)
			concurrent_users += user_ref
		// Turn on the console
		if(length(concurrent_users) == 1 && is_living)
			playsound(src, 'sound/machines/terminal_on.ogg', 25, FALSE)
			use_power(active_power_usage)
		// Open UI
		ui = new(user, src, "CameraConsole", name)
		ui.open()
		// Register map objects
		cam_screen.display_to(user, ui.window)

/obj/item/hud_tablet/ui_close(mob/user)
	. = ..()
	// Unregister map objects
	cam_screen.hide_from(user)

/obj/machinery/computer/camera/ui_data()
	var/list/data = list()
	data["network"] = network
	data["activeCamera"] = null
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			status = active_camera.status,
		)
	return data

/obj/machinery/computer/camera/ui_static_data()
	var/list/data = list()
	data["mapRef"] = cam_screen.assigned_map
	var/list/cameras = get_available_cameras()
	data["cameras"] = list()
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		data["cameras"] += list(list(
			name = C.c_tag,
		))
	return data

/obj/machinery/computer/camera/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(action == "switch_camera")
		var/c_tag = params["name"]
		var/list/cameras = get_available_cameras()
		var/obj/machinery/camera/C = cameras[c_tag]
		active_camera = C
		playsound(src, SFX_TERMINAL_TYPE, 25, FALSE)

		// Show static if can't use the camera
		if(!active_camera?.can_use())
			cam_screen.show_camera_static()
			return TRUE

		var/list/visible_turfs = list()
		for(var/turf/T in view(C.view_range, C))
			visible_turfs += T

		var/list/bbox = get_bbox_of_atoms(visible_turfs)
		var/size_x = bbox[3] - bbox[1] + 1
		var/size_y = bbox[4] - bbox[2] + 1

		cam_screen.show_camera(visible_turfs, size_x, size_y)

		return TRUE

/obj/machinery/computer/camera/ui_close(mob/user)
	var/user_ref = REF(user)
	var/is_living = isliving(user)
	// Living creature or not, we remove you anyway.
	concurrent_users -= user_ref
	// Unregister map objects
	cam_screen.hide_from(user)
	// Turn off the console
	if(length(concurrent_users) == 0 && is_living)
		active_camera = null
		playsound(src, 'sound/machines/terminal_off.ogg', 25, FALSE)
		use_power(0)

/atom/movable/screen/map_view/camera
	/// All the plane masters that need to be applied.
	var/atom/movable/screen/background/cam_background

/atom/movable/screen/map_view/camera/Destroy()
	QDEL_NULL(cam_background)
	return ..()

/atom/movable/screen/map_view/camera/generate_view(map_key)
	. = ..()
	cam_background = new
	cam_background.del_on_map_removal = FALSE
	cam_background.assigned_map = assigned_map

/atom/movable/screen/map_view/camera/display_to_client(client/show_to)
	show_to.register_map_obj(cam_background)
	. = ..()

/atom/movable/screen/map_view/camera/proc/show_camera(list/visible_turfs, size_x, size_y)
	vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/atom/movable/screen/map_view/camera/proc/show_camera_static()
	vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, DEFAULT_MAP_SIZE, DEFAULT_MAP_SIZE)

// Returns the list of cameras accessible from this computer
/obj/machinery/computer/camera/proc/get_available_cameras()
	var/list/L = list()
	for(var/i in GLOB.cameranet.cameras)
		var/obj/machinery/camera/C = i
		L.Add(C)
	var/list/valid_cams = list()
	for(var/obj/machinery/camera/C in L)
		if(!C.network)
			stack_trace("Camera in a cameranet has no camera network")
			continue
		if(!(islist(C.network)))
			stack_trace("Camera in a cameranet has a non-list camera network")
			continue
		var/list/tempnetwork = C.network & network
		if(length(tempnetwork))
			valid_cams["[C.c_tag]"] = C
	return valid_cams

#undef DEFAULT_MAP_SIZE
