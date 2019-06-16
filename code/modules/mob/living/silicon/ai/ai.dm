/mob/living/silicon/ai
	name = "AI"
	real_name = "AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai"
	anchored = TRUE
	density = TRUE
	canmove = FALSE
	job = "AI"
	status_flags = CANSTUN|CANKNOCKOUT
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	hud_type = /datum/hud/ai

	var/list/available_networks = list("marinemainship", "marine", "dropship1", "dropship2")
	var/obj/machinery/camera/current

	var/mob/camera/aiEye/eyeobj
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1

	var/multicam_on = FALSE
	var/obj/screen/movable/pic_in_pic/ai/master_multicam
	var/list/multicam_screens = list()
	var/list/all_eyes = list()
	var/max_multicams = 6

	var/tracking = FALSE
	var/last_paper_seen = 0
	var/last_announcement = 0

	var/icon/holo_icon //Default is assigned when AI is created.
	var/list/datum/AI_Module/current_modules = list()

	var/control_disabled = FALSE

	var/camera_light_on = FALSE
	var/list/obj/machinery/camera/lit_cameras = list()

	var/datum/trackable/track


/mob/living/silicon/ai/Initialize(mapload, ...)
	. = ..()

	track = new(src)
	builtInCamera = new(src)
	builtInCamera.network = list("marinemainship")

	holo_icon = getHologramIcon(icon('icons/mob/AI.dmi', "holo1"))

	create_eye()

	GLOB.ai_list += src


/mob/living/silicon/ai/Destroy()
	GLOB.ai_list -= src
	QDEL_NULL(builtInCamera)
	QDEL_NULL(track)
	return ..()


/mob/living/silicon/ai/restrained(ignore_grab)
	return FALSE


/mob/living/silicon/ai/incapacitated(ignore_restraints)
	if(control_disabled)
		return TRUE
	return ..()


/mob/living/silicon/ai/resist()
	return


/mob/living/silicon/ai/emp_act(severity)
	. = ..()

	if(prob(30)) 
		view_core()


/mob/living/silicon/ai/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(usr != src || incapacitated())
		return

	if(href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"]) in GLOB.cameranet.cameras)

	else if(href_list["track"])
		var/string = href_list["track"]
		trackable_mobs()
		var/list/trackeable = list()
		trackeable += track.humans + track.others
		var/list/target = list()
		for(var/I in trackeable)
			var/mob/M = trackeable[I]
			if(M.name == string)
				target += M
		if(name == string)
			target += src
		if(!length(target))
			to_chat(src, "<span class='warning'>Target is not on or near any active cameras on the station.</span>")
			return

		ai_actual_track(pick(target))
			

/mob/living/silicon/ai/proc/switchCamera(obj/machinery/camera/C)
	if(QDELETED(C))
		return FALSE

	if(!tracking)
		cameraFollow = null

	if(QDELETED(eyeobj))
		view_core()
		return

	eyeobj.setLoc(get_turf(C))
	return TRUE


/mob/living/silicon/ai/proc/toggle_camera_light()
	if(camera_light_on)
		for(var/obj/machinery/camera/C in lit_cameras)
			C.SetLuminosity(0)
			lit_cameras = list()
		to_chat(src, "<span class='notice'>Camera lights deactivated.</span>")
	else
		light_cameras()
		to_chat(src, "<span class='notice'>Camera lights activated.</span>")
	camera_light_on = !camera_light_on


/mob/living/silicon/ai/proc/light_cameras()
	var/list/obj/machinery/camera/add = list()
	var/list/obj/machinery/camera/remove = list()
	var/list/obj/machinery/camera/visible = list()
	for(var/datum/camerachunk/CC in eyeobj.visibleCameraChunks)
		for(var/obj/machinery/camera/C in CC.cameras)
			if(!C.can_use() || get_dist(C, eyeobj) > 7 || !C.internal_light)
				continue
			visible |= C

	add = visible - lit_cameras
	remove = lit_cameras - visible

	for(var/obj/machinery/camera/C in remove)
		lit_cameras -= C //Removed from list before turning off the light so that it doesn't check the AI looking away.
		C.Togglelight(0)
		
	for(var/obj/machinery/camera/C in add)
		C.Togglelight(1)
		lit_cameras |= C


/mob/living/silicon/ai/proc/camera_visibility(mob/camera/aiEye/moved_eye)
	GLOB.cameranet.visibility(moved_eye, client, all_eyes, USE_STATIC_OPAQUE)


/mob/living/silicon/ai/proc/relay_speech(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	raw_message = lang_treat(speaker, message_language, raw_message, spans, message_mode)
	var/start = "Relayed Speech: "
	var/namepart = "[speaker.GetVoice()][speaker.get_alt_name()]"
	var/hrefpart = "<a href='?src=[REF(src)];track=[html_encode(namepart)]'>"
	var/jobpart

	if(iscarbon(speaker))
		var/mob/living/carbon/S = speaker
		if(S.job)
			jobpart = "[S.job]"
	else
		jobpart = "Unknown"

	var/rendered = "<i><span class='game say'>[start]<span class='name'>[hrefpart][namepart] ([jobpart])</a> </span><span class='message'>[raw_message]</span></span></i>"

	show_message(rendered, 2)


/mob/living/silicon/ai/reset_perspective(atom/A)
	if(camera_light_on)
		light_cameras()
	if(istype(A, /obj/machinery/camera))
		current = A
	if(client)
		if(ismovableatom(A))
			if(A != GLOB.ai_camera_room_landmark)
				end_multicam()
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			end_multicam()
			if(isturf(loc))
				if(eyeobj)
					client.eye = eyeobj
					client.perspective = EYE_PERSPECTIVE
				else
					client.eye = client.mob
					client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
		update_sight()
		if(client.eye != src)
			var/atom/AT = client.eye
			AT.get_remote_view_fullscreens(src)
		else
			clear_fullscreen("remote_view", 0)


/mob/living/silicon/ai/Stat()
	. = ..()

	if(statpanel("Status"))
	
		if(stat != CONSCIOUS)
			stat(null, text("Systems nonfunctional"))
			return

		stat(null, text("System integrity: [(health + 100) / 2]%"))


/mob/living/silicon/ai/canUseTopic(atom/movable/AM, proximity, dexterity)
	if(control_disabled || incapacitated())
		to_chat(src, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	if(proximity && !in_range(AM, src))
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	return can_see(AM)


/mob/living/silicon/ai/fully_replace_character_name(oldname, newname)
	. = ..()

	if(oldname == newname)
		return

	if(eyeobj)
		eyeobj.name = "[newname] (AI Eye)"


/mob/living/silicon/ai/forceMove(atom/destination)
	. = ..()
	if(.)
		end_multicam()