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

	custom_emote(EMOTE_VISIBLE, message, TRUE)


/mob/verb/whisper_verb(message as text)
	set name = "Whisper"
	set category = "IC"

	if(!message)
		return

	whisper(message)


/mob/proc/whisper(message, datum/language/language)
	say(message, language)


/mob/proc/say_dead(message)
	var/name = real_name

	if(!client)
		return

	if(!client.holder && !GLOB.dsay_allowed)
		to_chat(src, "<span class='warning'>Deadchat is globally muted</span>")
		return

	if(client.prefs.muted & MUTE_DEADCHAT)
		to_chat(src, "<span class='warning'>You cannot emote in deadchat (muted).</span>")
		return

	if(client?.prefs && !(client.prefs.toggles_chat & CHAT_DEAD))
		to_chat(usr, "<span class='warning'>You have deadchat muted.</span>")
		return

	log_talk(message, LOG_SAY, "ghost")

	for(var/i in GLOB.player_list)
		var/mob/M = i

		if(isnewplayer(M))
			continue

		var/rendered = "[M != src ? FOLLOW_LINK(M, src) : ""] <span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span> says, <span class='message'>\"[message]\"</span></span>"
		if(M.client && M.stat == DEAD && (M.client.prefs.toggles_chat & CHAT_DEAD))
			to_chat(M, rendered)

		else if(check_other_rights(M.client, R_ADMIN, FALSE) && (M.client.prefs.toggles_chat & CHAT_DEAD)) // Show the message to admins/mods with deadchat toggled on
			to_chat(M, rendered)


/mob/proc/emote(act, type, message, player_caused)
	return custom_emote(type, message, player_caused)


/mob/proc/get_message_mode(message)
	var/key = copytext(message, 1, 2)
	if(key == "#")
		return MODE_WHISPER
	else if(key == ";")
		return MODE_HEADSET
	else if(length(message) > 2 && (key in GLOB.department_radio_prefixes))
		var/key_symbol = lowertext(copytext(message, 2, 3))
		return GLOB.department_radio_keys[key_symbol]


/mob/proc/check_emote(message)
	if(copytext(message, 1, 2) == "*")
		emote(copytext(message, 2, length(message) + 1), EMOTE_VISIBLE, null, TRUE)
		return TRUE