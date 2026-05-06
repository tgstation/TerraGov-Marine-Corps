/datum/controller/subsystem/voicechat/proc/join_vc(client/C, external=FALSE)
	if(!C)
		return
	RegisterSignal(C, COMSIG_TOPIC, PROC_REF(voicechat_topic), override=TRUE)
	C << browse({"
	<html><h4>If this window doesnt close briefly, something is broken</h4>
	<script>window.location.href += `?src=[ref(src)];origin=${window.location.origin};external=[external]`</script></html>
	"},"window=origin_locator")
	///join_vc -> Topic -> open_vc

/datum/controller/subsystem/voicechat/proc/voicechat_topic(atom/source, mob/user, href_list)
	var/client/C = user.client
	if(href_list["origin"])
		C << browse(null, "window=origin_locator")
		UnregisterSignal(C, COMSIG_TOPIC)
		open_vc(C, href_list["origin"], href_list["external"])

/datum/controller/subsystem/voicechat/proc/generate_userCode(client/C)
	if(!C)
		// CRASH("no client")
		return
	. = copytext(md5("[C.computer_id][C.address][rand()]"),-4)
	//ensure unique
	while(. in userCode_client_map)
		. = copytext(md5("[C.computer_id][C.address][rand()]"),-4)
	return .

// Connects a client to voice chat via an external browser
/datum/controller/subsystem/voicechat/proc/open_vc(client/C, origin, external)
	if(!C || !origin)
		return
	// Disconnect existing session if present
	var/existing_userCode = client_userCode_map[C]
	if(existing_userCode)
		disconnect(existing_userCode, from_byond = TRUE)
	// Generate unique session and user codes
	var/sessionId = md5("[world.time][rand()][world.realtime][rand(0,9999)][C.address][C.computer_id]")
	var/userCode = generate_userCode(C)
	// "deliver" voicechat assets
	C << browse_rsc('voicechat/node/public/voicechat.html')
	C << browse_rsc('voicechat/node/public/voicechat.js')
	C << browse_rsc('voicechat/node/public/style.css')
	C << browse_rsc('voicechat/node/public/stopclown.png')
	C << browse_rsc('voicechat/node/public/socketio.js')
	C << browse_rsc('voicechat/node/public/megaphone.png')
	C << browse_rsc('voicechat/node/public/fastclown.gif')

	// opens voicechat
	var/node_port = CONFIG_GET(number/port_voicechat)
	var/web_link = "[origin]/voicechat.html?sessionId=[sessionId]&socket_address=[world.internet_address]:[node_port]"
	if(text2num(external))
		C << browse("<html><h4>[web_link]</h4><p>Paste into a browser that supports webRTC (firefox is recommended).</p></html>", "window=voicechat_help")
	else
		C << link(web_link)

	send_json(alist(
		cmd = "register",
		userCode = userCode,
		sessionId = sessionId
	))

	// Link client to userCode
	userCode_client_map[userCode] = C
	client_userCode_map[C] = userCode
	// Confirmation handled in confirm_usekrCode


// Confirms userCode when browser and mic access are granted
/datum/controller/subsystem/voicechat/proc/confirm_userCode(userCode)
	if(!userCode || (userCode in vc_clients))
		return
	var/client/C = userCode_client_map[userCode]
	var/mob/M = C.mob
	if(!C || !M)
		disconnect(userCode)
		return
	mob_client_map[M] = C

	vc_clients += userCode
	register_mob_signals(M)
	check_mob_conditions(M)
	RegisterSignal(C, COMSIG_QDELETING, PROC_REF(on_client_leaving_game))

/// the big ugly.
/datum/controller/subsystem/voicechat/proc/register_mob_signals(mob/M)
	SIGNAL_HANDLER
	// whenever client switches to a different mob, setup signals
	RegisterSignal(M, COMSIG_MOB_LOGOUT, PROC_REF(on_mob_changed))

	if(isliving(M))
		RegisterSignals(M, list(\
			SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT),
			SIGNAL_ADDTRAIT(TRAIT_MUTE),
			), PROC_REF(clear_from_room))
		RegisterSignals(M, list(\
			SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT),
			SIGNAL_REMOVETRAIT(TRAIT_MUTE),
			), PROC_REF(add_to_room))

		RegisterSignal(M, COMSIG_MOB_DEATH, PROC_REF(on_mob_death))
		RegisterSignal(M, COMSIG_MOB_REVIVE, PROC_REF(on_mob_revive))
		RegisterSignal(M, COMSIG_EAR_DAMAGE_CHANGED, PROC_REF(on_mob_ear_damaged))

/datum/controller/subsystem/voicechat/proc/on_mob_changed(mob/M)
	var/client/C = mob_client_map[M]
	var/mob/new_mob = C.mob
	if(!C || !new_mob)
		return

	mob_client_map.Remove(M)
	mob_client_map[new_mob] = C
	unregister_mob_signals(M)

	register_mob_signals(new_mob)
	check_mob_conditions(new_mob)

/datum/controller/subsystem/voicechat/proc/unregister_mob_signals(mob/M)
	UnregisterSignal(M, COMSIG_MOB_LOGOUT)
	if(isliving(M))
		UnregisterSignal(M, list(\
			SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT),
			SIGNAL_ADDTRAIT(TRAIT_MUTE),
			SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT),
			SIGNAL_REMOVETRAIT(TRAIT_MUTE),
			COMSIG_MOB_DEATH,
			COMSIG_MOB_REVIVE,
			COMSIG_EAR_DAMAGE_CHANGED,
		))


/datum/controller/subsystem/voicechat/proc/clear_from_room(mob/M)
	SIGNAL_HANDLER
	if(!M)
		// CRASH("signal called without user {usr: [usr || "null"]}")
		return
	var/client/C = M.client
	var/userCode = client_userCode_map[C]
	if(!C || !userCode)
		return
	clear_userCode(userCode)

/datum/controller/subsystem/voicechat/proc/add_to_room(mob/M)
	SIGNAL_HANDLER
	if(!M)
		// CRASH("signal called without user {usr: [usr || "null"]}")
		return
	var/client/C = M.client
	var/userCode = client_userCode_map[C]
	if(!C || !userCode)
		return
	move_userCode_to_room(userCode, "living")

/datum/controller/subsystem/voicechat/proc/on_mob_death(mob/M)
	SIGNAL_HANDLER
	check_mob_conditions(M)

/datum/controller/subsystem/voicechat/proc/on_mob_revive(mob/M)
	SIGNAL_HANDLER
	check_mob_conditions(M)

/datum/controller/subsystem/voicechat/proc/on_mob_ear_damaged(mob/M, ear_deaf)
	SIGNAL_HANDLER
	check_mob_conditions(M, ear_deaf)

/datum/controller/subsystem/voicechat/proc/check_mob_conditions(mob/M, ear_deaf)
	if(!M)
		return

	var/client/C = M.client
	var/userCode = client_userCode_map[C]

	if(!C || !userCode)
		return



	var/room

	// everyone goes to no prox to yell at each other at round end and round start.
	if(isnewplayer(M) || SSticker.current_state == GAME_STATE_FINISHED)
		room = "lobby"

	else if(isdead(M) || M.stat == DEAD)
		room = "ghost"

	else if(isliving(M))
		if(ear_deaf || HAS_TRAIT(M, TRAIT_KNOCKEDOUT) || HAS_TRAIT(M, TRAIT_MUTE))
			clear_from_room(M)
		else
			room = "living"

	if(room && userCode_room_map[userCode] != room)
		move_userCode_to_room(userCode, room)
		//for lobby chat as ticker isnt intialized.
		if(SSticker.current_state < GAME_STATE_PLAYING)
			send_locations()

/datum/controller/subsystem/voicechat/proc/on_client_leaving_game(client/C)
	var/userCode = client_userCode_map[C]
	disconnect(userCode, from_byond = TRUE)

// Disconnects a user from voice chat
/datum/controller/subsystem/voicechat/proc/disconnect(userCode, from_byond = FALSE)
	if(!userCode)
		return
	toggle_active(userCode, FALSE)
	clear_userCode(userCode)

	var/client/C = userCode_client_map[userCode]
	if(C)
		userCode_client_map.Remove(userCode)
		client_userCode_map.Remove(C)
		userCode_room_map.Remove(userCode)
		vc_clients -= userCode

	var/mob/M = C.mob

	if(userCodes_speaking_icon[userCode])
		if(C && M)
			M.cut_overlay(userCodes_speaking_icon[userCode])
			unregister_mob_signals(M)

	if(from_byond)
		send_json(alist(cmd= "disconnect", userCode= userCode))
	//for lobby chat

	if(SSticker.current_state < GAME_STATE_PLAYING)
		send_locations()



// Toggles the speaker overlay for a user
/datum/controller/subsystem/voicechat/proc/toggle_active(userCode, is_active)
	if(!userCode || isnull(is_active))
		return
	var/client/C = userCode_client_map[userCode]

	if(!C || !C.mob)
		return
	var/mob/M = C.mob
	var/image/speaker
	if(!userCodes_speaking_icon[userCode])
		speaker = image('icons/mob/effects/talk.dmi', icon_state = "voice")
		speaker.alpha = 200
		userCodes_speaking_icon[userCode] = speaker
	else
		speaker = userCodes_speaking_icon[userCode]

	var/mob/old_mob = userCode_mob_map[userCode]
	if(M != old_mob)
		if(old_mob)
			old_mob.overlays -= speaker
		userCode_mob_map[userCode] = M

	var/room = userCode_room_map[userCode]

	//stat is used to ensure dead people dont have talking overlays
	if(is_active && room && !M.stat)
		userCodes_active |= userCode
		M.add_overlay(speaker)
	else
		userCodes_active -= userCode
		M.cut_overlay(speaker)


// Mutes or deafens a user's microphone
/datum/controller/subsystem/voicechat/proc/mute_mic(client/C, deafen = FALSE)
	if(!C)
		return
	var/userCode = client_userCode_map[C]
	if(!userCode)
		return
	send_json(list(
		cmd = deafen ? "deafen" : "mute_mic",
		userCode = userCode
	))

