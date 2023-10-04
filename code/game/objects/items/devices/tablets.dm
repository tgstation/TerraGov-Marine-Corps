/obj/item/hud_tablet
	name = "hud tablet"
	desc = "A tablet with a live feed to a number of headset cameras"
	icon = 'icons/Marine/marine-navigation.dmi'
	icon_state = "req_tablet_off"
	req_access = list(ACCESS_NT_CORPORATE)
	flags_equip_slot = ITEM_SLOT_POCKET
	w_class = WEIGHT_CLASS_SMALL

	interaction_flags = INTERACT_MACHINE_TGUI


	/// How far can these tablets see around the cameras
	var/max_view_dist = 3

	var/obj/machinery/camera/active_camera
	/// Used to keep a cache of the last location visible on the camera
	var/turf/last_turf
	var/list/network = list("marine")

	// Stuff needed to render the map
	var/map_name
	var/const/default_map_size = 15
	var/atom/movable/screen/map_view/cam_screen
	/// All the plane masters that need to be applied.
	var/list/cam_plane_masters
	var/atom/movable/screen/background/cam_background

/obj/item/hud_tablet/Initialize(mapload, rank, datum/squad/squad)
	. = ..()
	if(rank)
		var/dat = "marine"
		switch(rank)
			if(/datum/job/terragov/squad/leader)
				if(squad)
					switch(squad.name)
						if("Alpha")
							dat += " alpha"
							network = list("alpha")
							req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_ALPHA)
						if("Bravo")
							dat += " bravo"
							network = list("bravo")
							req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_BRAVO)
						if("Charlie")
							dat += " charlie"
							network = list("charlie")
							req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_CHARLIE)
						if("Delta")
							dat += " delta"
							network = list("delta")
							req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_DELTA)
				dat += " squad leader's"
			if(/datum/job/terragov/command/captain)
				dat += " captain's"
				network = list("marinesl", "marine", "marinemainship")
				req_access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_LEADER, ACCESS_MARINE_CAPTAIN)
			if(/datum/job/terragov/command/fieldcommander)
				dat += " field commander's"
				network = list("marinesl", "marine")
				req_access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_LEADER)
			if(/datum/job/terragov/command/pilot)
				dat += " pilot's"
				network = list("dropship1", "dropship2")
				req_access = list(ACCESS_MARINE_PILOT, ACCESS_MARINE_DROPSHIP)
		name = dat + " hud tablet"
	// Convert networks to lowercase
	for(var/i in network)
		network -= i
		network += lowertext(i)
	// Map name has to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	// I wasted 6 hours on this. :agony:
	map_name = "hud_tablet_[REF(src)]_map"
	// Initialize map objects
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.del_on_map_removal = FALSE
	cam_screen.screen_loc = "[map_name]:1,1"
	cam_plane_masters = list()
	for(var/plane in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/blackness)
		var/atom/movable/screen/plane_master/instance = new plane()
		instance.assigned_map = map_name
		instance.del_on_map_removal = FALSE
		if(instance.blend_mode_override)
			instance.blend_mode = instance.blend_mode_override
		instance.screen_loc = "[map_name]:CENTER"
		cam_plane_masters += instance
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE

/obj/item/hud_tablet/Destroy()
	qdel(cam_screen)
	QDEL_LIST(cam_plane_masters)
	qdel(cam_background)
	return ..()

/obj/item/hud_tablet/proc/get_available_cameras()
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
		if(C.c_tag == "Unknown")
			continue // dropped headsets havee an unknown tag
		var/list/tempnetwork = C.network & network
		if(length(tempnetwork))
			valid_cams["[C.c_tag]"] = C
	return valid_cams

/obj/item/hud_tablet/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, default_map_size, default_map_size)

/obj/item/hud_tablet/interact(mob/user)
	if(!allowed(user))
		to_chat(user, span_warning("Access denied, unauthorized user."))
		return TRUE
	return ..()

/obj/item/hud_tablet/ui_interact(mob/user, datum/tgui/ui)
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui)

	// Update the camera, showing static if necessary and updating data if the location has moved.
	update_active_camera_screen()

	if(!ui)
		// Register map objects
		user.client.register_map_obj(cam_screen)
		for(var/plane in cam_plane_masters)
			user.client.register_map_obj(plane)
		user.client.register_map_obj(cam_background)
		// Open UI
		ui = new(user, src, "CameraConsole", name)
		ui.open()

/obj/item/hud_tablet/ui_data()
	. = list()
	.["network"] = network
	.["activeCamera"] = null
	if(active_camera)
		.["activeCamera"] = list(
			name = active_camera.c_tag,
			status = active_camera.status,
		)

/obj/item/hud_tablet/ui_static_data()
	var/list/data = list()
	data["mapRef"] = map_name
	var/list/cameras = get_available_cameras()
	data["cameras"] = list()
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		data["cameras"] += list(list(
			name = C.c_tag,
		))
	return data

/obj/item/hud_tablet/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "switch_camera")
		var/c_tag = params["name"]
		var/list/cameras = get_available_cameras()
		var/obj/machinery/camera/selected_camera = cameras[c_tag]
		active_camera = selected_camera
		playsound(src, get_sfx("terminal_type"), 25, FALSE)

		if(!selected_camera)
			return TRUE

		update_active_camera_screen()

		return TRUE

/obj/item/hud_tablet/proc/update_active_camera_screen()
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		show_camera_static()
		return

	var/list/visible_turfs = list()

	// Is this camera located in or attached to a living thing? If so, assume the camera's loc is the living thing.
	var/cam_location = isliving(active_camera.loc) ? active_camera.loc : active_camera

	// If we're not forcing an update for some reason and the cameras are in the same location,
	// we don't need to update anything.
	// Most security cameras will end here as they're not moving.
	var/newturf = get_turf(cam_location)
	if(last_turf == newturf)
		return

	// Cameras that get here are moving, and are likely attached to some moving atom such as cyborgs.
	last_turf = get_turf(cam_location)

	for(var/turf/visible_turf in view(min(max_view_dist, active_camera.view_range), last_turf))
		visible_turfs += visible_turf

	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/obj/item/hud_tablet/alpha
	name = "alpha hud tablet"
	network = list("alpha")
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_ALPHA)

/obj/item/hud_tablet/bravo
	name = "bravo hud tablet"
	network = list("bravo")
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_BRAVO)

/obj/item/hud_tablet/charlie
	name = "charlie hud tablet"
	network = list("charlie")
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_CHARLIE)

/obj/item/hud_tablet/delta
	name = "delta hud tablet"
	network = list("delta")
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_DELTA)

/obj/item/hud_tablet/leadership
	name = "captain's hud tablet"
	network = list("marinesl", "marine", "marinemainship")
	req_access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_LEADER, ACCESS_MARINE_CAPTAIN)
	max_view_dist = WORLD_VIEW_NUM

/obj/item/hud_tablet/fieldcommand
	name = "field commander's hud tablet"
	network = list("marinesl", "marine")
	req_access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_LEADER)
	max_view_dist = WORLD_VIEW_NUM

/obj/item/hud_tablet/pilot
	name = "pilot officers's hud tablet"
	network = list("dropship1", "dropship2")
	req_access = list(ACCESS_MARINE_PILOT, ACCESS_MARINE_DROPSHIP)
	max_view_dist = WORLD_VIEW_NUM


/obj/item/hud_tablet/artillery
	name = "artillery impact hud tablet"
	desc = "A handy tablet with a live feed to several TGMC satellites. Provides a view of all artillery on the battlefield. Transmits a video of the impact site whenever a shot is fired, so that hits may be observed by the loader or spotter."
	network = list("terragovartillery") //This shows cameras of all mortars, so don't add this to HvH
	req_access = list()
	max_view_dist = WORLD_VIEW_NUM

