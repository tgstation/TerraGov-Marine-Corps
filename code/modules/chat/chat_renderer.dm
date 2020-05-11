/*
	Chat renderering system

	This takes input from the chat system and ouputs it for its specific framework.
	For example vue.js for vchat, or to the custom format of goonchat.
*/
/datum/chatRenderer
	var/client/owner
	var/datum/chatSystem/chat /// datum/chatSystem reference
	var/datum/asset/group/asset_datum /// Assets required by the renderer
	var/name = "DEFAULT" /// name of the renderer

	var/loaded = FALSE /// Has this renderer loaded yet

	var/skinRawOutputTag = "output" /// Winset tag used to send data to the renderer
	var/skinOutputTag = "chatoutput" /// Winset tag used to send data to the renderer


/datum/chatRenderer/New(datum/chatSystem/parentChat)
	chat = parentChat
	owner = chat.owner


/** Gets the asset datum to to send during initialization */
/datum/chatRenderer/proc/get_assets()
	return get_asset_datum(asset_datum)


/** Returns the main page that is sent to the client, this is the base html page (think index.html) */
/datum/chatRenderer/proc/get_main_page()
	return


/** Show the chat, replacing the default chat system with the specific chat renderer */
/datum/chatRenderer/proc/show_chat()
	winset(chat.owner, skinRawOutputTag, "is-visible=false")
	winset(chat.owner, skinOutputTag, "is-disabled=false;is-visible=true")
	loaded = TRUE
	chat.loaded = loaded

	for(var/message in chat.messageQueue)
		// whitespace has already been handled by the original to_chat
		to_chat_immediate(owner, message, handle_whitespace = FALSE)

/** Show the chat, replacing the default chat system with the specific chat renderer */
/datum/chatRenderer/proc/hide_chat()
	winset(chat.owner, skinRawOutputTag, "is-visible=true")
	winset(chat.owner, skinOutputTag, "is-disabled=true;is-visible=false")
	loaded = FALSE
	chat.loaded = loaded

/datum/chatRenderer/proc/send_message(message)
	owner << output(json_encode(list("message" = message)), "[skinOutputTag]:receiveMessage")


/datum/chatRenderer/proc/send_data(list/data)
	owner << output(json_encode(data), "[skinOutputTag]:receiveData")

/datum/chatRenderer/proc/send_ping()
	send_data(list("ping" = world.time))

/datum/chatRenderer/proc/send_client_data()
	return


/** Handle the topics from the frontend */
/datum/chatRenderer/Topic(href, list/href_list)
	return FALSE
