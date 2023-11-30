///what clients use to speak. when you type a message into the chat bar in say mode, this is the first thing that goes off serverside.
/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"
	set instant = TRUE

	if(!message)
		return

	//queue this message because verbs are scheduled to process after SendMaps in the tick and speech is pretty expensive when it happens.
	//by queuing this for next tick the mc can compensate for its cost instead of having speech delay the start of the next tick
	SSspeech_controller.queue_say_for_mob(src, message, SPEECH_CONTROLLER_QUEUE_SAY_VERB)


/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"
	set instant = TRUE

	if(!message)
		return

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	SSspeech_controller.queue_say_for_mob(src, message, SPEECH_CONTROLLER_QUEUE_EMOTE_VERB)


/mob/verb/whisper_verb(message as text)
	set name = "Whisper"
	set category = "IC"
	set instant = TRUE

	if(!message)
		return

	SSspeech_controller.queue_say_for_mob(src, message, SPEECH_CONTROLLER_QUEUE_WHISPER_VERB)


/mob/proc/whisper(message, datum/language/language)
	say(message, language = language)


/mob/proc/say_dead(message)
	if(!check_rights(R_ADMIN, FALSE))
		if(!GLOB.dsay_allowed)
			to_chat(src, span_warning("Deadchat is globally muted"))
			return
		if(client)
			if(client.prefs.muted & MUTE_DEADCHAT)
				to_chat(src, span_danger("You cannot talk in deadchat (muted)."))
				return
			if(client?.prefs && !(client.prefs.toggles_chat & CHAT_DEAD))
				to_chat(src, span_warning("You have deadchat muted."))
				return
			if(is_banned_from(ckey, "Deadchat"))
				to_chat(src, span_warning("You are banned from deadchat."))
				return
			if(client.handle_spam_prevention(message, MUTE_DEADCHAT))
				return

	var/list/filter_result = is_ooc_filtered(message)
	if(!CAN_BYPASS_FILTER(usr) && filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		log_filter("Deadchat", message, filter_result)
		return

	// Protect filter bypassers from themselves.
	// Demote hard filter results to soft filter results if necessary due to the danger of accidentally speaking in OOC.
	var/list/soft_filter_result = filter_result || is_soft_ooc_filtered(message)

	if(soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			log_filter("Soft Deadchat", message, soft_filter_result)
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[message]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[message]\"")
		log_filter("Soft Deadchat (PASSED)", message, soft_filter_result)

	var/name = "GHOST" // Just defined incase its empty
	var/alt_name = ""
	if(mind?.name)
		name = "[mind.name]"
	else
		name = real_name
	if(name != real_name)
		alt_name = " (died as [real_name])"

	var/spanned = say_quote(say_emphasis(message))
	var/source = "[span_game("<span class='prefix'>DEAD:")] [span_name("[name]")][alt_name]"
	var/rendered = " [span_message("[emoji_parse(spanned)]")]</span>"
	log_talk(message, LOG_SAY, tag = "DEAD")
	if(SEND_SIGNAL(src, COMSIG_MOB_DEADSAY, message) & MOB_DEADSAY_SIGNAL_INTERCEPT)
		return
	var/displayed_key = key
	if(client?.holder?.fakekey)
		displayed_key = null

	deadchat_broadcast(rendered, source, follow_target = src, speaker_key = displayed_key)
	create_chat_message(src, /datum/language/common, message)

/mob/living/proc/get_message_mode(message)
	var/key = message[1]
	if(key == "#")
		return MODE_WHISPER
	else if(key == "%")
		return MODE_SING
	else if(key == ";")
		return MODE_HEADSET
	else if((length(message) > (length(key) + 1)) && (key in GLOB.department_radio_prefixes))
		var/key_symbol = lowertext(message[length(key) + 1])
		if(faction == FACTION_SOM)
			return GLOB.department_radio_keys_som[key_symbol]
		return GLOB.department_radio_keys[key_symbol]


///Check if this message is an emote
/mob/proc/check_emote(message)
	if(message[1] == "*")
		emote(copytext(message, length(message[1]) + 1), intentional = TRUE)
		return TRUE
