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
	if(!client)
		return

	if(!check_rights(R_ADMIN, FALSE))
		if(!GLOB.dsay_allowed)
			to_chat(src, "<span class='warning'>Deadchat is globally muted</span>")
			return
		if(client.prefs.muted & MUTE_DEADCHAT)
			to_chat(src, "<span class='warning'>You cannot emote in deadchat (muted).</span>")
			return
		if(client?.prefs && !(client.prefs.toggles_chat & CHAT_DEAD))
			to_chat(usr, "<span class='warning'>You have deadchat muted.</span>")
			return
		if(client.handle_spam_prevention(message, MUTE_IC))
			return

	log_talk(message, LOG_SAY, "ghost")

	for(var/i in GLOB.player_list)
		var/mob/M = i

		if(isnewplayer(M))
			continue

		if(!(M.client.prefs.toggles_chat & CHAT_DEAD))
			continue

		// Admin links for name
		var/name = real_name
		if(check_other_rights(M.client, R_ADMIN, FALSE))
			name = "<a class='hidelink' href='?_src_=holder;[HrefToken(TRUE)];playerpanel=[REF(usr)]'>[name]</a>"

		var/rendered = "[M != src ? FOLLOW_LINK(M, src) : ""] <span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span> says, <span class='message'>\"[emoji_parse(message)]\"</span></span>"
		if(M.client && (M.stat == DEAD || check_other_rights(M.client, R_ADMIN, FALSE)))
			to_chat(M, rendered)


/mob/proc/get_message_mode(message)
	var/key = message[1]
	if(key == "#")
		return MODE_WHISPER
	else if(key == "%")
		return MODE_SING
	else if(key == ";")
		return MODE_HEADSET
	else if((length(message) > (length(key) + 1)) && (key in GLOB.department_radio_prefixes))
		var/key_symbol = lowertext(message[length(key) + 1])
		return GLOB.department_radio_keys[key_symbol]


///Check if this message is an emote
/mob/proc/check_emote(message)
	if(message[1] == "*")
		emote(copytext(message, length(message[1]) + 1), intentional = TRUE)
		return TRUE
