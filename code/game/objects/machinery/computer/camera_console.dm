/obj/machinery/computer/security
	name = "security camera console"
	desc = "Used to access the various cameras on the station."
	icon_state = "computer_small"
	screen_overlay = "cameras"
	broken_icon = "computer_small_red_broken"

	circuit = /obj/item/circuitboard/computer/security

	var/list/network = list("marinemainship")
	var/list/watchers = list() //who's using the console, associated with the camera they're on.
	var/long_ranged = FALSE


/obj/machinery/computer/security/Initialize(mapload)
	. = ..()
	for(var/i in network)
		network -= i
		network += lowertext(i)


/obj/machinery/computer/security/check_eye(mob/living/user)
	if(!istype(user))
		return
	if((machine_stat & (NOPOWER|BROKEN|DISABLED)) || user.incapacitated() || user.eye_blind )
		user.unset_interaction()
		return
	if(!(user in watchers))
		user.unset_interaction()
		return
	if(!watchers[user])
		user.unset_interaction()
		return
	var/obj/machinery/camera/C = watchers[user]
	if(!C.can_use())
		user.unset_interaction()
		return
	if(long_ranged)
		var/list/viewing = viewers(src)
		if(!viewing.Find(user))
			user.unset_interaction()
		return
	if(!issilicon(user) && !Adjacent(user))
		user.unset_interaction()
		return


/obj/machinery/computer/security/on_unset_interaction(mob/user)
	watchers.Remove(user)
	user.reset_perspective(null)


/obj/machinery/computer/security/Destroy()
	if(length(watchers))
		for(var/mob/M in watchers)
			M.unset_interaction() //to properly reset the view of the users if the console is deleted.
	return ..()


/obj/machinery/computer/security/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(machine_stat)
		return

	if(!istype(user))
		return

	if(!network)
		user.unset_interaction()
		CRASH("No camera network")

	if(!(islist(network)))
		user.unset_interaction()
		CRASH("Camera network is not a list")

	var/list/camera_list = get_available_cameras()
	if(!(user in watchers))
		for(var/Num in camera_list)
			var/obj/machinery/camera/CAM = camera_list[Num]
			if(istype(CAM))
				if(CAM.can_use())
					watchers[user] = CAM //let's give the user the first usable camera, and then let him change to the camera he wants.
					break
		if(!(user in watchers))
			user.unset_interaction() // no usable camera on the network, we disconnect the user from the computer.
			return
	playsound(src, 'sound/machines/terminal_on.ogg', 25, 0)
	user.set_interaction(src)
	use_camera_console(user)


/obj/machinery/computer/security/proc/use_camera_console(mob/living/user)
	if(!istype(user))
		return
	var/list/camera_list = get_available_cameras()
	var/t = tgui_input_list(user, "Which camera should you change to?", null, camera_list)
	if(!t)
		user.unset_interaction()
		playsound(src, 'sound/machines/terminal_off.ogg', 25, 0)
		return

	var/obj/machinery/camera/C = camera_list[t]

	if(C)
		var/camera_fail = FALSE
		if(!C.can_use() || user.eye_blind || user.incapacitated())
			camera_fail = TRUE
		else if(long_ranged)
			var/list/viewing = viewers(src)
			if(!viewing.Find(user))
				camera_fail = TRUE
		else if(!issilicon(user) && !Adjacent(user))
			camera_fail = TRUE

		if(camera_fail)
			user.unset_interaction()
			return FALSE

		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 25, 0)
		if(isAI(user))
			var/mob/living/silicon/ai/A = user
			A.eyeobj.setLoc(get_turf(C))
			A.client.eye = A.eyeobj
		else
			user.reset_perspective(C)
			user.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/noise)
			user.clear_fullscreen("flash", 5)
		watchers[user] = C
		use_power(active_power_usage)
		addtimer(CALLBACK(src, PROC_REF(use_camera_console), user), 5)
	else
		user.unset_interaction()


//returns the list of cameras accessible from this computer
/obj/machinery/computer/security/proc/get_available_cameras()
	var/list/all_cams = list()
	for(var/i in GLOB.cameranet.cameras)
		var/obj/machinery/camera/C = i
		all_cams += C

	camera_sort(all_cams)

	var/list/valid_cams = list()
	for(var/i in all_cams)
		var/obj/machinery/camera/C = i
		if(!C.network)
			stack_trace("Camera in a cameranet has no camera network")
			continue
		if(!(islist(C.network)))
			stack_trace("Camera in a cameranet has a non-list camera network")
			continue
		var/list/tempnetwork = C.network & network
		if(length(tempnetwork) && C.c_tag)
			valid_cams["[C.c_tag]"] = C
	return valid_cams


/obj/machinery/computer/security/telescreen
	name = "Telescreen"
	desc = "Used for watching an empty arena."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	network = list("thunder")
	density = FALSE
	circuit = null


/obj/machinery/computer/security/telescreen/update_icon_state()
	icon_state = initial(icon_state)
	if(machine_stat & (BROKEN|DISABLED))
		icon_state += "b"


/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, why do they never have anything interesting on these things?"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment"
	circuit = null

/obj/machinery/computer/security/wooden_tv
	name = "Security Cameras"
	desc = "An old TV hooked into the stations camera network."
	icon_state = "security_det"
	screen_overlay = "security_det_screen"
	circuit = null


/obj/machinery/computer/security/mining
	name = "Outpost Cameras"
	desc = "Used to access the various cameras on the outpost."
	icon_state = "computer"
	screen_overlay = "miningcameras"
	broken_icon = "computer_blue_broken"
	network = list("MINE")
	circuit = /obj/item/circuitboard/computer/security/mining

/obj/machinery/computer/security/engineering
	name = "Engineering Cameras"
	desc = "Used to monitor fires and breaches."
	icon_state = "computer"
	screen_overlay = "engineeringcameras"
	broken_icon = "computer_blue_broken"
	network = list("Engineering","Power Alarms","Atmosphere Alarms","Fire Alarms")
	circuit = /obj/item/circuitboard/computer/security/engineering

/obj/machinery/computer/security/nuclear
	name = "Mission Monitor"
	desc = "Used to access the built-in cameras in helmets."
	icon_state = "computer"
	screen_overlay = "syndicam"
	network = list("NUKE")
	circuit = null


/obj/machinery/computer/security/marinemainship
	name = "Ship Security Cameras"
	density = FALSE
	icon_state = "computer_small"
	screen_overlay = "security_cam"
	network = list("marinemainship")


/obj/machinery/computer/security/marinemainship_network
	network = list("marinemainship")

/obj/machinery/computer/security/marine_network
	network = list("marine")

/obj/machinery/computer/security/som_mainship
	network = list("sommainship")

/obj/machinery/computer/security/som_network
	network = list(SOM_CAMERA_NETWORK)

/obj/machinery/computer/security/dropship
	name = "abstract dropship camera computer"
	desc = "A computer to monitor cameras linked to the dropship."
	density = TRUE
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "consoleleft"
	screen_overlay = "consoleleft_emissive"
	circuit = null
	resistance_flags = RESIST_ALL


/obj/machinery/computer/security/dropship/one
	name = "\improper 'Alamo' camera controls"
	network = list("dropship1")
	opacity = FALSE


/obj/machinery/computer/security/dropship/two
	name = "\improper 'Normandy' camera controls"
	network = list("dropship2")

/obj/machinery/computer/security/dropship/three
	name = "\improper 'Triump' camera controls"
	network = list("dropship3")

