/mob/proc/say()
	return


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

	if(use_me)
		emote("me", EMOTE_VISIBLE, message, TRUE)
	else
		emote(message, EMOTE_VISIBLE, null, TRUE)


/mob/proc/say_dead(var/message)
	var/name = real_name

	if(!client)
		return

	if(!client.holder && !GLOB.dsay_allowed)
		to_chat(src, "<span class='warning'>Deadchat is globally muted</span>")
		return

	if(client?.prefs && !(client.prefs.toggles_chat & CHAT_DEAD))
		to_chat(usr, "<span class='warning'>You have deadchat muted.</span>")
		return

	for(var/mob/M in GLOB.player_list)
		if(isnewplayer(M))
			continue

		var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span> [M != src ? "(<a href='byond://?src=[REF(M)];track=[REF(src)]'>follow</a>)" : ""] says, <span class='message'>\"[message]\"</span></span>"
		if(M.client && M.stat == DEAD && (M.client.prefs.toggles_chat & CHAT_DEAD))
			to_chat(M, rendered)

		else if(check_other_rights(M.client, R_ADMIN, FALSE) && (M.client.prefs.toggles_chat & CHAT_DEAD)) // Show the message to admins/mods with deadchat toggled on
			to_chat(M, rendered)

/*
   ***Deprecated***
   let this be handled at the hear_say or hear_radio proc
   This is left in for robot speaking when humans gain binary channel access until I get around to rewriting
   robot_talk() proc.
   There is no language handling build into it however there is at the /mob level so we accept the call
   for it but just ignore it.
*/

/mob/proc/say_quote(var/message, var/datum/language/speaking = null)
        var/verb = "says"
        var/ending = copytext(message, length(message))
        if(ending == "!")
                verb = pick("exclaims","shouts","yells")
        else if(ending== "?")
                verb = "asks"

        return verb


/mob/proc/emote(var/act, var/type, var/message, player_caused)
	if(act == "me")
		return custom_emote(type, message, player_caused)

/mob/proc/get_ear()
	// returns an atom representing a location on the map from which this
	// mob can hear things

	// should be overloaded for all mobs whose "ear" is separate from their "mob"

	return get_turf(src)

/mob/proc/say_test(var/text)
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "0"

//parses the message mode code (e.g. :h, :w) from text, such as that supplied to say.
//returns the message mode string or null for no message mode.
//standard mode is the mode returned for the special ';' radio code.
/mob/proc/parse_message_mode(var/message, var/standard_mode = "headset")
	if(length(message) >= 1 && copytext(message, 1, 2) == ";")
		return standard_mode

	if(length(message) >= 2)
		var/channel_prefix = copytext(message, 1 ,3)
		return department_radio_keys[channel_prefix]

	return null