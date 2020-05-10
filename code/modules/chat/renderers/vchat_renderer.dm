/datum/asset/simple/vchat
	verify = FALSE
	assets = list(
		"semantic.min.css"        = 'code/modules/chat/renderers/vchat/css/semantic.min.css',
		"vchat-font-embedded.css" = 'code/modules/chat/renderers/vchat/css/vchat-font-embedded.css',
		"ss13styles.css"          = 'code/modules/chat/renderers/vchat/css/ss13styles.css',
		"polyfills.js"            = 'code/modules/chat/renderers/vchat/js/polyfills.js',
		"vue.min.js"              = 'code/modules/chat/renderers/vchat/js/vue.min.js',
		"vchat.js"                = 'code/modules/chat/renderers/vchat/js/vchat.js',
	)

/datum/asset/spritesheet/vchat
	name = "chat"

/datum/asset/spritesheet/vchat/register()
	InsertAll("emoji", 'icons/misc/emoji.dmi')

	// pre-loading all lanugage icons also helps to avoid meta
	InsertAll("language", 'icons/misc/language.dmi')
	// catch languages which are pulling icons from another file
	for(var/path in typesof(/datum/language))
		var/datum/language/L = path
		var/icon = initial(L.icon)
		if(icon != 'icons/misc/language.dmi')
			var/icon_state = initial(L.icon_state)
			Insert("language-[icon_state]", icon, icon_state = icon_state)

	return ..()


/datum/asset/group/vchat
	children = list(
		/datum/asset/simple/vchat,
		/datum/asset/spritesheet/vchat
	)


/*
vchat specific chat renderer (default for most clients)
*/
/datum/chatRenderer/vchat
	asset_datum = /datum/asset/group/vchat

/datum/chatRenderer/vchat/get_main_page()
	return file('code/modules/chat/renderers/vchat/html/vchat.html')

/datum/chatRenderer/vchat/show_chat()
	return ..()


/datum/chatRenderer/vchat/send_message(client/target, message, time = world.time)
	var/list/tojson = list("time" = time, "message" = url_decode(url_decode(message)));
	target << output(url_encode(url_encode(json_encode(tojson))), "[skinOutputTag]:putmessage")


/datum/chatRenderer/vchat/Topic(href, list/href_list)
	. = ..()
	if(.)
		return

	var/list/params = list()
	for(var/key in href_list)
		if(length_char(key) > 7 && findtext(key, "param")) // 7 is the amount of characters in the basic param key template.
			var/param_name = copytext_char(key, 7, -1)
			var/item       = href_list[key]

			params[param_name] = item


	var/data
	switch(href_list["proc"])
		if("not_ready")
			CRASH("Tried to send a message to [chat.owner.ckey] chatOutput before it was ready!")
		if("done_loading")
			data = chat.doneLoading(arglist(params))
		if("ping")
			data = latency_check(arglist(params))
		// if("ident")
		// 	data = bancheck(arglist(params))
		if("unloading")
			loaded = FALSE
		if("debug")
			data = debug(arglist(params))

	if(data)
		send_data(data = data)


// Custom vchat shit
/datum/chatRenderer/vchat/proc/debug(message)
	chat.debug(message)

/datum/chatRenderer/vchat/send_ping()
	send_data(data = list("evttype" = "keepalive"))

//A response to a latency check from the client
/datum/chatRenderer/vchat/proc/latency_check()
	return list("evttype" = "pong")
