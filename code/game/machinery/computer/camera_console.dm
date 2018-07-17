//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31


/obj/machinery/computer/security
	name = "Security Cameras"
	desc = "Used to access the various cameras on the station."
	icon_state = "cameras"
	var/obj/machinery/camera/current = null
	var/last_pic = 1.0
	var/list/network = list("military")
	var/mapping = 0//For the overview file, interesting bit of code.
	circuit = /obj/item/circuitboard/computer/security


	attack_ai(var/mob/user as mob)
		return attack_hand(user)


	attack_paw(var/mob/user as mob)
		return attack_hand(user)


	check_eye(mob/user)
		if (user.is_mob_incapacitated() || ((get_dist(user, src) > 1 || !( user.canmove ) || user.blinded) && !istype(user, /mob/living/silicon))) //user can't see - not sure why canmove is here.
			user.unset_interaction()
			return
		else if ( !current || !current.can_use() ) //camera doesn't work
			current = null
		user.reset_view(current)


	on_set_interaction(mob/user)
		..()
		if(current && current.can_use())
			user.reset_view(current)


	on_unset_interaction(mob/user)
		..()
		user.reset_view(null)


	attack_hand(mob/user)
		if (src.z > 6)
			user << "\red <b>Unable to establish a connection</b>: \black You're too far away from the station!"
			return
		if(stat & (NOPOWER|BROKEN))	return

		if(!isAI(user))
			user.set_interaction(src)

		var/list/L = list()
		for (var/obj/machinery/camera/C in cameranet.cameras)
			L.Add(C)

		camera_sort(L)

		var/list/D = list()
		D["Cancel"] = "Cancel"
		for(var/obj/machinery/camera/C in L)
			if(can_access_camera(C))
				D["[C.c_tag][C.can_use() ? null : " (Deactivated)"]"] = C

		var/t = input(user, "Which camera should you change to?") as null|anything in D
		if(!t)
			user.unset_interaction()
			return 0

		var/obj/machinery/camera/C = D[t]
		if(t == "Cancel")
			user.unset_interaction()
			return 0

		if(C)
			if(!can_access_camera(C)) return
			switch_to_camera(user, C)
			spawn(5)
				attack_hand(user)
		return

	proc/can_access_camera(obj/machinery/camera/C)
		var/list/shared_networks = src.network & C.network
		if(shared_networks.len)
			return 1
		return 0

	proc/switch_to_camera(mob/user, obj/machinery/camera/C)
		//don't need to check if the camera works for AI because the AI jumps to the camera location and doesn't actually look through cameras.
		if(isAI(user))
			var/mob/living/silicon/ai/A = user
			A.eyeobj.setLoc(get_turf(C))
			A.client.eye = A.eyeobj
			return 1

		if (!C.can_use() || user.is_mob_incapacitated() || (get_dist(user, src) > 1 || user.interactee != src || user.blinded || !( user.canmove ) && !istype(user, /mob/living/silicon)))
			return 0
		src.current = C
		use_power(50)
		user.reset_view(C)
		return 1

//Camera control: moving.
	proc/jump_on_click(var/mob/user,var/A)
		if(user.interactee != src)
			return
		var/obj/machinery/camera/jump_to
		if(istype(A,/obj/machinery/camera))
			jump_to = A
		else if(ismob(A))
			if(ishuman(A))
				jump_to = locate() in A:head
			else if(isrobot(A))
				jump_to = A:camera
		else if(isobj(A))
			jump_to = locate() in A
		else if(isturf(A))
			var/best_dist = INFINITY
			for(var/obj/machinery/camera/camera in get_area(A))
				if(!camera.can_use())
					continue
				if(!can_access_camera(camera))
					continue
				var/dist = get_dist(camera,A)
				if(dist < best_dist)
					best_dist = dist
					jump_to = camera
		if(isnull(jump_to))
			return
		if(can_access_camera(jump_to))
			switch_to_camera(user,jump_to)

//Camera control: mouse.
/obj/machinery/computer/security/clicked(var/mob/user, var/list/mods)
	if (mods["ctrl"] && mods["middle"])
		if (src == user.interactee)
			jump_on_click(user, src)
		return 1

	..()

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
	if(stat & BROKEN)
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


/obj/machinery/computer/security/almayer
	density = 0
	icon_state = "security_cam"
	network = list("almayer")

/obj/machinery/computer/security/almayer_network
	network = list("almayer")


/obj/machinery/computer/security/dropship
	name = "abstract dropship camera computer"
	desc = "A computer to monitor cameras linked to the dropship."
	density = 1
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "consoleleft"
	circuit = null
	unacidable = TRUE
	exproof = TRUE


/obj/machinery/computer/security/dropship/one
	name = "\improper 'Alamo' camera controls"
	network = list("dropship1")

/obj/machinery/computer/security/dropship/two
	name = "\improper 'Normandy' camera controls"
	network = list("dropship2")

