/obj/machinery/computer/security
	name = "security camera console"
	desc = ""
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/security
	light_color = LIGHT_COLOR_RED

	var/last_pic = 1
	var/list/network = list("ss13")
	var/list/watchers = list() //who's using the console, associated with the camera they're on.
	var/long_ranged = FALSE

/obj/machinery/computer/security/Initialize()
	. = ..()
	for(var/i in network)
		network -= i
		network += lowertext(i)

/obj/machinery/computer/security/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	for(var/i in network)
		network -= i
		network += "[idnum][i]"

/obj/machinery/computer/security/check_eye(mob/user)
	if( (stat & (NOPOWER|BROKEN)) || user.incapacitated() || user.eye_blind )
		user.unset_machine()
		return
	if(!(user in watchers))
		user.unset_machine()
		return
	if(!watchers[user])
		user.unset_machine()
		return
	var/obj/machinery/camera/C = watchers[user]
	if(!C.can_use())
		user.unset_machine()
		return
	if(iscyborg(user) || long_ranged)
		var/list/viewing = viewers(src)
		if(!viewing.Find(user))
			user.unset_machine()
		return
	if(!issilicon(user) && !Adjacent(user))
		user.unset_machine()
		return

/obj/machinery/computer/security/on_unset_machine(mob/user)
	watchers.Remove(user)
	user.reset_perspective(null)

/obj/machinery/computer/security/Destroy()
	if(watchers.len)
		for(var/mob/M in watchers)
			M.unset_machine() //to properly reset the view of the users if the console is deleted.
	return ..()

/obj/machinery/computer/security/interact(mob/user)
	if (stat)
		return
	if (ismob(user) && !isliving(user)) // ghosts don't need cameras
		return
	if (!network)
		user.unset_machine()
		CRASH("No camera network")
		return
	if (!(islist(network)))
		user.unset_machine()
		CRASH("Camera network is not a list")
		return
	if(..())
		user.unset_machine()
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
			user.unset_machine() // no usable camera on the network, we disconnect the user from the computer.
			return
	playsound(src, 'sound/blank.ogg', 25, FALSE)
	use_camera_console(user)

/obj/machinery/computer/security/proc/use_camera_console(mob/user)
	var/list/camera_list = get_available_cameras()
	var/t = input(user, "Which camera should you change to?") as null|anything in camera_list
	if(user.machine != src) //while we were choosing we got disconnected from our computer or are using another machine.
		return
	if(!t)
		user.unset_machine()
		playsound(src, 'sound/blank.ogg', 25, FALSE)
		return

	var/obj/machinery/camera/C = camera_list[t]

	if(t == "Cancel")
		user.unset_machine()
		playsound(src, 'sound/blank.ogg', 25, FALSE)
		return
	if(C)
		var/camera_fail = 0
		if(!C.can_use() || user.machine != src || user.eye_blind || user.incapacitated())
			camera_fail = 1
		else if(iscyborg(user) || long_ranged)
			var/list/viewing = viewers(src)
			if(!viewing.Find(user))
				camera_fail = 1
		else if(!issilicon(user) && !Adjacent(user))
			camera_fail = 1

		if(camera_fail)
			user.unset_machine()
			return 0

		playsound(src, 'sound/blank.ogg', 25, FALSE)
		if(isAI(user))
			var/mob/living/silicon/ai/A = user
			A.eyeobj.setLoc(get_turf(C))
			A.client.eye = A.eyeobj
		else
			user.reset_perspective(C)
			user.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
			user.clear_fullscreen("flash", 5)
		watchers[user] = C
		use_power(50)
		addtimer(CALLBACK(src, .proc/use_camera_console, user), 5)
	else
		user.unset_machine()

//returns the list of cameras accessible from this computer
/obj/machinery/computer/security/proc/get_available_cameras()
	var/list/L = list()
	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if((is_away_level(z) || is_away_level(C.z)) && (C.z != z))//if on away mission, can only receive feed from same z_level cameras
			continue
		L.Add(C)

	camera_sort(L)

	var/list/D = list()
	D["Cancel"] = "Cancel"
	for(var/obj/machinery/camera/C in L)
		if(!C.network)
			stack_trace("Camera in a cameranet has no camera network")
			continue
		if(!(islist(C.network)))
			stack_trace("Camera in a cameranet has a non-list camera network")
			continue
		var/list/tempnetwork = C.network&network
		if(tempnetwork.len)
			D["[C.c_tag][(C.status ? null : " (Deactivated)")]"] = C
	return D

// SECURITY MONITORS

/obj/machinery/computer/security/wooden_tv
	name = "security camera monitor"
	desc = ""
	icon_state = "television"
	icon_keyboard = null
	icon_screen = "detective_tv"
	pass_flags = PASSTABLE

/obj/machinery/computer/security/mining
	name = "outpost camera console"
	desc = ""
	icon_screen = "mining"
	icon_keyboard = "mining_key"
	network = list("mine", "auxbase")
	circuit = /obj/item/circuitboard/computer/mining

/obj/machinery/computer/security/research
	name = "research camera console"
	desc = ""
	network = list("rd")
	circuit = /obj/item/circuitboard/computer/research

/obj/machinery/computer/security/hos
	name = "\improper Head of Security's camera console"
	desc = ""
	network = list("ss13", "labor")
	circuit = null

/obj/machinery/computer/security/labor
	name = "labor camp monitoring"
	desc = ""
	network = list("labor")
	circuit = null

/obj/machinery/computer/security/qm
	name = "\improper Quartermaster's camera console"
	desc = ""
	network = list("mine", "auxbase", "vault")
	circuit = null

// TELESCREENS

/obj/machinery/computer/security/telescreen
	name = "\improper Telescreen"
	desc = ""
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	layer = SIGN_LAYER
	network = list("thunder")
	density = FALSE
	circuit = null
	light_power = 0

/obj/machinery/computer/security/telescreen/update_icon_state()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = ""
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment_blank"
	network = list("thunder")
	density = FALSE
	circuit = null
	long_ranged = TRUE
	interaction_flags_atom = NONE  // interact() is called by BigClick()
	var/icon_state_off = "entertainment_blank"
	var/icon_state_on = "entertainment"

/obj/machinery/computer/security/telescreen/entertainment/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_CLICK, .proc/BigClick)

// Bypass clickchain to allow humans to use the telescreen from a distance
/obj/machinery/computer/security/telescreen/entertainment/proc/BigClick()
	interact(usr)

/obj/machinery/computer/security/telescreen/entertainment/proc/notify(on)
	if(on && icon_state == icon_state_off)
		say(pick(
			"Feats of bravery live now at the thunderdome!",
			"Two enter, one leaves! Tune in now!",
			"Violence like you've never seen it before!",
			"Spears! Camera! Action! LIVE NOW!"))
		icon_state = icon_state_on
	else
		icon_state = icon_state_off

/obj/machinery/computer/security/telescreen/rd
	name = "\improper Research Director's telescreen"
	desc = ""
	network = list("rd", "aicore", "aiupload", "minisat", "xeno", "test")

/obj/machinery/computer/security/telescreen/research
	name = "research telescreen"
	desc = ""
	network = list("rd")

/obj/machinery/computer/security/telescreen/ce
	name = "\improper Chief Engineer's telescreen"
	desc = ""
	network = list("engine", "singularity", "tcomms", "minisat")

/obj/machinery/computer/security/telescreen/cmo
	name = "\improper Chief Medical Officer's telescreen"
	desc = ""
	network = list("medbay")

/obj/machinery/computer/security/telescreen/vault
	name = "vault monitor"
	desc = ""
	network = list("vault")

/obj/machinery/computer/security/telescreen/toxins
	name = "bomb test site monitor"
	desc = ""
	network = list("toxins")

/obj/machinery/computer/security/telescreen/engine
	name = "engine monitor"
	desc = ""
	network = list("engine")

/obj/machinery/computer/security/telescreen/turbine
	name = "turbine monitor"
	desc = ""
	network = list("turbine")

/obj/machinery/computer/security/telescreen/interrogation
	name = "interrogation room monitor"
	desc = ""
	network = list("interrogation")

/obj/machinery/computer/security/telescreen/prison
	name = "prison monitor"
	desc = ""
	network = list("prison")

/obj/machinery/computer/security/telescreen/auxbase
	name = "auxillary base monitor"
	desc = ""
	network = list("auxbase")

/obj/machinery/computer/security/telescreen/minisat
	name = "minisat monitor"
	desc = ""
	network = list("minisat")

/obj/machinery/computer/security/telescreen/aiupload
	name = "\improper AI upload monitor"
	desc = ""
	network = list("aiupload")
