/mob/living/silicon/hivemind
	name = "hivemind"
	verb_say = "states"
	verb_ask = "ponders"
	verb_exclaim = "declares"
	verb_yell = "exclaims"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai"
	anchored = TRUE
	density = TRUE
	canmove = FALSE
	job = "AI"
	status_flags = CANSTUN|CANKNOCKOUT
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	hud_type = /datum/hud/ai
	buckle_flags = NONE

	var/datum/hive_status/hive

	var/default_network = "xeno"
	var/list/available_networks = list("xeno")
	var/obj/effect/alien/weeds/node/current

	var/mob/camera/aiEye/eyeobj
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = FALSE

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

	var/level_locked = TRUE
	var/control_disabled = FALSE
	var/radiomod = ";"
	var/list/laws

	var/list/effect/alien/weeds/node/lit_cameras = list()

	var/datum/trackable/track

/mob/living/silicon/hivemind/Initialize(mapload, ...)
	. = ..()

	track = new(src)
	builtInCamera = new(src)
	builtInCamera.network = list(default_network)

	holo_icon = getHologramIcon(icon('icons/mob/AI.dmi', "holo1"))

	create_eye()

	GLOB.ai_list += src

/mob/living/silicon/hivemind/Destroy()
	GLOB.ai_list -= src
	QDEL_NULL(builtInCamera)
	QDEL_NULL(track)
	return ..()

/mob/living/silicon/hivemind/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(usr != src || incapacitated())
		return

	if(href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"]) in GLOB.xenonet.cameras)

	else if(href_list["track"])
		to_chat(world, "TODO")
		// var/string = href_list["track"]
		// trackable_mobs()
		// var/list/trackeable = list()
		// trackeable += track.humans + track.others
		// var/list/target = list()
		// for(var/I in trackeable)
		// 	var/mob/M = trackeable[I]
		// 	if(M.name == string)
		// 		target += M
		// if(name == string)
		// 	target += src
		// if(!length(target))
		// 	to_chat(src, "<span class='warning'>Target is not on or near any active cameras on the station.</span>")
		// 	return

		// ai_actual_track(pick(target))


/mob/living/silicon/hivemind/proc/switchCamera(obj/effect/alien/weeds/node/C)
	if(QDELETED(C))
		return FALSE

	if(!tracking)
		cameraFollow = null

	if(QDELETED(eyeobj))
		to_chat(world, "view core?")
		return

	eyeobj.setLoc(get_turf(C))
	return TRUE


/mob/living/silicon/hivemind/proc/camera_visibility(mob/camera/aiEye/moved_eye)
	GLOB.xenonet.visibility(moved_eye, client, all_eyes, USE_STATIC_OPAQUE)


/mob/living/silicon/hivemind/proc/relay_speech(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
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


/mob/living/silicon/hivemind/reset_perspective(atom/A)
	if(istype(A, /obj/effect/alien/weeds/node))
		current = A
	if(client)
		if(ismovableatom(A))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
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


/mob/living/silicon/hivemind/Stat()
	. = ..()

	if(statpanel("Game"))

		if(stat != CONSCIOUS)
			stat("System status:", "Nonfunctional")
			return

		stat("System integrity:", "[(health + 100) / 2]%")


/mob/living/silicon/hivemind/fully_replace_character_name(oldname, newname)
	. = ..()

	if(oldname == newname)
		return

	if(eyeobj)
		eyeobj.name = "[newname] (AI Eye)"



/mob/living/silicon/hivemind/can_interact_with(datum/D)
	return FALSE
	if(!isatom(D))
		return FALSE

	var/atom/A = D
	if(level_locked && A.z != z)
		return FALSE

	return GLOB.xenonet.checkTurfVis(get_turf(A))



/* Resistances */
/mob/living/silicon/hivemind/restrained(ignore_checks)
	return FALSE


/mob/living/silicon/hivemind/incapacitated(ignore_restrained, restrained_flags)
	if(control_disabled)
		return TRUE
	return ..()


/mob/living/silicon/hivemind/resist()
	return


/mob/living/silicon/hivemind/emp_act(severity)
	. = ..()

	if(prob(30))
		to_chat(world, "view core?")