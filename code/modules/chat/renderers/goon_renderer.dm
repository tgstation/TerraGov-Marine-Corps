/datum/asset/simple/goonchat
	verify = FALSE
	assets = list(
		"common.js"					= 'code/modules/chat/renderers/common/goon.js',
		"json2.min.js"				= 'code/modules/chat/renderers/goonchat/js/json2.min.js',
		"browserOutput.js"			= 'code/modules/chat/renderers/goonchat/js/browserOutput.js',
		"fontawesome-webfont.eot"	= 'code/modules/chat/renderers/goonchat/fonts/fontawesome-webfont.eot',
		"fontawesome-webfont.svg"	= 'code/modules/chat/renderers/goonchat/fonts/fontawesome-webfont.svg',
		"fontawesome-webfont.ttf"	= 'code/modules/chat/renderers/goonchat/fonts/fontawesome-webfont.ttf',
		"fontawesome-webfont.woff"	= 'code/modules/chat/renderers/goonchat/fonts/fontawesome-webfont.woff',
		"goonchatfont-awesome.css"	= 'code/modules/chat/renderers/goonchat/css/font-awesome.css',
		"browserOutput.css"			= 'code/modules/chat/renderers/goonchat/css/browserOutput.css',
		"browserOutput_white.css"	= 'code/modules/chat/renderers/goonchat/css/browserOutput_white.css'
	)

/datum/asset/simple/jquery
	verify = FALSE
	assets = list(
		"jquery.min.js"            = 'code/modules/chat/renderers/goonchat/js/jquery.min.js',
	)

/datum/asset/spritesheet/goonchat
	name = "chat"


/datum/asset/spritesheet/goonchat/register()
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


/datum/asset/group/goonchat
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/goonchat,
		/datum/asset/spritesheet/goonchat
	)

/*
Goon specific chat renderer (default for most clients)
*/
/datum/chatRenderer/goon
	name = "goon"
	asset_datum = /datum/asset/group/goonchat

/datum/chatRenderer/goon/get_main_page()
	return file('code/modules/chat/renderers/goonchat/html/browserOutput.html')

/datum/chatRenderer/goon/show_chat()
	return ..()

/datum/chatRenderer/goon/send_client_data()
	var/list/deets = list("clientData" = list())
	deets["clientData"]["ckey"] = owner.ckey
	deets["clientData"]["ip"] = owner.address
	deets["clientData"]["compid"] = owner.computer_id
	send_data(deets)


/datum/chatRenderer/Topic(href, list/href_list)
	. = ..()
	if(.)
		return

	var/list/params = list()
	for(var/key in href_list)
		if(length_char(key) > 7 && findtext(key, "param")) // 7 is the amount of characters in the basic param key template.
			var/param_name = copytext_char(key, 7, -1)
			var/item       = href_list[key]

			params[param_name] = item

	var/data // Data to be sent back to the chat.
	switch(href_list["proc"])
		if("doneLoading")
			data = chat.doneLoading(arglist(params))

		if("debug")
			data = chat.debug(list2params(params))

		if("analyzeClientData")
			data = chat.analyzeClientData(arglist(params))

		if("setMusicVolume")
			data = chat.setMusicVolume(arglist(params))

		if("swaptodarkmode")
			chat.swaptodarkmode()

		if("swaptolightmode")
			chat.swaptolightmode()

	if(data)
		send_data(data = data)
