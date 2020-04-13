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
Goon specific chat renderer (default for most clients)
*/
/datum/chatRenderer/goon
	asset_datum = /datum/asset/group/vchat

/datum/chatRenderer/goon/get_main_page()
	return file('code/modules/chat/renderers/vchat/html/vchat.html')

/datum/chatRenderer/show_chat()
	winset(chat.owner, "output", "is-visible=false")
	winset(chat.owner, "browseroutput", "is-disabled=false;is-visible=true")
