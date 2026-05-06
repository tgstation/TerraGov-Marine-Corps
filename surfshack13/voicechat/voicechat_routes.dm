//uncomment to show traffic
// #define LOG_TRAFFIC
#define VOICECHAT_LIB_PATH  "voicechat/pipes/unix/byondsocket"

/datum/controller/subsystem/voicechat/proc/test_library()
	var/text = "hello word"
	var/out = call_ext(VOICECHAT_LIB_PATH, "byond:Echo")(text)
	var/confirmed = (out == text)
	return confirmed


/proc/json_encode_sanitize(list/data)
	. = json_encode(data)
	//NOT in: alphanumeric, ", {}, :, commas, spaces, []
	var/static/regex/r = new/regex(@'[^\w"{}:,\s\[\]]', "g")
	. = r.Replace(., "")
	. = replacetext(., "\\", "\\\\")
	return .

/// this errors if voicechat isnt setup. To stop it, turn off voicechat in voicechat.txt config
/datum/controller/subsystem/voicechat/proc/send_json(list/data)
	var/json = json_encode_sanitize(data)
	#ifdef LOG_TRAFFIC
	message_admins("BYOND: [json]")
	#endif
	call_ext(VOICECHAT_LIB_PATH, "byond:SendJSON")(json)


/datum/controller/subsystem/voicechat/proc/handle_topic(T, addr)
	//sanity check
	if(addr != "127.0.0.1")
		return

	var/list/data = json_decode(T)
	if(data["error"])
		message_admins(T)
		return

	#ifdef LOG_TRAFFIC
	message_admins("NODE: [T]")
	#endif

	if(data["node_started"])
		on_node_start()
		return


	if(data["pong"])
		world.log << "started: [data["time"]] round trip: [world.timeofday] approx: [world.timeofday -  data["time"]] x 1/10 seconds, data: [data["pong"]]"
		return

	if(data["confirmed"])
		confirm_userCode(data["confirmed"])
		return

	if(data["voice_activity"])
		toggle_active(data["voice_activity"], data["active"])
		return

	if(data["disconnect"])
		disconnect(userCode= data["disconnect"])

	if(data["ice_failed"])
		on_ice_failed(userCode=data["ice_failed"])
		return

#undef VOICECHAT_LIB_PATH
