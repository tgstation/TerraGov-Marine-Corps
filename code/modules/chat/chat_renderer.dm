/*
	Chat renderering system

	This takes input from the chat system and ouputs it for its specific framework.
	For example vue.js for vchat, or to the custom format of goonchat.
*/
/datum/chatRenderer
	var/datum/chatSystem/chat /// datum/chatSystem reference
	var/datum/asset/group/asset_datum /// Assets required by the renderer

/* Gets the asset datum to to send during initialization */
/datum/chatRenderer/proc/get_assets()
	return get_asset_datum(asset_datum)

/* Returns the main page that is sent to the client, this is the base html page (think index.html) */
/datum/chatRenderer/proc/get_main_page()
	return

/* Show the chat, replacing the default chat system with the specific chat renderer */
/datum/chatRenderer/proc/show_chat()
	winset(chat.owner, "output", "is-visible=false")
	winset(chat.owner, "browseroutput", "is-disabled=false;is-visible=true")


/// Goon specific chat renderer (default for most clients)
/datum/chatRenderer/goon
	asset_datum = /datum/asset/group/goonchat

/datum/chatRenderer/goon/get_main_page()
	return file('code/modules/goonchat/browserOutput.html')

/datum/chatRenderer/show_chat()
	winset(chat.owner, "output", "is-visible=false")
	winset(chat.owner, "browseroutput", "is-disabled=false;is-visible=true")
