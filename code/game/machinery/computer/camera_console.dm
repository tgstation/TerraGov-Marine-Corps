/obj/machinery/computer/security
	name = "security camera console"
	desc = "Used to access the various cameras on the station."
	icon_state = "cameras"

	circuit = /obj/item/circuitboard/computer/security

	var/list/network = list("marinemainship")
	var/list/watchers = list() //who's using the console, associated with the camera they're on.
	var/long_ranged = FALSE


/obj/machinery/computer/security/Initialize()
	. = ..()
	for(var/i in network)
		network -= i
		network += lowertext(i)


/obj/machinery/computer/security/check_eye(mob/living/user)
	if(!istype(user))
		return
	if((machine_stat & (NOPOWER|BROKEN)) || user.incapacitated() || user.eye_blind )
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


/obj/machinery/computer/security/attack_hand(mob/living/carbon/human/user)
	if(machine_stat)
		return

	if(!istype(user))
		return

	if(!network)
		user.unset_interaction()
		CRASH("No camera network")
		return

	if(!(islist(network)))
		user.unset_interaction()
		CRASH("Camera network is not a list")
		return

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
	playsound(src, 'sound/machines/terminal_prompt.ogg', 25, 0)
	user.set_interaction(src)
	use_camera_console(user)


/obj/machinery/computer/security/proc/use_camera_console(mob/living/user)
	if(!istype(user))
		return
	var/list/camera_list = get_available_cameras()
	var/t = input(user, "Which camera should you change to?") as null|anything in camera_list
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
			user.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/noise)
			user.clear_fullscreen("flash", 5)
		watchers[user] = C
		use_power(50)
		addtimer(CALLBACK(src, .proc/use_camera_console, user), 5)
	else
		user.unset_interaction()


//returns the list of cameras accessible from this computer
/obj/machinery/computer/security/proc/get_available_cameras()
	var/list/L = list()
	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if((is_away_level(z) || is_away_level(C.z)) && (C.z != z))//if on away mission, can only receive feed from same z_level cameras
			continue
		L.Add(C)

	camera_sort(L)

	var/list/D = list()
	for(var/obj/machinery/camera/C in L)
		if(!C.network)
			stack_trace("Camera in a cameranet has no camera network")
			continue
		if(!(islist(C.network)))
			stack_trace("Camera in a cameranet has a non-list camera network")
			continue
		var/list/tempnetwork = C.network & network
		if(length(tempnetwork))
			D["[C.c_tag][(C.status ? null : " (Deactivated)")]"] = C
	return D


/obj/machinery/computer/security/telescreen
	name = "Telescreen"
	desc = "Used for watching an empty arena."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	network = list("thunder")
	density = 0
	circuit = null


/obj/machinery/computer/security/telescreen/update_icon()
	icon_state = initial(icon_state)
	if(machine_stat & BROKEN)
		icon_state += "b"
	return

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
	circuit = null


/obj/machinery/computer/security/mining
	name = "Outpost Cameras"
	desc = "Used to access the various cameras on the outpost."
	icon_state = "miningcameras"
	network = list("MINE")
	circuit = /obj/item/circuitboard/computer/security/mining

/obj/machinery/computer/security/engineering
	name = "Engineering Cameras"
	desc = "Used to monitor fires and breaches."
	icon_state = "engineeringcameras"
	network = list("Engineering","Power Alarms","Atmosphere Alarms","Fire Alarms")
	circuit = /obj/item/circuitboard/computer/security/engineering

/obj/machinery/computer/security/nuclear
	name = "Mission Monitor"
	desc = "Used to access the built-in cameras in helmets."
	icon_state = "syndicam"
	network = list("NUKE")
	circuit = null


/obj/machinery/computer/security/marinemainship
	density = FALSE
	icon_state = "security_cam"
	network = list("marinemainship")


/obj/machinery/computer/security/marinemainship_network
	network = list("marinemainship")


/obj/machinery/computer/security/dropship
	name = "abstract dropship camera computer"
	desc = "A computer to monitor cameras linked to the dropship."
	density = TRUE
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "consoleleft"
	circuit = null
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE


/obj/machinery/computer/security/dropship/one
	name = "\improper 'Alamo' camera controls"
	network = list("dropship1")


/obj/machinery/computer/security/dropship/two
	name = "\improper 'Normandy' camera controls"
	network = list("dropship2")