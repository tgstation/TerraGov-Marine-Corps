/*********************************
For the main html chat area
*********************************/

//This is used to convert icons to base64 <image> strings, because byond stores icons in base64 in savefiles.
GLOBAL_DATUM_INIT(iconCache, /savefile, new("tmp/iconCache.sav")) //Cache of icons for the browser output

//Should match the value set in the browser js
#define MAX_COOKIE_LENGTH 5


#define CHAT_RENDERER_GOON(X) new /datum/chatRenderer/goon(X)
#define CHAT_RENDERER_VCHAT(X) new /datum/chatRenderer/vchat(X)
#define DEFAULT_CHAT_RENDERER(X) CHAT_RENDERER_VCHAT(X)

/*
	The Chat system datum

	This is the main system for chat in TGMC. All outgoing chat is sent via the chatSystem
	which is able to work with different renderers to support multiple outputs

	Currently supported are byond, goonchat, and vchat.

*/
/datum/chatSystem
	var/client/owner ///Client ref
	var/datum/chatRenderer/renderer /// Chat renderer
	// How many times client data has been checked
	var/total_checks			= 0
	// When to next clear the client data checks counter
	var/next_time_to_clear		= 0
	var/loaded					= FALSE // Has the client loaded the browser output area?
	var/list/messageQueue //If they haven't loaded chat, this is where messages will go until they do
	var/cookieSent				= FALSE // Has the client sent a cookie for analysis
	var/working					= TRUE
	var/list/connectionHistory //Contains the connection history passed from chat cookie
	var/adminMusicVolume		= 10 //This is for the Play Global Sound verb

/datum/chatSystem/New(client/C)
	owner = C
	messageQueue = list()
	connectionHistory = list()

	//TODO: choose renderer this from prefs
	renderer = CHAT_RENDERER_GOON(src)

/datum/chatSystem/proc/start()
	//Check for existing chat
	if(QDELETED(owner))
		return FALSE

	if(!istype(owner))
		CRASH("chatOutput/proc/start() called with owner of type: [owner?.type]")

	if(!winexists(owner, "chatoutput")) // Oh goddamnit.
		set waitfor = FALSE
		working = FALSE
		message_admins("Couldn't start chat for [key_name_admin(owner)]!")
		. = FALSE
		alert(owner.mob, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
		return

	if(winget(owner, "chatoutput", "is-visible") == "true") //Already setup
		doneLoading()

	else //Not setup
		load()

	return TRUE

/datum/chatSystem/proc/load()
	set waitfor = FALSE
	if(!owner)
		return

	var/datum/asset/stuff = renderer.get_assets()
	stuff.send(owner)

	var/main_page = renderer.get_main_page()
	owner << browse(main_page, "window=chatoutput")


/datum/chatSystem/Topic(href, list/href_list)
	if(usr.client != owner)
		return TRUE

	//Spam check
	if(!COOLDOWN_CHECK(src, COOLDOWN_TOPIC_SPAM))
		COOLDOWN_START(src, COOLDOWN_TOPIC_SPAM, 3 SECONDS)
		total_checks = 0

	total_checks += 1

	if(total_checks > SPAM_TRIGGER_AUTOMUTE)
		log_admin("[key_name(owner)] kicked for goonchat topic spam")
		message_admins("[key_name(owner)] kicked for goonchat topic spam")
		qdel(owner)
		return

	renderer.Topic(href, href_list)


//Called on chat output done-loading by JS.
/datum/chatSystem/proc/doneLoading()
	if(loaded)
		return

	if(!owner)
		return FALSE

	renderer.show_chat()

	sendClientData()

	syncRegex()

	//do not convert to to_chat()
	SEND_TEXT(owner, "<span class=\"userdanger\">Failed to load fancy chat, reverting to old chat. Certain features won't work.</span>")

/datum/chatSystem/proc/send_ping()
	renderer.send_ping()

/datum/chatSystem/proc/show_chat()
	renderer.show_chat()

/datum/chatSystem/proc/hide_chat()
	renderer.hide_chat()

/proc/syncChatRegexes()
	for (var/user in GLOB.clients)
		var/client/C = user
		var/datum/chatSystem/Cchat = C.chatOutput
		if (Cchat?.working && Cchat.loaded)
			Cchat.syncRegex()

/datum/chatSystem/proc/syncRegex()
	var/list/regexes = list()

	if (config.ic_filter_regex)
		regexes["show_filtered_ic_chat"] = list(
			config.ic_filter_regex.name,
			"ig",
			"<span class='boldwarning'>$1</span>"
		)

	if (regexes.len)
		ehjax_send(data = list("syncRegex" = regexes))

/datum/chatSystem/proc/ehjax_send(data)
	renderer.send_data(data)


/datum/chatSystem/proc/sendMusic(music, list/extra_data)
	if(!findtext(music, GLOB.is_http_protocol))
		return
	var/list/music_data = list("adminMusic" = url_encode(url_encode(music)))
	if(length(extra_data))
		music_data["musicRate"] = extra_data["pitch"]
		music_data["musicSeek"] = extra_data["start"]
		music_data["musicHalt"] = extra_data["end"]
	ehjax_send(data = music_data)

/datum/chatSystem/proc/stopMusic()
	ehjax_send(data = "stopMusic")

/datum/chatSystem/proc/setMusicVolume(volume = "")
	if(volume)
		adminMusicVolume = CLAMP(text2num(volume), 0, 100)

//Sends client connection details to the chat to handle and save
/datum/chatSystem/proc/sendClientData()
	renderer.send_client_data()

//Called by client, sent data to investigate (cookie history so far)
/datum/chatSystem/proc/analyzeClientData(cookie)
	if(!cookie)
		return

	if(cookie != "none")
		var/list/connData = json_decode(cookie)
		if(length(connData) && connData["connData"])
			connectionHistory = connData["connData"]
			var/list/found = new()

			if(connectionHistory.len > MAX_COOKIE_LENGTH)
				log_admin("[key_name(owner)] was kicked for a malformed ban cookie (Size greater [MAX_COOKIE_LENGTH])")
				message_admins("[key_name(owner)] was kicked for a malformed ban cookie (Size greater [MAX_COOKIE_LENGTH])")
				qdel(owner)
				return

			for(var/i in connectionHistory.len to 1 step -1)
				if(QDELETED(owner))
					//he got cleaned up before we were done
					return
				var/list/row = connectionHistory[i]
				if(!row || length(row) < 3 || (!row["ckey"] || !row["compid"] || !row["ip"])) //Passed malformed history object
					return
				if(world.IsBanned(row["ckey"], row["compid"], row["ip"]))
					found = row
					break
				CHECK_TICK

			if(length(found))
				log_admin_private("[key_name(owner)] has a cookie from a banned account (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])")
				message_admins("<font color='red'><b>Notice: </b></font><span class='notice'>[ADMIN_TPMONTY(owner.mob)] has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])</font>")

	cookieSent = TRUE


//Called by js client on js error
/datum/chatSystem/proc/debug(error)
	stack_trace("JS Error: [error]")
	log_world("Client: [(src.owner.key ? src.owner.key : src.owner)] JS Error: [error]")


//Global chat procs
/proc/to_chat_immediate(target, message, handle_whitespace = TRUE)
	if(!target || !message)
		return

	if(!istext(message))
		stack_trace("to_chat_immediate called with invalid input type")
		return

	if(target == world)
		target = GLOB.clients

	var/original_message = message
	if(handle_whitespace)
		message = replacetext(message, "\n", "<br>")
		message = replacetext(message, "\t", "[FOURSPACES][FOURSPACES]")

	if(islist(target))
		// Do the double-encoding outside the loop to save nanoseconds
		var/twiceEncoded = message
		for(var/I in target)
			var/client/C = CLIENT_FROM_VAR(I)

			if(!C)
				return

			//Send it to the old style output window.
			SEND_TEXT(C, original_message)

			if(!C.chatOutput?.working) //A player who hasn't updated his skin file.
				continue

			if(!C.chatOutput.loaded) //Client still loading, put their messages in a queue
				if(length(C.chatOutput.messageQueue) > 25)
					continue
				C.chatOutput.messageQueue += message
				continue

			C.chatOutput.renderer.send_message(twiceEncoded)
	else
		var/client/C = CLIENT_FROM_VAR(target)

		if(!C)
			return

		//Send it to the old style output window.
		SEND_TEXT(C, original_message)

		if(!C?.chatOutput?.working) //A player who hasn't updated his skin file.
			return

		if(!C.chatOutput.loaded) //Client still loading, put their messages in a queue
			if(length(C.chatOutput.messageQueue) > 25)
				return
			C.chatOutput.messageQueue += message
			return

		// url_encode it TWICE, this way any UTF-8 characters are able to be decoded by the Javascript.
		C.chatOutput.renderer.send_message(url_encode(url_encode(message)))



/proc/to_chat(target, message, handle_whitespace = TRUE)
	if(Master.current_runlevel == RUNLEVEL_INIT || !SSchat?.initialized)
		to_chat_immediate(target, message, handle_whitespace)
		return
	SSchat.queue(target, message, handle_whitespace)

/datum/chatSystem/proc/swaptolightmode()
	owner.force_white_theme()

/datum/chatSystem/proc/swaptodarkmode()
	owner.force_dark_theme()

#undef MAX_COOKIE_LENGTH
