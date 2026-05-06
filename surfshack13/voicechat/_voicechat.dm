#define NODE_SERVER_PATH "voicechat/node/server/main.js"
SUBSYSTEM_DEF(voicechat)
	name = "Voice Chat"
	/// faster tick times means smoother proximity. If machine is lagging, increase.
	wait = 3 //300 ms
	flags = SS_KEEP_TIMING
	init_order = INITSTAGE_EARLY
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	//userCodes associated thats been fully confirmed - browser paired and mic perms on
	var/list/vc_clients = list()
	//userCode to clientRef
	var/list/userCode_client_map = alist()
	var/list/client_userCode_map = alist()
	//change with add_rooms and remove_rooms.
	var/list/current_rooms = alist()
	var/list/room_has_proximity = alist()
	// usercode to room
	var/list/userCode_room_map = alist()
	// usercode to mob only really used for the overlays
	var/list/userCode_mob_map = alist()
	// mob to client map, needed for tracking switched mobs
	var/list/mob_client_map = alist()
	// used to manage overlays
	var/list/userCodes_active = list()
	// each speaker per userCode
	var/list/userCodes_speaking_icon = alist()
	// SS_INIT_NO_NEED still sets initialized to true, so we use this instead
	var/actually_initialized = FALSE
/datum/controller/subsystem/voicechat/Initialize()
	. = ..()

	if(!CONFIG_GET(flag/enable_voicechat))
		return SS_INIT_NO_NEED

	if(!test_library())
		message_admins("library test failed cant start voicechat")
		return SS_INIT_FAILURE

	add_rooms(list("living", "ghost"))
	add_rooms(list("lobby"), proximity_mode = FALSE)
	start_node()

	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_ENDED, PROC_REF(on_round_end)) //moves everyone to no prox room at round end.
	actually_initialized = TRUE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/voicechat/proc/restart()
	send_ooc_announcement("Voicechat restarting in a few seconds, please reconnect with join")
	disconnect_all_clients()
	stop_node()
	addtimer(CALLBACK(src, PROC_REF(start_node), 4 SECONDS))

/datum/controller/subsystem/voicechat/proc/on_ice_failed(userCode)
	// if(!userCode)
	// 	CRASH("ice_failed error without usercode {userCode: [userCode || "null"]")
	// var/client/C = userCode_client_map[userCode]
	// message_admins("voicechat peer connection failed for [C || userCode]")
	return


/datum/controller/subsystem/voicechat/proc/start_node()
	var/byond_port = world.port
	var/node_port = CONFIG_GET(number/port_voicechat)
	var/pid = world.process
	if(!byond_port || !node_port || !pid)
		message_admins("missing variable {byond_port:[byond_port], node_port:[node_port], pid:[pid]}")
		return FALSE
	var/cmd = "node [NODE_SERVER_PATH] --node-port=[node_port] --byond-port=[byond_port] --byond-pid=[pid] &"
	var/exit_code = shell(cmd)
	if(exit_code != 0)
		message_admins("launching node failed {exit_code: [exit_code || "null"], cmd: [cmd || "null"]}")
		return FALSE
	else
		return TRUE


/datum/controller/subsystem/voicechat/Shutdown()
	if(actually_initialized)
		disconnect_all_clients()
		stop_node()
		send_ooc_announcement("voicechat stopped")
	. = ..()

/datum/controller/subsystem/voicechat/proc/disconnect_all_clients()
	for(var/userCode in vc_clients)
		disconnect(userCode, from_byond = TRUE)


/datum/controller/subsystem/voicechat/proc/stop_node()
	send_json(alist(cmd= "stop_node"))
	addtimer(CALLBACK(src, PROC_REF(ensure_node_stopped), 3 SECONDS))


/datum/controller/subsystem/voicechat/proc/ensure_node_stopped()
	var/pid = file2text("node.pid")
	if(!pid)
		return TRUE

	message_admins("node failed to shutdown when asked, trying forcefully...")

	var/cmd = "kill [pid]"
	if(world.system_type == MS_WINDOWS)
		cmd = "taskkill /F /PID [pid]"
	var/exit_code = shell(cmd)

	if(exit_code != 0)
		message_admins("killing node failed {exit_code: [exit_code || "null"], cmd: [cmd || "null"]}")
	else
		message_admins("node shutdown forcefully")
		fdel("node.pid")


/datum/controller/subsystem/voicechat/fire()
	send_locations()

/datum/controller/subsystem/voicechat/proc/on_node_start()
	return

/datum/controller/subsystem/voicechat/proc/add_rooms(list/rooms, proximity_mode = TRUE)
	if(!islist(rooms))
		rooms = list(rooms)
	rooms.Remove(current_rooms) //remove existing rooms
	for(var/room in rooms)
		if(isnum(room))
			continue
		current_rooms[room] = list()
		room_has_proximity[room] = proximity_mode


/datum/controller/subsystem/voicechat/proc/remove_rooms(list/rooms)
	if(!islist(rooms))
		rooms = list(rooms)
	rooms &= current_rooms //remove nonexistant rooms
	for(var/room in rooms)
		for(var/userCode in current_rooms[room])
			userCode_room_map[userCode] = null
		current_rooms.Remove(room)
		room_has_proximity.Remove(room)

/// remove user from room
/datum/controller/subsystem/voicechat/proc/clear_userCode(userCode)
	var/own_room = userCode_room_map[userCode]
	if(own_room)
		current_rooms[own_room] -= userCode

	userCode_room_map[userCode] = null

/datum/controller/subsystem/voicechat/proc/move_userCode_to_room(userCode, room)
	if(!room || !current_rooms.Find(room))
		return

	var/own_room = userCode_room_map[userCode]
	if(own_room)
		current_rooms[own_room] -= userCode

	userCode_room_map[userCode] = room
	current_rooms[room] += userCode
	message_admins("move to room worked {room: [userCode_room_map[userCode] || "null"]}")


/datum/controller/subsystem/voicechat/proc/link_userCode_client(userCode, client)
	if(!client|| !userCode)
		// CRASH("{userCode: [userCode || "null"], client: [client  || "null"]}")
		return
	userCode_client_map[userCode] = client
	client_userCode_map[client] = userCode

// faster the better
/datum/controller/subsystem/voicechat/proc/send_locations()
	var/list/packet = list(cmd = "loc")
	var/locs_sent = 0

	for(var/userCode in vc_clients)
		var/client/C = userCode_client_map[userCode]
		var/room =  userCode_room_map[userCode]
		if(!room || !C)
			continue
		var/mob/M = C.mob
		if(!M)
			continue
		if(room_has_proximity[room])
			var/turf/T = get_turf(M)
			var/localroom = "[T.z]_[room]"
			if(!packet[localroom])
				packet[localroom] = list()
			packet[localroom][userCode] = list(T.x, T.y)
		else
			var/room_noprox = room + "_noprox"
			if(!packet[room_noprox])
				packet[room_noprox] = list()
			packet[room_noprox][userCode] = list(1, 1) //very hacky bismallah

		locs_sent ++

	if(!locs_sent) //dont send empty packets
		return
	send_json(packet)


/datum/controller/subsystem/voicechat/proc/on_round_end()
	for(var/userCode in vc_clients)
		move_userCode_to_room(userCode, "lobby")

#undef NODE_SERVER_PATH
