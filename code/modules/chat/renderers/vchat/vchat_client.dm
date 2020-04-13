//The 'V' is for 'VORE' but you can pretend it's for Vue.js if you really want.

//These are sent to the client via browse_rsc() in advance so the HTML can access them.
GLOBAL_LIST_INIT(vchatFiles, list(
	"code/modules/vchat/css/vchat-font-embedded.css",
	"code/modules/vchat/css/semantic.min.css",
	"code/modules/vchat/css/ss13styles.css",
	"code/modules/vchat/js/polyfills.js",
	"code/modules/vchat/js/vue.min.js",
	"code/modules/vchat/js/vchat.js"
))

//The main object attached to clients, created when they connect, and has start() called on it in client/New()
/datum/chatOutput
	var/client/owner = null
	var/loaded = FALSE
	var/list/message_queue = list()
	var/broken = FALSE
	var/resources_sent = FALSE

	var/last_topic_time = 0
	var/too_many_topics = 0
	var/topic_spam_limit = 10 //Just enough to get over the startup and such

/datum/chatOutput/New(client/C)
	. = ..()

	owner = C

/datum/chatOutput/Destroy()
	owner = null
	. = ..()

/datum/chatOutput/proc/update_vis()
	if(!loaded && !broken)
		winset(owner, null, "outputwindow.htmloutput.is-visible=false;outputwindow.oldoutput.is-visible=false;outputwindow.chatloadlabel.is-visible=true")
	else if(broken)
		winset(owner, null, "outputwindow.htmloutput.is-visible=false;outputwindow.oldoutput.is-visible=true;outputwindow.chatloadlabel.is-visible=false")
	else if(loaded)
		return //It can do it's own winsets from inside the JS if it's working.

//Shove all the assets at them
/datum/chatOutput/proc/send_resources()
	for(var/filename in GLOB.vchatFiles)
		owner << browse_rsc(file(filename))
	resources_sent = TRUE

//Called from client/New() in a spawn()
/datum/chatOutput/proc/start()
	if(!owner)
		qdel(src)
		return FALSE

	if(!winexists(owner, "htmloutput"))
		spawn()
			alert(owner, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
		become_broken()
		return FALSE

	if(!owner.is_preference_enabled(/datum/client_preference/vchat_enable))
		become_broken()
		return FALSE

	//Could be loaded from a previous round, are you still there?
	if(winget(owner,"outputwindow.htmloutput","is-visible") == "true") //Winget returns strings
		send_event(event = list("evttype" = "availability"))
		sleep(3 SECONDS)

	if(!owner) // In case the client vanishes before winexists returns
		qdel(src)
		return FALSE

	if(!loaded)
		update_vis()
		if(!resources_sent)
			send_resources()
		load()

	return TRUE

//Attempts to actually load the HTML page into the client's UI
/datum/chatOutput/proc/load()
	if(!owner)
		qdel(src)
		return

	owner << browse(file2text("code/modules/chat/renderers/vchat/html/vchat.html"), "window=htmloutput")

	//Check back later
	spawn(15 SECONDS)
		if(!src)
			return
		if(!src.loaded)
			src.become_broken()

//var/list/joins = list() //Just for testing with the below
//Called by Topic, when the JS in the HTML page finishes loading
/datum/chatOutput/proc/done_loading()
	if(loaded)
		return

	loaded = TRUE
	broken = FALSE
	owner.chatOutputLoadedAt = world.time

	//update_vis() //It does it's own winsets
	ping_cycle()
	send_playerinfo()
	load_database()

//It din work
/datum/chatOutput/proc/become_broken()
	broken = TRUE
	loaded = FALSE

	if(!owner)
		qdel(src)
		return

	update_vis()

	spawn()
		alert(owner,"VChat didn't load after some time. Switching to use oldchat as a fallback. Try using 'Reload VChat' verb in OOC verbs, or reconnecting to try again.")

//Provide the JS with who we are
/datum/chatOutput/proc/send_playerinfo()
	if(!owner)
		qdel(src)
		return

	var/list/playerinfo = list("evttype" = "byond_player", "cid" = owner.computer_id, "ckey" = owner.ckey, "address" = owner.address, "admin" = owner.holder ? "true" : "false")
	send_event(playerinfo)

//Ugh byond doesn't handle UTF-8 well so we have to do this.
/proc/jsEncode(var/list/message) {
	if(!islist(message))
		CRASH("Passed a non-list to encode.")
		return; //Necessary?

	return url_encode(url_encode(json_encode(message)))
}

//Send a side-channel event to the chat window
/datum/chatOutput/proc/send_event(var/event, var/client/C = owner)
	C << output(jsEncode(event), "htmloutput:get_event")

//Looping sleeping proc that just pings the client and dies when we die
/datum/chatOutput/proc/ping_cycle()
	set waitfor = FALSE
	while(!QDELING(src))
		if(!owner)
			qdel(src)
			return
		send_event(event = keep_alive())
		sleep(20 SECONDS) //Make sure this makes sense with what the js client is expecting

//Just produces a message for using in keepalives from the server to the client
/datum/chatOutput/proc/keep_alive()
	return list("evttype" = "keepalive")

//A response to a latency check from the client
/datum/chatOutput/proc/latency_check()
	return list("evttype" = "pong")

//Redirected from client/Topic when the user clicks a link that pertains directly to the chat (when src == "chat")
/datum/chatOutput/Topic(var/href, var/list/href_list)
	if(usr.client != owner)
		return 1

	if(last_topic_time > (world.time - 3 SECONDS))
		too_many_topics++
		if(too_many_topics >= topic_spam_limit)
			log_and_message_admins("Kicking [key_name(owner)] - VChat Topic() spam")
			to_chat(owner,"<span class='danger'>You have been kicked due to VChat sending too many messages to the server. Try reconnecting.</span>")
			qdel(owner)
			qdel(src)
			return
	else
		too_many_topics = 0
	last_topic_time = world.time

	var/list/params = list()
	for(var/key in href_list)
		if(length(key) > 7 && findtext(key, "param"))
			var/param_name = copytext(key, 7, -1)
			var/item = href_list[key]
			params[param_name] = item

	var/data
	switch(href_list["proc"])
		if("not_ready")
			CRASH("Tried to send a message to [owner.ckey] chatOutput before it was ready!")
		if("done_loading")
			data = done_loading(arglist(params))
		if("ping")
			data = latency_check(arglist(params))
		if("ident")
			data = bancheck(arglist(params))
		if("unloading")
			loaded = FALSE
		if("debug")
			data = debugmsg(arglist(params))

	if(data)
		send_event(event = data)

//Print a message that was an error from a client
/datum/chatOutput/proc/debugmsg(var/message = "No String Provided")
	log_debug("VChat: [owner] got: [message]")

//Check relevant client info reported from JS
/datum/chatOutput/proc/bancheck(var/clientdata)
	var/list/info = json_decode(clientdata)
	var/ckey = info["ckey"]
	var/ip = info["ip"]
	var/cid = info["cid"]

	//Never connected? How sad!
	if(!cid && !ip && !ckey)
		return

	var/list/ban = world.IsBanned(key = ckey, address = ip, computer_id = cid)
	if(ban)
		log_and_message_admins("[key_name(owner)] has a cookie from a banned account! (Cookie: [ckey], [ip], [cid])")

//Converts an icon to base64. Operates by putting the icon in the iconCache savefile,
// exporting it as text, and then parsing the base64 from that.
// (This relies on byond automatically storing icons in savefiles as base64)
/proc/icon2base64(var/icon/icon, var/iconKey = "misc")
	if (!isicon(icon)) return FALSE

	GLOB.iconCache[iconKey] << icon
	var/iconData = GLOB.iconCache.ExportText(iconKey)
	var/list/partial = splittext(iconData, "{")
	return replacetext(copytext(partial[2], 3, -5), "\n", "")

/proc/bicon(var/obj, var/use_class = 1, var/custom_classes = "")
	var/class = use_class ? "class='icon misc [custom_classes]'" : null
	if (!obj)
		return

	var/static/list/bicon_cache = list()
	if (isicon(obj))
		//Icon refs get reused all the time especially on temporarily made ones like chat tags, too difficult to cache.
		//if (!bicon_cache["\ref[obj]"]) // Doesn't exist yet, make it.
			//bicon_cache["\ref[obj]"] = icon2base64(obj)

		return "<img [class] src='data:image/png;base64,[icon2base64(obj)]'>"

	// Either an atom or somebody fucked up and is gonna get a runtime, which I'm fine with.
	var/atom/A = obj
	var/key = "[istype(A.icon, /icon) ? "\ref[A.icon]" : A.icon]:[A.icon_state]"
	if (!bicon_cache[key]) // Doesn't exist, make it.
		var/icon/I = icon(A.icon, A.icon_state, SOUTH, 1)
		if (ishuman(obj))
			I = getFlatIcon(obj) //Ugly
		bicon_cache[key] = icon2base64(I, key)
	if(use_class)
		class = "class='icon [A.icon_state] [custom_classes]'"

	return "<img [class] src='data:image/png;base64,[bicon_cache[key]]'>"

//Checks if the message content is a valid to_chat message
/proc/is_valid_tochat_message(message)
	return istext(message)

//Checks if the target of to_chat is something we can send to
/proc/is_valid_tochat_target(target)
	return !istype(target, /savefile) && (ismob(target) || islist(target) || isclient(target) || target == world)

var/to_chat_filename
var/to_chat_line
var/to_chat_src

//This proc is only really used if the SSchat subsystem is unavailable (not started yet)
/proc/to_chat_immediate(target, time, message)
	if(!is_valid_tochat_message(message) || !is_valid_tochat_target(target))
		target << message

		// Info about the "message"
		if(isnull(message))
			message = "(null)"
		else if(istype(message, /datum))
			var/datum/D = message
			message = "([D.type]): '[D]'"
		else if(!is_valid_tochat_message(message))
			message = "(bad message) : '[message]'"

		// Info about the target
		var/targetstring = "'[target]'"
		if(istype(target, /datum))
			var/datum/D = target
			targetstring += ", [D.type]"

		// The final output
		log_debug("to_chat called with invalid message/target: [to_chat_filename], [to_chat_line], [to_chat_src], Message: '[message]', Target: [targetstring]")
		return

	else if(is_valid_tochat_message(message))
		if(istext(target))
			log_debug("Somehow, to_chat got a text as a target")
			return

		var/original_message = message
		message = replacetext(message, "\n", "<br>")
		message = replacetext(message, "\improper", "")
		message = replacetext(message, "\proper", "")

		if(isnull(time))
			time = world.time

		var/client/C = CLIENT_FROM_VAR(target)
		if(C && C.chatOutput)
			if(C.chatOutput.broken)
				DIRECT_OUTPUT(C, original_message)
				return

			// // Client still loading, put their messages in a queue - Actually don't, logged already in database.
			// if(!C.chatOutput.loaded && C.chatOutput.message_queue && islist(C.chatOutput.message_queue))
			// 	C.chatOutput.message_queue[++C.chatOutput.message_queue.len] = list("time" = time, "message" = message)
			// 	return

		var/list/tojson = list("time" = time, "message" = message);
		target << output(jsEncode(tojson), "htmloutput:putmessage")
