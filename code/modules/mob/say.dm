/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"

	if(!message)
		return

	say(message)


/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	if(!message)
		return

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	emote("me", EMOTE_VISIBLE, message, TRUE)


/mob/verb/whisper_verb(message as text)
	set name = "Whisper"
	set category = "IC"

	if(!message)
		return

	whisper(message)


/mob/proc/whisper(message, datum/language/language)
	say(message, language)


/mob/proc/say_dead(message)
	if(!check_rights(R_ADMIN, FALSE))
		if(!GLOB.dsay_allowed)
			to_chat(src, "<span class='warning'>Deadchat is globally muted</span>")
			return
		if(client)
			if(client.prefs.muted & MUTE_DEADCHAT)
				to_chat(src, "<span class='danger'>You cannot talk in deadchat (muted).</span>")
				return
			if(client?.prefs && !(client.prefs.toggles_chat & CHAT_DEAD))
				to_chat(usr, "<span class='warning'>You have deadchat muted.</span>")
				return
			if(client.handle_spam_prevention(message, MUTE_DEADCHAT))
				return

	var/name = "GHOST" // Just defined incase its empty
	var/alt_name = ""
	if(mind && mind.name)
		name = "[mind.name]"
	else
		name = real_name
	if(name != real_name)
		alt_name = " (died as [real_name])"

	var/spanned = say_quote(say_emphasis(message))
	var/source = "<span class='game'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span>[alt_name]"
	var/rendered = " <span class='message'>[emoji_parse(spanned)]</span></span>"
	log_talk(message, LOG_SAY, tag = "DEAD")
	if(SEND_SIGNAL(src, COMSIG_MOB_DEADSAY, message) & MOB_DEADSAY_SIGNAL_INTERCEPT)
		return
	var/displayed_key = key
	if(client?.holder?.fakekey)
		displayed_key = null

	deadchat_broadcast(rendered, source, follow_target = src, speaker_key = displayed_key)


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
		if(faction == FACTION_TERRAGOV_REBEL)
			return GLOB.department_radio_keys_rebel[key_symbol]
		return GLOB.department_radio_keys[key_symbol]


///Check if this message is an emote
/mob/proc/check_emote(message)
	if(message[1] == "*")
		emote(copytext(message, length(message[1]) + 1), intentional = TRUE)
		return TRUE
