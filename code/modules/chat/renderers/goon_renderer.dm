/datum/asset/simple/goonchat
	verify = FALSE
	assets = list(
		"json2.min.js"             = 'code/modules/chat/renderers/goonchat/json2.min.js',
		"browserOutput.js"         = 'code/modules/chat/renderers/goonchat/browserOutput.js',
		"fontawesome-webfont.eot"  = 'code/modules/chat/renderers/goonchat/fonts/fontawesome-webfont.eot',
		"fontawesome-webfont.svg"  = 'code/modules/chat/renderers/goonchat/fonts/fontawesome-webfont.svg',
		"fontawesome-webfont.ttf"  = 'code/modules/chat/renderers/goonchat/fonts/fontawesome-webfont.ttf',
		"fontawesome-webfont.woff" = 'code/modules/chat/renderers/goonchat/fonts/fontawesome-webfont.woff',
		"goonchatfont-awesome.css" = 'code/modules/chat/renderers/goonchat/font-awesome.css',
		"browserOutput.css"	       = 'code/modules/chat/renderers/goonchat/browserOutput.css',
		"browserOutput_white.css"  = 'code/modules/chat/renderers/goonchat/browserOutput_white.css',
	)

/datum/asset/simple/jquery
	verify = FALSE
	assets = list(
		"jquery.min.js"            = 'code/modules/chat/renderers/goonchat/jquery.min.js',
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
	asset_datum = /datum/asset/group/goonchat

/datum/chatRenderer/goon/get_main_page()
	return file('code/modules/chat/renderers/goonchat/browserOutput.html')

/datum/chatRenderer/show_chat()
	winset(chat.owner, "output", "is-visible=false")
	winset(chat.owner, "browseroutput", "is-disabled=false;is-visible=true")
