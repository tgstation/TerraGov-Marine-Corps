/obj/machinery/computer/camera_advanced
	name = "advanced camera console"
	desc = "Used to access the various cameras on the ship."
	icon_state = "cameras"
	interaction_flags = INTERACT_MACHINE_NOSILICON
	var/list/z_lock = list() // Lock use to these z levels
	var/lock_override = NONE
	var/open_prompt = TRUE
	var/mob/camera/aiEye/remote/hud/overwatch/eyeobj
	var/mob/living/current_user
	var/list/networks = list("marinemainship")
	var/datum/action/innate/camera_off/off_action
	var/datum/action/innate/camera_jump/jump_action
	var/list/actions
	var/mob/living/tracking_target
	var/tracking = FALSE
	var/cameraticks = 0


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


/obj/machinery/computer/camera_advanced/proc/give_actions(mob/living/user)
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
	if(!eyeobj)
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
	user.client.view_size.unsupress()
	playsound(src, 'sound/machines/terminal_off.ogg', 25, 0)


/obj/machinery/computer/camera_advanced/check_eye(mob/living/user)
	if(machine_stat & (NOPOWER|BROKEN|DISABLED) || user.incapacitated(TRUE))
		user.unset_interaction()
	if(isAI(user))
		return
	if(!Adjacent(user) || is_blind(user))
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


/obj/machinery/computer/camera_advanced/interact(mob/living/user)
	. = ..()
	if(.)
		return

	if(open_prompt)
		open_prompt(user)


/obj/machinery/computer/camera_advanced/proc/open_prompt(mob/user, turf/premade_camera_location)
	if(current_user)
		to_chat(user, "The console is already in use!")
		return

	var/mob/living/L = user

	if(!can_use(user))
		return

	if(!eyeobj)
		CreateEye()

	if(!eyeobj.eye_initialized)
		if(premade_camera_location)
			eyeobj.eye_initialized = TRUE
			give_eye_control(L)
			eyeobj.setLoc(premade_camera_location)
			return
		var/camera_location
		var/turf/myturf = get_turf(src)
		if(eyeobj.use_static)
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


/obj/machinery/computer/camera_advanced/proc/give_eye_control(mob/user)
	give_actions(user)
	current_user = user
	eyeobj.eye_user = user
	eyeobj.name = "Camera Eye ([user.name])"
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)
	eyeobj.setLoc(eyeobj.loc)
	user.client.view_size.supress()

/obj/machinery/computer/camera_advanced/proc/track(mob/living/target)
	if(!istype(target))
		return

	if(!target.can_track(current_user))
		to_chat(current_user, span_warning("Target is not near any active cameras."))
		tracking_target = null
		return

	tracking_target = target
	to_chat(current_user, span_notice("Now tracking [target.get_visible_name()] on camera."))
	start_processing()


/obj/machinery/computer/camera_advanced/process()
	if(QDELETED(tracking_target))
		return PROCESS_KILL

	if(!tracking_target.can_track(current_user))
		if(!cameraticks)
			to_chat(current_user, span_warning("Target is not near any active cameras. Attempting to reacquire..."))
		cameraticks++
		if(cameraticks > 9)
			tracking_target = null
			to_chat(current_user, span_warning("Unable to reacquire, cancelling track..."))
			return PROCESS_KILL
	else
		cameraticks = 0

	eyeobj?.setLoc(get_turf(tracking_target))


/mob/camera/aiEye/remote
	name = "Inactive Camera Eye"
	ai_detector_visible = FALSE
	var/move_delay = 0.1 SECONDS// quite fast
	var/tiles_moved = 0 // Tiles moved in 1 direction , used for smart acceleration
	var/max_tile_acceleration = 8 // a limit to how far acceleration can go
	var/cooldown = 0
	var/acceleration = FALSE
	var/mob/living/eye_user = null
	var/obj/machinery/origin
	var/eye_initialized = 0
	var/visible_icon = 0
	var/image/user_image = null


/mob/camera/aiEye/remote/update_remote_sight(mob/living/user)
	user.see_invisible = SEE_INVISIBLE_LIVING
	user.sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS|SEE_BLACKNESS
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


/mob/camera/aiEye/remote/setLoc(atom/target)
	if(!eye_user)
		return
	var/turf/T = get_turf(target)
	if(!T)
		return
	if(T.z != z && use_static)
		GLOB.cameranet.visibility(src, GetViewerClient(), null, use_static)
	dir = get_dir(src, target)
	abstract_move(T)
	if(use_static)
		GLOB.cameranet.visibility(src, GetViewerClient(), null, use_static)
	if(visible_icon && eye_user.client)
		eye_user.client.images -= user_image
		var/atom/top
		for(var/i in loc)
			var/atom/A = i
			if(!top)
				top = loc
			if(is_type_in_typecache(A.type, GLOB.ignored_atoms))
				continue
			if(A.layer > top.layer)
				top = A
			else if(A.plane > top.plane)
				top = A
		user_image = image(icon, top, icon_state, FLY_LAYER)
		eye_user.client.images += user_image


/mob/camera/aiEye/remote/relaymove(mob/user, direct)
	if(istype(origin, /obj/machinery/computer/camera_advanced))
		var/obj/machinery/computer/camera_advanced/CA = origin
		CA.tracking_target = null
	if(cooldown > world.time)
		return
	cooldown = world.time +	move_delay
	if(acceleration)
		cooldown -= tiles_moved * (move_delay/10)
	var/turf/T = get_turf(get_step(src, direct))
	// check for dir change , if we changed then remove all acceleration
	if(get_dir(src, T) != dir)
		tiles_moved = 0
	if(tiles_moved < max_tile_acceleration)
		tiles_moved++
	setLoc(T)


//Version of remote eye that's added to marine HUD. Not visible to xenos but visible to marines
//This one's for CAS
/mob/camera/aiEye/remote/hud
	icon_state = "nothing"
	var/icon_state_on = "cas_camera"
	hud_possible = list(SQUAD_HUD_TERRAGOV)

/mob/camera/aiEye/remote/hud/Initialize()
	. = ..()
	prepare_huds()
	var/datum/atom_hud/squad/squad_hud = GLOB.huds[DATA_HUD_SQUAD_TERRAGOV]
	squad_hud.add_to_hud(src)

	var/image/holder = hud_list[SQUAD_HUD_TERRAGOV]
	if(!holder)
		return
	holder.icon = icon
	holder.icon_state = icon_state_on

//This one's for overwatch/CIC
/mob/camera/aiEye/remote/hud/overwatch
	icon_state_on = "cic_camera"
	///List of current aura defines we're emitting, for overlay purposes
	var/list/current_aura_list = list()

/mob/camera/aiEye/remote/hud/overwatch/Initialize()
	..()
	RegisterSignal(src, COMSIG_AURA_STARTED, .proc/add_emitted_auras)
	RegisterSignal(src, COMSIG_AURA_FINISHED, .proc/remove_emitted_auras)

///Add to our current aura list and update overlays.
/mob/camera/aiEye/remote/hud/overwatch/proc/add_emitted_auras(source, list/new_auras)
	SIGNAL_HANDLER
	current_aura_list += new_auras
	update_aura_overlays()

///Remove from our current aura list and update overlays
/mob/camera/aiEye/remote/hud/overwatch/proc/remove_emitted_auras(source, list/dead_auras)
	SIGNAL_HANDLER
	current_aura_list -= dead_auras
	update_aura_overlays()

///Applies order overlays (hold/move/focus) depending on what we have. Only visible to marines.
/mob/camera/aiEye/remote/hud/overwatch/proc/update_aura_overlays(source, list/new_auras)
	var/image/holder = hud_list[SQUAD_HUD_TERRAGOV]
	if(!holder)
		return
	holder.overlays.Cut()
	for(var/aura_type in current_aura_list)
		holder.overlays += image('icons/mob/hud.dmi', src, "hud[aura_type]")
		holder.overlays += image('icons/mob/hud.dmi', src, "hud[aura_type]aura")


/datum/action/innate/camera_off
	name = "End Camera View"
	background_icon_state = "template2"
	action_icon_state = "camera_off"


/datum/action/innate/camera_off/Activate()
	if(!isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/console = remote_eye.origin
	console.remove_eye_control(target)


/datum/action/innate/camera_jump
	name = "Jump To Camera"
	background_icon_state = "template2"
	action_icon_state = "camera_jump"


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
			T["[C.c_tag][C.can_use() ? "" : " (Deactivated)"]"] = C

	playsound(origin, 'sound/machines/terminal_prompt.ogg', 25, 0)
	var/camera = tgui_input_list(owner, "Choose which camera you want to view?", "Cameras", T)
	var/obj/machinery/camera/C = T[camera]
	playsound(src, "terminal_type", 25, 0)

	if(!C)
		playsound(origin, 'sound/machines/terminal_prompt_deny.ogg', 25, 0)
		return

	playsound(origin, 'sound/machines/terminal_prompt_confirm.ogg', 25, 0)
	remote_eye.setLoc(get_turf(C))
	L.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/noise)
	L.clear_fullscreen("flash", 3)
