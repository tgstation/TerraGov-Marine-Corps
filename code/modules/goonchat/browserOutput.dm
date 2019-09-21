/*********************************
For the main html chat area
*********************************/

//Precaching a bunch of shit
GLOBAL_DATUM_INIT(iconCache, /savefile, new("tmp/iconCache.sav")) //Cache of icons for the browser output

//On client, created on login
/datum/chatOutput
	var/client/owner	 //client ref
	var/loaded       = FALSE // Has the client loaded the browser output area?
	var/list/messageQueue //If they haven't loaded chat, this is where messages will go until they do
	var/cookieSent   = FALSE // Has the client sent a cookie for analysis
	var/working      = TRUE
	var/list/connectionHistory //Contains the connection history passed from chat cookie
	var/adminMusicVolume = 10 //This is for the Play Global Sound verb
	var/clientCSS = "" // This is a string var that stores client CSS.

/datum/chatOutput/New(client/C)
	owner = C
	messageQueue = list()
	connectionHistory = list()

/datum/chatOutput/proc/start()
	//Check for existing chat
	if(QDELETED(owner))
		return FALSE

	if(!istype(owner))
		CRASH("chatOutput/proc/start() called with owner of type: [owner?.type]")

	if(!winexists(owner, "browseroutput")) // Oh goddamnit.
		set waitfor = FALSE
		working = FALSE
		message_admins("Couldn't start chat for [key_name_admin(owner)]!")
		. = FALSE
		alert(owner.mob, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
		return

	if(winget(owner, "browseroutput", "is-visible") == "true") //Already setup
		doneLoading()

	else //Not setup
		load()

	return TRUE

/datum/chatOutput/proc/load()
	set waitfor = FALSE
	if(!owner)
		return

	var/datum/asset/stuff = get_asset_datum(/datum/asset/group/goonchat)
	stuff.send(owner)

	owner << browse(file('code/modules/goonchat/browserOutput.html'), "window=browseroutput")

/datum/chatOutput/Topic(href, list/href_list)
	if(usr.client != owner)
		return TRUE

	// Build arguments.
	// Arguments are in the form "param[paramname]=thing"
	var/list/params = list()
	for(var/key in href_list)
		if(length(key) > 7 && findtext(key, "param")) // 7 is the amount of characters in the basic param key template.
			var/param_name = copytext(key, 7, -1)
			var/item       = href_list[key]

			params[param_name] = item

	var/data // Data to be sent back to the chat.
	switch(href_list["proc"])
		if("doneLoading")
			data = doneLoading(arglist(params))

		if("debug")
			data = debug(arglist(params))

		if("analyzeClientData")
			data = analyzeClientData(arglist(params))

		if("setMusicVolume")
			data = setMusicVolume(arglist(params))

	if(data)
		ehjax_send(data = data)


//Called on chat output done-loading by JS.
/datum/chatOutput/proc/doneLoading()
	if(loaded)
		return

	if(!owner)
		return FALSE

	loaded = TRUE
	showChat()


	for(var/message in messageQueue)
		// whitespace has already been handled by the original to_chat
		to_chat_immediate(owner, message, handle_whitespace = FALSE)

	messageQueue = null
	sendClientData()
	loadClientCSS()

	//do not convert to to_chat()
	SEND_TEXT(owner, "<span class=\"userdanger\">Failed to load fancy chat, reverting to old chat. Certain features won't work.</span>")

/datum/chatOutput/proc/showChat()
	winset(owner, "output", "is-visible=false")
	winset(owner, "browseroutput", "is-disabled=false;is-visible=true")

/datum/chatOutput/proc/ehjax_send(client/C = owner, window = "browseroutput", data)
	if(islist(data))
		data = json_encode(data)
	C << output("[data]", "[window]:ehjaxCallback")

/datum/chatOutput/proc/sendMusic(music, list/extra_data)
	if(!findtext(music, GLOB.is_http_protocol))
		return
	var/list/music_data = list("adminMusic" = url_encode(url_encode(music)))
	if(length(extra_data))
		music_data["musicRate"] = extra_data["pitch"]
		music_data["musicSeek"] = extra_data["start"]
		music_data["musicHalt"] = extra_data["end"]
	ehjax_send(data = music_data)

/datum/chatOutput/proc/stopMusic()
	ehjax_send(data = "stopMusic")

/datum/chatOutput/proc/setMusicVolume(volume = "")
	if(volume)
		adminMusicVolume = CLAMP(text2num(volume), 0, 100)

//Sends client connection details to the chat to handle and save
/datum/chatOutput/proc/sendClientData()
	//Get dem deets
	var/list/deets = list("clientData" = list())
	deets["clientData"]["ckey"] = owner.ckey
	deets["clientData"]["ip"] = owner.address
	deets["clientData"]["compid"] = owner.computer_id
	var/data = json_encode(deets)
	ehjax_send(data = data)

//Called by client, sent data to investigate (cookie history so far)
/datum/chatOutput/proc/analyzeClientData(cookie)
	if(!cookie)
		return

	if(cookie != "none")
		var/list/connData = json_decode(cookie)
		if(length(connData) && connData["connData"])
			connectionHistory = connData["connData"]
			var/list/found = new()
			for(var/i in connectionHistory.len to 1 step -1)
				var/list/row = connectionHistory[i]
				if(!row || length(row) < 3 || (!row["ckey"] || !row["compid"] || !row["ip"])) //Passed malformed history object
					return
				if(world.IsBanned(row["ckey"], row["compid"], row["ip"]))
					found = row
					break

			if(length(found))
				log_admin_private("[key_name(owner)] has a cookie from a banned account (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])")
				message_admins("<font color='red'><b>Notice: </b></font><font color='blue'>[ADMIN_TPMONTY(owner.mob)] has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])</font>")

	cookieSent = TRUE


//Called by js client on js error
/datum/chatOutput/proc/debug(error)
	log_world("\[[time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")]\] Client: [(src.owner.key ? src.owner.key : src.owner)] triggered JS error: [error]")



/mob/verb/update_client_css()
	set category = "Preferences"
	set name = "Update Custom CSS"

	if(!client.chatOutput)
		return
	var/new_input = input(usr, "Enter custom CSS", "Client CSS", client.chatOutput.clientCSS) as message|null
	if(isnull(new_input) || length(new_input) > UPLOAD_LIMIT)
		return
	to_chat(src, "<span class='notice'>Updating custom CSS.</span>")
	client.chatOutput.clientCSS = new_input
	client.chatOutput.saveClientCSS()
	client.chatOutput.syncClientCSS()

// Load the CSS into the user browser
/datum/chatOutput/proc/syncClientCSS()
	var/css_data = _replacetext(clientCSS, ";", "||") // ; is a reserved key so lets just replace it and replace it back in js
	var/list/ajax_data = list("clientCSS" = css_data)
	ehjax_send(data = ajax_data)

// Save the CSS locally on the client
/datum/chatOutput/proc/saveClientCSS()
	var/savefile/F = new()
	WRITE_FILE(F["CSS"], clientCSS)
	owner.Export(F)
	qdel(F)

// Load the CSS from the local client
/datum/chatOutput/proc/loadClientCSS()
	var/last_savefile = owner.Import()
	if(!last_savefile)
		saveClientCSS("")
		return 
	var/savefile/F = new(last_savefile)
	READ_FILE(F["CSS"], clientCSS)
	
	if(length(clientCSS) > UPLOAD_LIMIT)
		clientCSS = ""
	clientCSS = sanitize_text(clientCSS, "")

	syncClientCSS(clientCSS)


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
	//Some macros remain in the string even after parsing and fuck up the eventual output
	message = replacetext(message, "\improper", "")
	message = replacetext(message, "\proper", "")
	if(handle_whitespace)
		message = replacetext(message, "\n", "<br>")
		message = replacetext(message, "\t", "[GLOB.TAB][GLOB.TAB]")

	if(islist(target))
		// Do the double-encoding outside the loop to save nanoseconds
		var/twiceEncoded = url_encode(url_encode(message))
		for(var/I in target)
			var/mob/M = I
			var/client/C = istype(M) ? M.client : I

			if(!C?.chatOutput?.working || (!C.chatOutput.loaded && length(C.chatOutput.messageQueue) > 25)) //A player who hasn't updated his skin file.
				SEND_TEXT(C, original_message)
				continue

			if(!C.chatOutput.loaded) //Client still loading, put their messages in a queue
				C.chatOutput.messageQueue += message
				continue

			C << output(twiceEncoded, "browseroutput:output")
	else
		var/mob/M = target
		var/client/C = istype(M) ? M.client : target

		if(!C?.chatOutput?.working || (!C.chatOutput.loaded && length(C.chatOutput.messageQueue) > 25)) //A player who hasn't updated his skin file.
			SEND_TEXT(C, original_message)
			return

		if(!C.chatOutput.loaded) //Client still loading, put their messages in a queue
			C.chatOutput.messageQueue += message
			return

		// url_encode it TWICE, this way any UTF-8 characters are able to be decoded by the Javascript.
		C << output(url_encode(url_encode(message)), "browseroutput:output")


/proc/to_chat(target, message, handle_whitespace = TRUE)
	if(Master.current_runlevel == RUNLEVEL_INIT || !SSchat?.initialized)
		to_chat_immediate(target, message, handle_whitespace)
		return
	SSchat.queue(target, message, handle_whitespace)