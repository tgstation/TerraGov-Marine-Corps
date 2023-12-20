/mob/living/silicon/ai/proc/get_camera_list()
	var/list/L = list()
	for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		L.Add(C)

	camera_sort(L)

	var/list/T = list()

	for(var/obj/machinery/camera/C in L)
		var/list/tempnetwork = C.network & available_networks
		if(length(tempnetwork))
			T["[C.c_tag][C.can_use() ? "" : " (Deactivated)"]"] = C

	return T


/mob/living/silicon/ai/proc/show_camera_list()
	if(controlling)
		return
	var/list/cameras = get_camera_list()
	var/camera = tgui_input_list(src, "Choose which camera you want to view", "Cameras", cameras)
	switchCamera(cameras[camera])


/datum/trackable
	var/initialized = FALSE
	var/list/names = list()
	var/list/namecounts = list()
	var/list/humans = list()
	var/list/others = list()


/mob/living/silicon/ai/proc/trackable_mobs()
	track.initialized = TRUE
	track.names.Cut()
	track.namecounts.Cut()
	track.humans.Cut()
	track.others.Cut()

	if(incapacitated())
		return

	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		if(!L.can_track(src))
			continue

		var/name = L.name
		while(name in track.names)
			track.namecounts[name]++
			name = "[name] ([track.namecounts[name]])"
		track.names.Add(name)
		track.namecounts[name] = 1

		if(ishuman(L))
			track.humans[name] = L
		else
			track.others[name] = L

	var/list/targets = sortList(track.humans) + sortList(track.others)

	return targets


/mob/living/silicon/ai/verb/ai_camera_track(target_name in trackable_mobs())
	set name = "track"
	set hidden = TRUE

	if(!target_name)
		return

	if(controlling)
		return

	if(!track.initialized)
		trackable_mobs()

	var/mob/target = (isnull(track.humans[target_name]) ? track.others[target_name] : track.humans[target_name])

	ai_actual_track(target)


/mob/living/silicon/ai/proc/ai_actual_track(mob/living/target)
	if(!istype(target))
		return

	cameraFollow = target
	tracking = TRUE

	if(!target || !target.can_track(src))
		to_chat(src, span_warning("Target is not near any active cameras."))
		cameraFollow = null
		return

	to_chat(src, span_notice("Now tracking [target.get_visible_name()] on camera."))

	var/cameraticks = 0
	spawn(0)
		while(cameraFollow == target)
			if(cameraFollow == null)
				return

			if(!target.can_track(src))
				tracking = TRUE
				if(!cameraticks)
					to_chat(src, span_warning("Target is not near any active cameras. Attempting to reacquire..."))
				cameraticks++
				if(cameraticks > 9)
					cameraFollow = null
					to_chat(src, span_warning("Unable to reacquire, cancelling track..."))
					tracking = FALSE
					return
				else
					sleep(1 SECONDS)
					continue

			else
				cameraticks = 0
				tracking = FALSE

			if(eyeobj)
				eyeobj.setLoc(get_turf(target))

			else
				view_core()
				cameraFollow = null
				return

			sleep(1 SECONDS)


/proc/near_camera(mob/living/M)
	if(!isturf(M.loc))
		return FALSE
	if(issilicon(M))
		var/mob/living/silicon/S = M
		if((QDELETED(S.builtInCamera) || !S.builtInCamera.can_use()) && !GLOB.cameranet.checkCameraVis(M))
			return FALSE
	else if(!GLOB.cameranet.checkCameraVis(M))
		return FALSE
	return TRUE


/obj/machinery/camera/attack_ai(mob/living/silicon/ai/user)
	if(!istype(user))
		return
	if(!can_use())
		return
	user.switchCamera(src)


/proc/camera_sort(list/L)  // TODO: replace this bubblesort with a mergesort - spookydonut
	var/obj/machinery/camera/a
	var/obj/machinery/camera/b

	for(var/i = length(L), i > 0, i--)
		for(var/j = 1 to i - 1)
			a = L[j]
			b = L[j + 1]
			if(sorttext(a.c_tag, b.c_tag) < 0)
				L.Swap(j, j + 1)
	return L
