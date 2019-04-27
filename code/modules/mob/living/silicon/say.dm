/mob/living/silicon/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return speak_query
	else if (ending == "!")
		return speak_exclamation

	return speak_statement

#define IS_AI 1
#define IS_ROBOT 2


/mob/living/silicon/say(message, datum/language/language)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (stat == 2)
		return say_dead(message)

	if(copytext(message,1,2) == "*")
		return emote(copytext(message,2))

	var/bot_type = 0			//Let's not do a fuck ton of type checks, thanks.
	if(isAI(src))
		bot_type = IS_AI
	else if(iscyborg(src))
		bot_type = IS_ROBOT

	var/mob/living/silicon/ai/AI = src		//and let's not declare vars over and over and over for these guys.
	var/mob/living/silicon/robot/R = src

	//Must be concious to speak
	if (stat)
		return

	var/verb = say_quote(message)

	//parse radio key and consume it
	var/message_mode = parse_message_mode(message, "general")
	if (message_mode)
		if (message_mode == "general")
			message = trim(copytext(message,2))
		else
			message = trim(copytext(message,3))

	// Currently used by drones.
	if(local_transmit)
		var/list/listeners = hearers(5,src)
		listeners |= src

		for(var/mob/living/silicon/D in listeners)
			if(D.client && istype(D,src.type))
				to_chat(D, "<b>[src]</b> transmits, \"[message]\"")

		for (var/mob/M in GLOB.player_list)
			if (isnewplayer(M))
				continue
			else if(M.stat == 2 &&  M.client.prefs.toggles_chat & CHAT_GHOSTEARS)
				if(M.client) to_chat(M, "<b>[src]</b> transmits, \"[message]\"")
		return

	if(message_mode && bot_type == IS_ROBOT && !R.is_component_functioning("radio"))
		to_chat(src, "<span class='warning'>Your radio isn't functional at this time.</span>")
		return

	switch(message_mode)
		if("department")
			switch(bot_type)
				if(IS_AI)
					return AI.holopad_talk(message)
				if(IS_ROBOT)
					log_talk(message, LOG_SAY)
					R.radio.talk_into(src,message,message_mode,verb,language)
			return 1

			return 1
		if("general")
			switch(bot_type)
				if(IS_AI)
					if (AI.aiRadio.disabledAi)
						to_chat(src, "<span class='warning'>System Error - Transceiver Disabled</span>")
						return
					else
						log_talk(message, LOG_SAY)
						AI.aiRadio.talk_into(src,message,null,verb,language)
				if(IS_ROBOT)
					log_talk(message, LOG_SAY)
					R.radio.talk_into(src,message,null,verb,language)
			return 1

		else
			if(message_mode)
				switch(bot_type)
					if(IS_AI)
						if (AI.aiRadio.disabledAi)
							to_chat(src, "<span class='warning'>System Error - Transceiver Disabled</span>")
							return
						else
							log_talk(message, LOG_SAY)
							AI.aiRadio.talk_into(src,message,message_mode,verb,language)
					if(IS_ROBOT)
						log_talk(message, LOG_SAY)
						R.radio.talk_into(src,message,message_mode,verb,language)
				return 1

	return ..(message,language,verb)

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(var/message)

	log_talk(message, LOG_SAY, tag="holopad")

	message = trim(message)

	if (!message)
		return

	var/obj/machinery/hologram/holopad/T = src.holo
	if(T && T.hologram && T.master == src)//If there is a hologram and its master is the user.
		var/verb = say_quote(message)

		//Human-like, sorta, heard by those who understand humans.
		var/rendered_a = "<span class='game say'><span class='name'>[name]</span> [verb], <span class='message'>\"[message]\"</span></span>"

		to_chat(src, "<i><span class='game say'>Holopad transmitted, <span class='name'>[real_name]</span> [verb], <span class='message'>[message]</span></span></i>")
		for(var/mob/M in hearers(T.loc))//The location is the object, default distance.
			M.show_message(rendered_a, 2)
		/*Radios "filter out" this conversation channel so we don't need to account for them.
		This is another way of saying that we won't bother dealing with them.*/
	else
		to_chat(src, "No holopad connected.")
		return
	return 1

#undef IS_AI
#undef IS_ROBOT
