// AI EYE
//
// An invisible (no icon) mob that the AI controls to look around the station with.
// It streams chunks as it moves around, which will show it what the AI can and cannot see.
/mob/camera/aiEye
	name = "Inactive AI Eye"
	icon_state = "ai_camera"
	icon = 'icons/mob/cameramob.dmi'
	invisibility = INVISIBILITY_MAXIMUM
	var/mob/living/silicon/ai/ai = null
	var/relay_speech = TRUE

/mob/camera/aiEye/Initialize(mapload, cameranet, new_faction)
	. = ..()
	GLOB.aiEyes += src
	setLoc(loc, TRUE)

/mob/camera/aiEye/Destroy()
	ai = null
	return ..()

//Version the normal aiEye that's added to squad HUDs. Visible to marines, not visible to xenos. CAS does this too.
//This is the one actually used by AI in ai.dm
/mob/camera/aiEye/hud
	icon_state = "nothing"
	var/icon_state_on = "ai_camera"
	hud_possible = list(SQUAD_HUD_TERRAGOV)

/mob/camera/aiEye/hud/Initialize(mapload)
	. = ..()
	prepare_huds()
	var/datum/atom_hud/squad/squad_hud = GLOB.huds[DATA_HUD_SQUAD_TERRAGOV]
	squad_hud.add_to_hud(src)

	var/image/holder = hud_list[SQUAD_HUD_TERRAGOV]
	if(!holder)
		return
	holder.icon = icon
	holder.icon_state = icon_state_on
	hud_list[hud_type] = holder

/mob/camera/aiEye/hud/Destroy()
	var/datum/atom_hud/squad/squad_hud = GLOB.huds[DATA_HUD_SQUAD_TERRAGOV]
	squad_hud.remove_from_hud(src)
	return ..()

/mob/camera/aiEye/proc/get_visible_turfs()
	if(!isturf(loc))
		return list()
	var/client/C = GetViewerClient()
	var/view = C ? getviewsize(C.view) : getviewsize(WORLD_VIEW)
	var/turf/lowerleft = locate(max(1, x - (view[1] - 1)/2), max(1, y - (view[2] - 1)/2), z)
	var/turf/upperright = locate(min(world.maxx, lowerleft.x + (view[1] - 1)), min(world.maxy, lowerleft.y + (view[2] - 1)), lowerleft.z)
	return block(lowerleft, upperright)


// Use this when setting the aiEye's location.
// It will also stream the chunk that the new loc is in.
/mob/camera/aiEye/proc/setLoc(T, force_update = FALSE)
	if(!ai)
		return

	if(!isturf(ai.loc))
		return
	T = get_turf(T)
	if(!force_update && T == get_turf(src))
		return //we are already here!
	if(T)
		abstract_move(T)
	else
		moveToNullspace()
	if(use_static)
		ai.camera_visibility(src)
	if(ai.client && !ai.multicam_on)
		ai.client.set_eye(src)
	//Holopad
	if(istype(ai.current, /obj/machinery/holopad))
		var/obj/machinery/holopad/H = ai.current
		H.move_hologram(ai, T)
	if(ai.camera_light_on)
		ai.light_cameras()
	if(ai.master_multicam)
		ai.master_multicam.refresh_view()
	update_parallax_contents()


/mob/camera/aiEye/Move(atom/newloc, direction, glide_size_override)
	return FALSE


/mob/camera/aiEye/GetViewerClient()
	return ai?.client


/mob/camera/aiEye/Destroy()
	if(ai)
		ai.all_eyes -= src
		ai = null
	GLOB.aiEyes -= src
	return ..()


/atom/proc/move_camera_by_click()
	if(!isAI(usr))
		return

	var/mob/living/silicon/ai/AI = usr
	if(AI.eyeobj && (AI.multicam_on || (AI.client.eye == AI.eyeobj)) && (AI.eyeobj.z == z))
		AI.cameraFollow = null
		if(isturf(loc) || isturf(src))
			AI.eyeobj.setLoc(src)


// This will move the AIEye. It will also cause lights near the eye to light up, if toggled.
// This is handled in the proc below this one.
/client/proc/AIMove(n, direct, mob/living/silicon/ai/user)
	var/initial = initial(user.sprint)
	var/max_sprint = 50

	if(user.cooldown && user.cooldown < world.timeofday) // 3 seconds
		user.sprint = initial

	for(var/i = 0; i < max(user.sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(user.eyeobj, direct))
		if(step)
			user.eyeobj.setLoc(step)

	user.cooldown = world.timeofday + 5
	if(user.acceleration)
		user.sprint = min(user.sprint + 0.5, max_sprint)
	else
		user.sprint = initial

	if(!user.tracking)
		user.cameraFollow = null


// Return to the Core.
/mob/living/silicon/ai/proc/view_core()
	if(istype(current, /obj/machinery/holopad))
		var/obj/machinery/holopad/H = current
		H.clear_holo(src)
	else
		current = null
	cameraFollow = null

	unset_interaction()

	if(isturf(loc) && (QDELETED(eyeobj) || !eyeobj.loc))
		to_chat(src, "ERROR: Eyeobj not found. Creating new eye...")
		create_eye()

	eyeobj?.setLoc(loc)


/mob/living/silicon/ai/proc/create_eye()
	if(!QDELETED(eyeobj))
		return
	eyeobj = new /mob/camera/aiEye/hud()
	all_eyes += eyeobj
	eyeobj.ai = src
	eyeobj.setLoc(loc)
	eyeobj.name = "[name] (AI Eye)"
	eyeobj.real_name = eyeobj.name
	mini.override_locator(eyeobj)
	set_eyeobj_visible(TRUE)


/mob/living/silicon/ai/proc/set_eyeobj_visible(state = TRUE)
	if(!eyeobj)
		return
	eyeobj.mouse_opacity = state ? MOUSE_OPACITY_ICON : initial(eyeobj.mouse_opacity)
	eyeobj.invisibility = state ? INVISIBILITY_OBSERVER : initial(eyeobj.invisibility)


/mob/camera/aiEye/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if(relay_speech && speaker && ai && !radio_freq && speaker != ai && near_camera(speaker))
		ai.relay_speech(message, speaker, message_language, raw_message, radio_freq, spans, message_mode)

/mob/camera/aiEye/playsound_local(turf/turf_source, soundin, vol, vary, frequency, falloff, is_global, channel, sound/sound_to_use, distance_multiplier)
	if((istype(parent_cameranet) && !parent_cameranet.checkTurfVis(get_turf(src))) || !ai)
		return
	/*
	What is happening here is we are looking to find the position of the sound source relative to the camera eye
	and using it to get a turf in the same relative position to the AI core in order to properly simulate the
	direction and volume of where the sound is coming from.
	*/
	var/turf/playturf = locate(ai.x + (turf_source.x - x), ai.y + (turf_source.y - y), ai.z)
	ai?.playsound_local(playturf, soundin, vol, vary, frequency, falloff, is_global, channel, sound_to_use, distance_multiplier)
