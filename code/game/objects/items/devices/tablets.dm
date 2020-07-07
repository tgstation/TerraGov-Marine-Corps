/obj/item/hud_tablet
	name = "hud tablet"
	desc = "A tablet with a live feed to a number of headset cameras"
	icon = 'icons/obj/items/req_tablet.dmi'
	icon_state = "req_tablet_off"
	req_access = list(ACCESS_NT_CORPORATE)
	flags_equip_slot = ITEM_SLOT_POCKET
	w_class = WEIGHT_CLASS_NORMAL

	var/ui_x = 870
	var/ui_y = 708
	interaction_flags = INTERACT_MACHINE_TGUI


	/// How far can these tablets see around the cameras
	var/max_view_dist = 2

	var/obj/machinery/camera/active_camera
	/// Used to keep a cache of the last location visible on the camera
	var/turf/last_turf
	var/list/network = list("marine")

	// Stuff needed to render the map
	var/map_name
	var/const/default_map_size = 15
	var/obj/screen/map_view/cam_screen
	/// All the plane masters that need to be applied.
	var/list/cam_plane_masters
	var/obj/screen/background/cam_background

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
	for(var/plane in subtypesof(/obj/screen/plane_master))
		var/obj/screen/instance = new plane()
		instance.assigned_map = map_name
		instance.del_on_map_removal = FALSE
		instance.screen_loc = "[map_name]:CENTER"
		cam_plane_masters += instance
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE

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
		to_chat(user, "<span class='warning'>Access denied, unauthorized user.</span>")
		return TRUE
	return ..()

/obj/item/hud_tablet/ui_interact(\
		mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
		datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		show_camera_static()
	if(!ui)
		// Register map objects
		user.client.register_map_obj(cam_screen)
		for(var/plane in cam_plane_masters)
			user.client.register_map_obj(plane)
		user.client.register_map_obj(cam_background)
		// Open UI
		ui = new(user, src, ui_key, "CameraConsole", name, ui_x, ui_y, master_ui, state)
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

		var/turf/current_turf = get_turf(active_camera)
		if(last_turf == current_turf)
			return
		last_turf = current_turf

		var/list/visible_turfs = list()
		for(var/turf/T in view(min(max_view_dist, active_camera.view_range), current_turf))
			visible_turfs += T

		var/list/bbox = get_bbox_of_atoms(visible_turfs)
		var/size_x = bbox[3] - bbox[1] + 1
		var/size_y = bbox[4] - bbox[2] + 1

		cam_screen.vis_contents = visible_turfs
		cam_background.icon_state = "clear"
		cam_background.fill_rect(1, 1, size_x, size_y)

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
		var/obj/machinery/camera/C = cameras[c_tag]
		active_camera = C
		playsound(src, get_sfx("terminal_type"), 25, FALSE)

		// Show static if can't use the camera
		if(!active_camera?.can_use())
			show_camera_static()
			return TRUE

		return TRUE


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

/obj/item/hud_tablet/fieldcommand
	name = "field commander's hud tablet"
	network = list("marinesl", "marine")
	req_access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_LEADER)

/obj/item/hud_tablet/pilot
	name = "pilot officers's hud tablet"
	network = list("dropship1", "dropship2")
	req_access = list(ACCESS_MARINE_PILOT, ACCESS_MARINE_DROPSHIP)

//have to make these functional later
/obj/item/hud_tablet/leadership/natsf
	name = "captain's hud tablet"
	icon_state = "blue_off"
	network = list("marinesl", "marine", "marinemainship")
	req_access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_LEADER, ACCESS_MARINE_CAPTAIN)

/obj/item/hud_tablet/leadership/kosmnaz
	name = "captain's hud tablet"
	icon_state = "brown_off"
	network = list("marinesl", "marine", "marinemainship")
	req_access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_LEADER, ACCESS_MARINE_CAPTAIN)

