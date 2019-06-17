/obj/machinery/computer/camera_advanced
	name = "advanced camera console"
	desc = "Used to access the various cameras on the ship."
	icon_state = "cameras"
	var/list/z_lock = list() // Lock use to these z levels
	var/lock_override = NONE
	var/open_prompt = TRUE
	var/mob/camera/aiEye/remote/eyeobj
	var/mob/living/current_user
	var/list/networks = list("marinemainship")
	var/datum/action/innate/camera_off/off_action
	var/datum/action/innate/camera_jump/jump_action
	var/list/actions


/obj/machinery/computer/camera_advanced/Initialize()
	. = ..()
	off_action = new
	jump_action = new
	actions = list()
	for(var/i in networks)
		networks -= i
		networks += lowertext(i)
	if(lock_override)
		if(lock_override & CAMERA_LOCK_SHIP)
			z_lock |= SSmapping.levels_by_trait(ZTRAITS_MAIN_SHIP)
		if(lock_override & CAMERA_LOCK_GROUND)
			z_lock |= SSmapping.levels_by_trait(ZTRAIT_GROUND)
		if(lock_override & CAMERA_LOCK_CENTCOM)
			z_lock |= SSmapping.levels_by_trait(ZTRAIT_CENTCOM)


/obj/machinery/computer/camera_advanced/proc/CreateEye()
	eyeobj = new()
	eyeobj.origin = src


/obj/machinery/computer/camera_advanced/proc/GrantActions(mob/living/user)
	if(off_action)
		off_action.target = user
		off_action.give_action(user)
		actions += off_action

	if(jump_action)
		jump_action.target = user
		jump_action.give_action(user)
		actions += jump_action

	
/obj/machinery/computer/camera_advanced/remove_eye_control(mob/living/user)
	if(!user)
		return
	for(var/V in actions)
		var/datum/action/A = V
		A.remove_action(user)
	actions.Cut()
	for(var/V in eyeobj.visibleCameraChunks)
		var/datum/camerachunk/C = V
		C.remove(eyeobj)
	if(user.client)
		user.reset_perspective(null)
		if(eyeobj.visible_icon && user.client)
			user.client.images -= eyeobj.user_image
	eyeobj.eye_user = null
	user.remote_control = null

	current_user = null
	user.unset_interaction()
	playsound(src, 'sound/machines/terminal_off.ogg', 25, 0)


/obj/machinery/computer/camera_advanced/check_eye(mob/living/user)
	if(machine_stat & (NOPOWER|BROKEN) || !Adjacent(user) || is_blind(user) || user.incapacitated(TRUE))
		user.unset_interaction()


/obj/machinery/computer/camera_advanced/Destroy()
	current_user?.unset_interaction()
	if(eyeobj)
		qdel(eyeobj)
	QDEL_LIST(actions)
	return ..()


/obj/machinery/computer/camera_advanced/on_unset_interaction(mob/M)
	if(M == current_user)
		remove_eye_control(M)


/obj/machinery/computer/camera_advanced/proc/can_use(mob/living/user)
	return TRUE


/obj/machinery/computer/camera_advanced/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(open_prompt)
		open_prompt(user)


/obj/machinery/computer/camera_advanced/proc/open_prompt(mob/user)
	if(current_user)
		to_chat(user, "The console is already in use!")
		return

	var/mob/living/L = user

	if(!can_use(user))
		return

	if(!eyeobj)
		CreateEye()

	if(!eyeobj.eye_initialized)
		var/camera_location
		var/turf/myturf = get_turf(src)
		if(eyeobj.use_static != USE_STATIC_NONE)
			if((!length(z_lock) || (myturf.z in z_lock)) && GLOB.cameranet.checkTurfVis(myturf))
				camera_location = myturf
			else
				for(var/i in GLOB.cameranet.cameras)
					var/obj/machinery/camera/C = i
					if(!C.can_use() || length(z_lock) && !(C.z in z_lock))
						continue
					var/list/network_overlap = networks & C.network
					if(length(network_overlap))
						camera_location = get_turf(C)
						break
		else
			camera_location = myturf
			if(length(z_lock) && !(myturf.z in z_lock))
				camera_location = locate(round(world.maxx / 2), round(world.maxy / 2), z_lock[1])

		if(camera_location)
			eyeobj.eye_initialized = TRUE
			give_eye_control(L)
			eyeobj.setLoc(camera_location)
		else
			user.unset_interaction()
	else
		give_eye_control(L)
		eyeobj.setLoc(eyeobj.loc)


/obj/machinery/computer/camera_advanced/attack_ai(mob/user)
	return


/obj/machinery/computer/camera_advanced/proc/give_eye_control(mob/user)
	GrantActions(user)
	current_user = user
	eyeobj.eye_user = user
	eyeobj.name = "Camera Eye ([user.name])"
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)
	eyeobj.setLoc(eyeobj.loc)


/mob/camera/aiEye/remote
	name = "Inactive Camera Eye"
	ai_detector_visible = FALSE
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1
	var/mob/living/eye_user = null
	var/obj/machinery/origin
	var/eye_initialized = 0
	var/visible_icon = 0
	var/image/user_image = null


/mob/camera/aiEye/remote/update_remote_sight(mob/living/user)
	user.see_invisible = SEE_INVISIBLE_LIVING
	user.sight = SEE_TURFS | SEE_BLACKNESS
	user.see_in_dark = 2
	return TRUE


/mob/camera/aiEye/remote/Destroy()
	if(origin && eye_user)
		origin.remove_eye_control(eye_user,src)
	origin = null
	eye_user = null
	return ..()


/mob/camera/aiEye/remote/GetViewerClient()
	return eye_user?.client


/mob/camera/aiEye/remote/setLoc(T)
	if(eye_user)
		T = get_turf(T)
		if (T)
			forceMove(T)
		else
			moveToNullspace()
		update_ai_detect_hud()
		if(use_static != USE_STATIC_NONE)
			GLOB.cameranet.visibility(src, GetViewerClient(), null, use_static)
		if(visible_icon)
			if(eye_user.client)
				eye_user.client.images -= user_image
				user_image = image(icon,loc,icon_state,FLY_LAYER)
				eye_user.client.images += user_image


/mob/camera/aiEye/remote/relaymove(mob/user, direct)
	var/initial = initial(sprint)
	var/max_sprint = 50

	if(cooldown && cooldown < world.timeofday) // 3 seconds
		sprint = initial

	for(var/i = 0; i < max(sprint, initial); i += 20)
		var/turf/T = get_turf(get_step(src, direct))
		if(T)
			setLoc(T)

	cooldown = world.timeofday + 0.5 SECONDS
	if(acceleration)
		sprint = min(sprint + 0.5, max_sprint)
	else
		sprint = initial


/datum/action/innate/camera_off
	name = "End Camera View"
	button_icon_state = "template2"
	icon_icon_state = "camera_off"


/datum/action/innate/camera_off/Activate()
	if(!isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/console = remote_eye.origin
	console.remove_eye_control(target)


/datum/action/innate/camera_jump
	name = "Jump To Camera"
	button_icon_state = "template2"
	icon_icon_state = "camera_jump"


/datum/action/innate/camera_jump/Activate()
	if(!isliving(target))
		return
	var/mob/living/L = target
	var/mob/camera/aiEye/remote/remote_eye = L.remote_control
	var/obj/machinery/computer/camera_advanced/origin = remote_eye.origin

	var/list/valid_cams = list()

	for(var/i in GLOB.cameranet.cameras)
		var/obj/machinery/camera/C = i
		if(length(origin.z_lock) && !(C.z in origin.z_lock))
			continue
		valid_cams += C

	camera_sort(valid_cams)

	var/list/T = list()

	for(var/i in valid_cams)
		var/obj/machinery/camera/C = i
		var/list/tempnetwork = C.network & origin.networks
		if(length(tempnetwork))
			T["[C.c_tag][C.can_use() ? null : " (Deactivated)"]"] = C

	playsound(origin, 'sound/machines/terminal_prompt.ogg', 25, 0)
	var/camera = input("Choose which camera you want to view?", "Cameras") as null|anything in T
	var/obj/machinery/camera/C = T[camera]
	playsound(src, "terminal_type", 25, 0)

	if(!C)
		playsound(origin, 'sound/machines/terminal_prompt_deny.ogg', 25, 0)
		return

	playsound(origin, 'sound/machines/terminal_prompt_confirm.ogg', 25, 0)
	remote_eye.setLoc(get_turf(C))
	L.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/noise)
	L.clear_fullscreen("flash", 3)