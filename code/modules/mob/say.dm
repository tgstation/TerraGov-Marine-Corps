/mob/proc/say()
	return

/mob/verb/whisper()
	set name = "Whisper"
	set category = "IC"
	return

/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"
	if(say_disabled)	//This is here to try to identify lag problems
		usr << "\red Speech is currently admin-disabled."
		return
	if(message == "*dance")
		set_typing_indicator(0)
		usr.say(message)
		return
	if(usr.talked == 2)
		usr << "\red Your spam has been consumed for it's nutritional value."
		return
	if((usr.talked == 1) && (usr.chatWarn >= 5))
		usr.talked = 2
		usr << "\red You have been flagged for spam.  You may not speak for at least [usr.chatWarn] seconds (if you spammed alot this might break and never unmute you).  This number will increase each time you are flagged for spamming"
		if(usr.chatWarn >= 5)
			message_admins("[key_name(usr, usr.client)] is spamming like crazy. Their current chatwarn is [usr.chatWarn]. ")
		spawn(usr.chatWarn*10)
			usr.talked = 0
			usr << "\blue You may now speak again."
			usr.chatWarn++
		return
	else if(usr.talked == 1)
		usr << "\blue You just said something, take a breath."
		usr.chatWarn++
		return




	set_typing_indicator(0)
	usr.say(message)
	usr.talked = 1
	spawn (10)
		if (usr.talked ==2)
			return
		usr.talked = 0


/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "\red Speech is currently admin-disabled."
		return

	if(usr.talked == 2)
		usr << "\red Your spam has been consumed for it's nutritional value."
		return
	if((usr.talked == 1) && (usr.chatWarn >= 5))
		usr.talked = 2
		usr << "\red You have been flagged for spam.  You may not speak for at least [usr.chatWarn] seconds (if you spammed alot this might break and never unmute you).  This number will increase each time you are flagged for spamming"
		if(usr.chatWarn >= 5)
			message_admins("[key_name(usr, usr.client)] is spamming like crazy. Their current chatwarn is [usr.chatWarn]. ")
		spawn(usr.chatWarn*10)
			usr.talked = 0
			usr << "\blue You may now speak again."
			usr.chatWarn++
		return
	else if(usr.talked == 1)
		usr << "\blue You just said something, take a breath."
		usr.chatWarn++
		return

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	set_typing_indicator(0)
	if(use_me)
		usr.emote("me",usr.emote_type,message, TRUE)
	else
		usr.emote(message, 1, null, TRUE)
	usr.talked = 1
	spawn (10)
		if (usr.talked ==2)
			return
		usr.talked = 0

/mob/proc/say_dead(var/message)
	var/name = src.real_name

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "\red Speech is currently admin-disabled."
		return
	if(usr.talked == 2)
		usr << "\red Your spam has been consumed for it's nutritional value."
		return
	if((usr.talked == 1) && (usr.chatWarn >= 5))
		usr.talked = 2
		usr << "\red You have been flagged for spam.  You may not speak for at least [usr.chatWarn] seconds (if you spammed alot this might break and never unmute you).  This number will increase each time you are flagged for spamming"
		if(usr.chatWarn >10)
			message_admins("[key_name(usr, usr.client)] is spamming like a dirty bitch, their current chatwarn is [usr.chatWarn]. ")
		spawn(usr.chatWarn*10)
			usr.talked = 0
			usr << "\blue You may now speak again."
			usr.chatWarn++
		return
	else if(usr.talked == 1)
		usr << "\blue You just said something, take a breath."
		usr.chatWarn++
		return



	if(!src.client) //Somehow
		return

	if(!src.client.holder)
		if(!dsay_allowed)
			src << "\red Deadchat is globally muted"
			return

	if(client && client.prefs && !(client.prefs.toggles_chat & CHAT_DEAD))
		usr << "\red You have deadchat muted."
		return
/*
	if(mind && mind.name)
		name = "[mind.name]"
	else
		name = real_name

	if(name != real_name)
		alt_name = " (died as [real_name])"
*/
	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span> says, <span class='message'>\"[message]\"</span></span>"

	for(var/mob/M in player_list)
		if(istype(M, /mob/new_player))
			continue
		if(M.client && M.stat == DEAD && (M.client.prefs.toggles_chat & CHAT_DEAD))
			M << rendered
			continue

		if(M.client && M.client.holder && !is_mentor(M.client) && (M.client.prefs.toggles_chat & CHAT_DEAD) ) // Show the message to admins/mods with deadchat toggled on
			M << rendered	//Admins can hear deadchat, if they choose to, no matter if they're blind/deaf or not.

	usr.talked = 1
	spawn (5)
		if (usr.talked ==2)
			return
		usr.talked = 0

/mob/proc/say_understands(var/mob/other,var/datum/language/speaking = null)

	if (src.stat == 2)		//Dead
		return 1

	//Universal speak makes everything understandable, for obvious reasons.
	else if(src.universal_speak || src.universal_understand)
		return 1

	//Languages are handled after.
	if (!speaking)
		if(!other)
			return 1
		if(other.universal_speak)
			return 1
		if(isAI(src))
			return 1
		if (istype(other, src.type) || istype(src, other.type))
			return 1
		return 0

	//Language check.
	for(var/datum/language/L in src.languages)
		if(speaking.name == L.name)
			return 1

	return 0

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
        if(ending=="!")
                verb=pick("exclaims","shouts","yells")
        else if(ending=="?")
                verb="asks"

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
/mob/proc/parse_message_mode(var/message, var/standard_mode="headset")
	if(length(message) >= 1 && copytext(message,1,2) == ";")
		return standard_mode

	if(length(message) >= 2)
		var/channel_prefix = copytext(message, 1 ,3)
		return department_radio_keys[channel_prefix]

	return null

//parses the language code (e.g. :j) from text, such as that supplied to say.
//returns the language object only if the code corresponds to a language that src can speak, otherwise null.
/mob/proc/parse_language(var/message)
	if(length(message) >= 2)
		var/language_prefix = lowertext(copytext(message, 1 ,3))
		var/datum/language/L = language_keys[language_prefix]
		if (can_speak(L))
			return L

	return null
