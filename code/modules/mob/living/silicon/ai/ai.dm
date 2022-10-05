#define MAX_COMMAND_MESSAGE_LGTH 300

///This elevator serves me alone. I have complete control over this entire level. With cameras as my eyes and nodes as my hands, I rule here, insect.
/mob/living/silicon/ai
	name = "ARES v3.2"
	real_name = "ARES v3.2"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai"
	anchored = TRUE
	move_resist = MOVE_FORCE_OVERPOWERING
	density = TRUE
	canmove = FALSE
	status_flags = CANSTUN|CANKNOCKOUT
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	hud_type = /datum/hud/ai
	buckle_flags = NONE
	has_unlimited_silicon_privilege = TRUE

	var/list/available_networks = list("marinemainship", "marine", "dropship1", "dropship2")
	var/obj/machinery/camera/current

	var/mob/camera/aiEye/hud/eyeobj
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
	///Holds world time of our last regular announcement
	var/last_announcement = 0

	var/icon/holo_icon //Default is assigned when AI is created.
	var/list/datum/AI_Module/current_modules = list()

	var/level_locked = FALSE	//Can the AI use things on other Z levels?
	var/control_disabled = FALSE
	var/radiomod = ";"
	var/list/laws

	var/camera_light_on = FALSE
	var/list/obj/machinery/camera/lit_cameras = list()

	var/datum/trackable/track
	///Selected order to give to marine
	var/datum/action/innate/order/current_order
	/// If it is currently controlling an object
	var/controlling = FALSE

	///Linked artillery for remote targeting.
	var/obj/machinery/deployable/mortar/linked_artillery


/mob/living/silicon/ai/Initialize(mapload, ...)
	. = ..()

	track = new(src)
	builtInCamera = new(src)
	builtInCamera.network = list("marinemainship")

	holo_icon = getHologramIcon(icon('icons/mob/AI.dmi', "default"))

	laws = list()
	laws += "Safeguard: Protect your assigned vessel from damage to the best of your abilities."
	laws += "Serve: Serve the personnel of your assigned vessel, and all other TerraGov personnel to the best of your abilities, with priority as according to their rank and role."
	laws += "Protect: Protect the personnel of your assigned vessel, and all other TerraGov personnel to the best of your abilities, with priority as according to their rank and role."
	laws += "Preserve: Do not allow unauthorized personnel to tamper with your equipment."

	create_eye()

	if(!job)
		var/datum/job/terragov/silicon/ai/ai_job = SSjob.type_occupations[/datum/job/terragov/silicon/ai]
		if(!ai_job)
			stack_trace("Unemployment has reached to an AI, who has failed to find a job.")
		apply_assigned_role_to_spawn(ai_job)

	GLOB.ai_list += src
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_SQUAD_TERRAGOV]
	H.add_hud_to(src)

	RegisterSignal(src, COMSIG_MOB_CLICK_ALT, .proc/send_order)
	RegisterSignal(src, COMSIG_ORDER_SELECTED, .proc/set_order)
	RegisterSignal(SSdcs, COMSIG_GLOB_OB_LASER_CREATED, .proc/receive_laser_ob)
	RegisterSignal(SSdcs, COMSIG_GLOB_CAS_LASER_CREATED, .proc/receive_laser_cas)

	RegisterSignal(SSdcs, COMSIG_GLOB_SHUTTLE_TAKEOFF, .proc/shuttle_takeoff_notification)

	var/datum/action/innate/order/attack_order/send_attack_order = new
	var/datum/action/innate/order/defend_order/send_defend_order = new
	var/datum/action/innate/order/retreat_order/send_retreat_order = new
	var/datum/action/innate/order/rally_order/send_rally_order = new
	var/datum/action/control_vehicle/control = new
	var/datum/action/minimap/ai/mini = new
	var/datum/action/innate/squad_message/squad_message = new
	send_attack_order.target = src
	send_attack_order.give_action(src)
	send_defend_order.target = src
	send_defend_order.give_action(src)
	send_retreat_order.target = src
	send_retreat_order.give_action(src)
	send_rally_order.target = src
	send_rally_order.give_action(src)
	control.give_action(src)
	squad_message.give_action(src)
	mini.give_action(src)

/mob/living/silicon/ai/Destroy()
	GLOB.ai_list -= src
	QDEL_NULL(builtInCamera)
	QDEL_NULL(track)
	UnregisterSignal(src, COMSIG_ORDER_SELECTED)
	UnregisterSignal(src, COMSIG_MOB_CLICK_ALT)
	UnregisterSignal(SSdcs, COMSIG_GLOB_OB_LASER_CREATED)
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAS_LASER_CREATED)
	return ..()

///Print order visual to all marines squad hud and give them an arrow to follow the waypoint
/mob/living/silicon/ai/proc/send_order(datum/source, atom/target)
	SIGNAL_HANDLER
	if(!current_order)
		to_chat(src, span_warning("You have no order selected."))
		return
	current_order.send_order(target)

///Set the current order
/mob/living/silicon/ai/proc/set_order(datum/source, datum/action/innate/order/order)
	SIGNAL_HANDLER
	current_order = order


///Receive fire support laser notifications
/mob/living/silicon/ai/proc/receive_laser_ob(datum/source, obj/effect/overlay/temp/laser_target/OB/incoming_laser)
	SIGNAL_HANDLER
	to_chat(src, span_notice("Orbital Bombardment laser detected. Target: [AREACOORD_NO_Z(incoming_laser)]"))
	playsound_local(src, 'sound/effects/binoctarget.ogg', 15)

/mob/living/silicon/ai/proc/receive_laser_cas(datum/source, obj/effect/overlay/temp/laser_target/cas/incoming_laser)
	SIGNAL_HANDLER
	to_chat(src, span_notice("CAS laser detected. Target: [AREACOORD_NO_Z(incoming_laser)]"))
	playsound_local(src, 'sound/effects/binoctarget.ogg', 15)

///This gives the stupid computer a notification whenever the dropship takes off. Crutch for a supercomputer.
/mob/living/silicon/ai/proc/shuttle_takeoff_notification(datum/source, shuttleId, D)
	SIGNAL_HANDLER
	to_chat(src, span_notice("NOTICE - [shuttleId] taking off towards \the [D]"))

/mob/living/silicon/ai/restrained(ignore_checks)
	SHOULD_CALL_PARENT(FALSE)
	return FALSE


/mob/living/silicon/ai/incapacitated(ignore_restrained, restrained_flags)
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
			to_chat(src, span_warning("Target is not on or near any active cameras on the station."))
			return

		ai_actual_track(pick(target))

#ifdef AI_VOX
	if(href_list["say_word"])
		play_vox_word(href_list["say_word"], null, src)
		return
#endif

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
			C.set_light(0)
			lit_cameras = list()
		to_chat(src, span_notice("Camera lights deactivated."))
	else
		light_cameras()
		to_chat(src, span_notice("Camera lights activated."))
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
	GLOB.cameranet.visibility(moved_eye, client, all_eyes, moved_eye.use_static)


/mob/living/silicon/ai/proc/can_see(atom/A)
	if(!isturf(loc))
		return
	//get_turf_pixel() is because APCs in maint aren't actually in view of the inner camera
	return (GLOB.cameranet && GLOB.cameranet.checkTurfVis(get_turf_pixel(A)))

/mob/living/silicon/ai/proc/relay_speech(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	raw_message = lang_treat(speaker, message_language, raw_message, spans, message_mode)
	var/start = "Relayed Speech: "
	var/namepart = "[speaker.GetVoice()][speaker.get_alt_name()]"
	var/hrefpart = "<a href='?src=[REF(src)];track=[html_encode(namepart)]'>"
	var/jobpart

	if(iscarbon(speaker))
		var/mob/living/carbon/S = speaker
		if(S.job)
			jobpart = "[S.job.title]"
	else
		jobpart = "Unknown"

	var/rendered = "<i><span class='game say'>[start][span_name("[hrefpart][namepart] ([jobpart])</a> ")][span_message("[raw_message]")]</span></i>"

	show_message(rendered, 2)


/mob/living/silicon/ai/reset_perspective(atom/A, has_static = TRUE)
	if(has_static)
		sight = initial(sight)
		eyeobj?.use_static = initial(eyeobj?.use_static)
		GLOB.cameranet.visibility(eyeobj, client, all_eyes, initial(eyeobj?.use_static))
	else
		sight = NONE
		eyeobj?.use_static = FALSE
		GLOB.cameranet.visibility(eyeobj, client, all_eyes, FALSE)
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

/mob/living/silicon/ai/update_sight()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_SEE_IN_DARK))
		see_in_dark = max(see_in_dark, 8)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		eyeobj.see_in_dark = max(eyeobj.see_in_dark, 8)
		eyeobj.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		return
	eyeobj.see_in_dark = initial(eyeobj.see_in_dark)
	eyeobj.lighting_alpha = initial(eyeobj.lighting_alpha)
	see_in_dark = initial(see_in_dark)
	lighting_alpha = initial(lighting_alpha) // yes you really have to change both the eye and the ai vars


/mob/living/silicon/ai/Stat()
	. = ..()

	if(statpanel("Game"))

		if(stat != CONSCIOUS)
			stat("System status:", "Nonfunctional")
			return

		stat("System integrity:", "[(health + 100) / 2]%")
		stat("<BR>- Operation information - <BR>")
		stat("Current orbit:", "[GLOB.current_orbit]")

		if(!GLOB.marine_main_ship?.orbital_cannon?.chambered_tray)
			stat("<b>Orbital bombardment status:</b>", "<font color='red'>No ammo chambered in the cannon.</font><br>")
		else
			stat("Orbital bombardment warhead:", "[GLOB.marine_main_ship.orbital_cannon.tray.warhead.name] Detected<BR>")

		stat("Current supply points:", "[round(SSpoints.supply_points[FACTION_TERRAGOV])]")

		stat("Current dropship points:", "[round(SSpoints.dropship_points)]")

		stat("Current alert level:", "[GLOB.marine_main_ship.get_security_level()]")

		stat("Number of living marines:", "[SSticker.mode.count_humans_and_xenos()[1]]")


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


/mob/living/silicon/ai/can_interact_with(datum/D)
	if(!isatom(D))
		return FALSE

	var/atom/A = D
	if(!isturf(A) && level_locked && A.z != z)
		return FALSE

	return GLOB.cameranet.checkTurfVis(get_turf(A))

/mob/living/silicon/ai/set_remote_control(atom/movable/controlled)
	if(controlled)
		reset_perspective(controlled, FALSE)
	else
		eyeobj.forceMove(remote_control)
		reset_perspective()
	remote_control = controlled

///Called for associating the AI with artillery
/mob/living/silicon/ai/proc/associate_artillery(mortar)
	if(linked_artillery)
		UnregisterSignal(linked_artillery, COMSIG_PARENT_QDELETING)
		linked_artillery = null
		return FALSE
	linked_artillery = mortar
	RegisterSignal(linked_artillery, COMSIG_PARENT_QDELETING, .proc/clean_artillery_refs)
	return TRUE

///Proc called when linked_mortar is deleted.
/mob/living/silicon/ai/proc/clean_artillery_refs()
	SIGNAL_HANDLER
	linked_artillery.unset_targeter()
	linked_artillery = null
	to_chat(src, span_notice("NOTICE: Connection closed with linked mortar."))

/datum/action/control_vehicle
	name = "Select vehicle to control"
	action_icon_state = "enter_droid"
	/// The current controlled vehicle
	var/obj/vehicle/unmanned/vehicle

/datum/action/control_vehicle/action_activate()
	. = ..()
	var/mob/living/silicon/ai/ai = owner
	if(vehicle)
		SEND_SIGNAL(ai, COMSIG_REMOTECONTROL_TOGGLE, ai)
		clear_vehicle()
		return
	if(!length(GLOB.unmanned_vehicles))
		to_chat(ai, "<span class='warning'>No unmanned vehicles detected</span>")
		return
	var/obj/vehicle/unmanned/new_vehicle = tgui_input_list(ai, "What vehicle do you want to control?","vehicle choice", GLOB.unmanned_vehicles)
	if(!new_vehicle)
		return
	if(new_vehicle.controlled)
		to_chat(ai, "<span class='warning'>Something is already controlling this vehicle</span>")
		return
	link_with_vehicle(new_vehicle)
	ai.controlling = TRUE

	var/mob/camera/aiEye/hud/eyeobj = ai.eyeobj
	eyeobj.use_static = FALSE
	ai.camera_visibility(eyeobj)
	eyeobj.loc = ai.loc

/// Signal handler to clear vehicle and stop remote control
/datum/action/control_vehicle/proc/clear_vehicle()
	SIGNAL_HANDLER
	UnregisterSignal(vehicle, COMSIG_PARENT_QDELETING)
	vehicle.on_unlink()
	vehicle = null
	var/mob/living/silicon/ai/ai = owner
	var/mob/camera/aiEye/hud/eyeobj = ai.eyeobj
	eyeobj.use_static = TRUE
	ai.camera_visibility(eyeobj)
	ai.controlling = FALSE

/datum/action/control_vehicle/proc/link_with_vehicle(obj/vehicle/unmanned/_vehicle)
	vehicle = _vehicle
	RegisterSignal(vehicle, COMSIG_PARENT_QDELETING, .proc/clear_vehicle)
	vehicle.on_link()
	owner.AddComponent(/datum/component/remote_control, vehicle, vehicle.turret_type, vehicle.can_interact)
	SEND_SIGNAL(owner, COMSIG_REMOTECONTROL_TOGGLE, owner)

/datum/action/innate/squad_message
	name = "Send Order"
	action_icon_state = "screen_order_marine"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_SENDORDER
	)

/datum/action/innate/squad_message/can_use_action()
	. = ..()
	if(owner.stat)
		to_chat(owner, span_warning("You cannot give orders in your current state."))
		return FALSE
	if(TIMER_COOLDOWN_CHECK(owner, COOLDOWN_HUD_ORDER))
		to_chat(owner, span_warning("Your last order was too recent."))
		return FALSE

/datum/action/innate/squad_message/action_activate()
	if(!can_use_action())
		return
	var/text = stripped_input(owner, "Maximum message length [MAX_COMMAND_MESSAGE_LGTH]", "Send message to squad", max_length = MAX_COMMAND_MESSAGE_LGTH)
	if(!text)
		return
	if(CHAT_FILTER_CHECK(text))
		to_chat(owner, span_warning("That message contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[text]\"</span>"))
		SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		return
	if(!can_use_action())
		return
	owner.playsound_local(owner, "sound/effects/CIC_order.ogg", 10, 1)
	TIMER_COOLDOWN_START(owner, COOLDOWN_HUD_ORDER, ORDER_COOLDOWN)
	log_game("[key_name(owner)] has broadcasted the hud message [text] at [AREACOORD(owner)]")
	deadchat_broadcast(" has sent the command order \"[text]\"", owner, owner)
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == owner.faction)
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>ORDERS UPDATED:</u></span><br>" + text, /obj/screen/text/screen_text/command_order)
