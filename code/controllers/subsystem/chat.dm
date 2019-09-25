SUBSYSTEM_DEF(chat)
	name = "Chat"
	flags = SS_TICKER
	wait = 1
	priority = FIRE_PRIORITY_CHAT
	init_order = INIT_ORDER_CHAT

	var/list/payload = list()


/datum/controller/subsystem/chat/fire()
	for(var/i in payload)
		var/client/C = i
		C << output(payload[C], "browseroutput:output")
		payload -= C

		if(MC_TICK_CHECK)
			return


/datum/controller/subsystem/chat/proc/queue(target, message, handle_whitespace = TRUE)
	if(!target || !message)
		return

	if(!istext(message))
		CRASH("to_chat called with invalid input type")

	if(target == world)
		target = GLOB.clients

	var/original_message = message
	//Some macros remain in the string even after parsing and fuck up the eventual output
	message = replacetext(message, "\improper", "")
	message = replacetext(message, "\proper", "")
	if(handle_whitespace)
		message = replacetext(message, "\n", "<br>")
		message = replacetext(message, "\t", "[GLOB.TAB][GLOB.TAB]")
	message += "<br>"


	//url_encode it TWICE, this way any UTF-8 characters are able to be decoded by the Javascript.
	//Do the double-encoding here to save nanoseconds
	var/twiceEncoded = url_encode(url_encode(message))

	if(islist(target))
		for(var/I in target)
			var/mob/M = I
			var/client/C = istype(M) ? M.client : I
			
			if(!C?.chatOutput?.working || (!C.chatOutput.loaded && length(C.chatOutput.messageQueue) > 25)) //A player who hasn't updated his skin file.
				SEND_TEXT(C, original_message)
				continue

			if(!C.chatOutput.loaded) //Client still loading, put their messages in a queue
				C.chatOutput.messageQueue += message
				continue

			payload[C] += twiceEncoded

	else
		var/mob/M = target
		var/client/C = istype(M) ? M.client : target

		if(!C?.chatOutput?.working || (!C.chatOutput.loaded && length(C.chatOutput.messageQueue) > 25)) //A player who hasn't updated his skin file.
			SEND_TEXT(C, original_message)
			return

		if(!C.chatOutput.loaded) //Client still loading, put their messages in a queue
			C.chatOutput.messageQueue += message
			return

		payload[C] += twiceEncoded
