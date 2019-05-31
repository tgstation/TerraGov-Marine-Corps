/mob/living/silicon/ai
	name = "AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai"
	anchored = TRUE
	density = TRUE
	canmove = FALSE
	job = "AI"
	status_flags = CANSTUN|CANKNOCKOUT
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS

	var/list/network = list("marinemainship", "marine", "dropship1", "dropship2")
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

	var/datum/trackable/track = new

	var/datum/announcement/priority/announcement


/mob/living/silicon/ai/Initialize(mapload, ...)
	. = ..()

	builtInCamera = new(src)
	builtInCamera.network = list("marinemainship", "marine", "dropship1", "dropship2")

	announcement = new()
	announcement.title = "A.I. Announcement"
	announcement.announcement_type = "A.I. Announcement"

	holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))

	GLOB.ai_list += src


/mob/living/silicon/ai/Destroy()
	GLOB.ai_list -= src
	QDEL_NULL(builtInCamera)
	QDEL_NULL(announcement)
	return ..()


/mob/living/silicon/ai/verb/pick_icon()
	set category = "AI Commands"
	set name = "AI Core Display"

	if(incapacitated())
		return

	var/list/iconstates = GLOB.ai_core_display_screens
	for(var/option in iconstates)
		if(option == "Random")
			iconstates[option] = image(icon = src.icon, icon_state = "ai-random")
			continue
		iconstates[option] = image(icon = src.icon, icon_state = resolve_ai_icon(option))

	view_core()

	var/ai_core_icon = input(src, "Choose your AI core display icon.", "AI Core Display", iconstates) as null|anything in iconstates
	if(!ai_core_icon || incapacitated())
		return

	icon_state = resolve_ai_icon(ai_core_icon)


/mob/living/silicon/ai/verb/ai_announcement()
	set category = "AI Commands"
	set name = "Make Announcement"

	if(incapacitated() || last_announcement < world.time + 60 SECONDS)
		return

	var/input = stripped_input(usr, "Please write a message to announce to the station crew.", "A.I. Announcement")
	if(!input || incapacitated())
		return

	announcement.Announce(input)
	last_announcement = world.time


/mob/living/silicon/ai/restrained()
	return FALSE


/mob/living/silicon/ai/emp_act(severity)
	if(prob(30)) 
		view_core()
	return ..()


/mob/living/silicon/ai/Topic(href, href_list)
	if(usr != src || incapacitated())
		return

	. = ..()

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


/mob/living/silicon/ai/cancel_camera()
	set category = "AI Commands"
	set name = "Cancel Camera View"

	view_core()


/mob/living/silicon/ai/verb/ai_network_change()
	set category = "AI Commands"
	set name = "Jump To Network"

	unset_interaction()
	cameraFollow = null
	var/cameralist[0]

	if(incapacitated())
		return

	var/mob/living/silicon/ai/U = usr

	for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		var/list/tempnetwork = C.network
		if(!(is_station_level(C.z) || is_mining_level(C.z) || ("ss13" in tempnetwork)))
			continue
		if(!C.can_use())
			continue

		if(length(tempnetwork))
			for(var/i in C.network)
				cameralist[i] = i

	var/old_network = network
	network = input(U, "Which network would you like to view?") as null|anything in cameralist

	if(!U.eyeobj)
		U.view_core()
		return

	if(isnull(network))
		network = old_network // If nothing is selected
	else
		for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
			if(!C.can_use())
				continue
			if(network in C.network)
				U.eyeobj.setLoc(get_turf(C))
				break
	to_chat(src, "<span class='notice'>Switched to the \"[uppertext(network)]\" camera network.</span>")


/mob/living/silicon/ai/verb/ai_statuschange()
	set category = "AI Commands"
	set name = "Display Status"

	if(incapacitated())
		return

	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "BSOD", "Blank", "Problems?", "Awesome", "Facepalm", "Thinking", "Friend Computer", "Dorfy", "Blue Glow", "Red Glow")
	var/emote = input("Please, select a status!", "AI Status", null, null) in ai_emotions
	
	for(var/each in GLOB.ai_status_displays)
		var/obj/machinery/status_display/ai/M = each
		M.emotion = emote
		M.update()
	
	if(emote == "Friend Computer")
		var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

		if(!frequency)
			return

		var/datum/signal/status_signal = new(list("command" = "friendcomputer"))
		frequency.post_signal(src, status_signal)


/mob/living/silicon/ai/verb/ai_hologram_change()
	set category = "AI Commands"
	set name = "Change Hologram"

	if(incapacitated())
		return

	var/input
	switch(input(src, "Would you like to select a hologram based on a crew member, an animal, or switch to a unique avatar?", "Hologram") as null|anything in list("Crew Member", "Unique", "Animal"))
		if("Crew Member")
			var/list/personnel_list = list()

			for(var/datum/data/record/t in GLOB.datacore.general)
				personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["photo_front"]

			if(!length(personnel_list))
				to_chat(src, "<span class='warning'>No suitable records found. Aborting.</span>")

			input = input("Select a crew member:") as null|anything in personnel_list
			var/icon/character_icon = personnel_list[input]
			if(character_icon)
				qdel(holo_icon)//Clear old icon so we're not storing it in memory.
				holo_icon = getHologramIcon(icon(character_icon))

		if("Animal")
			var/list/icon_list = list(
			"bear" = 'icons/mob/animal.dmi',
			"carp" = 'icons/mob/animal.dmi',
			"chicken" = 'icons/mob/animal.dmi',
			"corgi" = 'icons/mob/pets.dmi',
			"cow" = 'icons/mob/animal.dmi',
			"crab" = 'icons/mob/animal.dmi',
			"fox" = 'icons/mob/pets.dmi',
			"goat" = 'icons/mob/animal.dmi',
			"cat" = 'icons/mob/pets.dmi',
			"cat2" = 'icons/mob/pets.dmi',
			"poly" = 'icons/mob/animal.dmi',
			"pug" = 'icons/mob/pets.dmi',
			"spider" = 'icons/mob/animal.dmi'
			)

			input = input("Please select a hologram:") as null|anything in icon_list
			if(input)
				qdel(holo_icon)
				switch(input)
					if("poly")
						holo_icon = getHologramIcon(icon(icon_list[input], "parrot_fly"))
					if("chicken")
						holo_icon = getHologramIcon(icon(icon_list[input], "chicken_brown"))
					if("spider")
						holo_icon = getHologramIcon(icon(icon_list[input], "guard"))
					else
						holo_icon = getHologramIcon(icon(icon_list[input], input))
		else
			var/list/icon_list = list(
				"default" = 'icons/mob/ai.dmi',
				"floating face" = 'icons/mob/ai.dmi',
				"xeno queen" = 'icons/mob/alien.dmi',
				"horror" = 'icons/mob/ai.dmi'
				)

			input = input("Please select a hologram:") as null|anything in icon_list
			if(input)
				qdel(holo_icon)
				switch(input)
					if("xeno queen")
						holo_icon = getHologramIcon(icon(icon_list[input], "alienq"))
					else
						holo_icon = getHologramIcon(icon(icon_list[input], input))


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
	for (var/datum/camerachunk/CC in eyeobj.visibleCameraChunks)
		for (var/obj/machinery/camera/C in CC.cameras)
			if (!C.can_use() || get_dist(C, eyeobj) > 7 || !C.internal_light)
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


/mob/living/silicon/ai/verb/sensor_mode()
	set category = "AI Commands"
	set name = "Toggle Sensors"

	toggle_sensor_mode()


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