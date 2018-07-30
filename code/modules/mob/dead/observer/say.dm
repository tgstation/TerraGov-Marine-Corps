/mob/dead/observer/say(var/message)
	message = sanitize(copytext(message, 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	log_say("Ghost/[src.key] : [message]")

	if (src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			src << "\red You cannot talk in deadchat (muted)."
			return

		if (src.client.handle_spam_prevention(message,MUTE_DEADCHAT))
			return

	. = src.say_dead(message)




/mob/dead/observer/hear_say(var/message, var/verb = "says", var/datum/language/language = null, var/alt_name = "",var/italics = 0, var/mob/speaker = null, var/sound/speech_sound, var/sound_vol)
	if(!client)
		return

	if(speaker && !speaker.client && client.prefs.toggles_chat & CHAT_GHOSTEARS && speaker.z == z && get_dist(speaker, src) <= world.view)
			//Does the speaker have a client?  It's either random stuff that observers won't care about (Experiment 97B says, 'EHEHEHEHEHEHEHE')
			//Or someone snoring.  So we make it where they won't hear it.
		return

	if(sleeping || stat == 1)
		hear_sleep(message)
		return

	var/style = "body"
	var/comm_paygrade = ""

	if(language)
		style = language.colour

	var/speaker_name = speaker.name
	if(istype(speaker, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = speaker
		speaker_name = H.GetVoice()
		comm_paygrade = H.get_paygrade()

	if(italics)
		message = "<i>[message]</i>"

	var/track = null

	if(italics && client.prefs.toggles_chat & CHAT_GHOSTRADIO)
		return
	if(speaker_name != speaker.real_name && speaker.real_name)
		speaker_name = "[speaker.real_name] ([speaker_name])"
	track = "(<a href='byond://?src=\ref[src];track=\ref[speaker]'>follow</a>) "
	if(client.prefs.toggles_chat & CHAT_GHOSTEARS && speaker.z == z && get_dist(speaker, src) <= world.view)
		message = "<b>[message]</b>"

	src << "<span class='game say'><span class='name'>[comm_paygrade][speaker_name]</span>[alt_name] [track][verb], <span class='message'><span class='[style]'>\"[message]\"</span></span></span>"
	if (speech_sound && (get_dist(speaker, src) <= world.view && src.z == speaker.z))
		var/turf/source = speaker? get_turf(speaker) : get_turf(src)
		src.playsound_local(source, speech_sound, sound_vol, 1)







/mob/dead/observer/emote(var/act, var/type, var/message)
	message = sanitize(copytext(message, 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	if(act != "me")
		return

	log_emote("Ghost/[src.key] : [message]")

	if(src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			src << "\red You cannot emote in deadchat (muted)."
			return

		if(src.client.handle_spam_prevention(message, MUTE_DEADCHAT))
			return

	. = src.emote_dead(message)

/*
	for (var/mob/M in hearers(null, null))
		if (!M.stat)
			if(M.job == "Chaplain")
				if (prob (49))
					M.show_message("<span class='game'><i>You hear muffled speech... but nothing is there...</i></span>", 2)
					if(prob(20))
						playsound(src.loc, pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)
				else
					M.show_message("<span class='game'><i>You hear muffled speech... you can almost make out some words...</i></span>", 2)
//				M.show_message("<span class='game'><i>[stutter(message)]</i></span>", 2)
					if(prob(30))
						playsound(src.loc, pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)
			else
				if (prob(50))
					return
				else if (prob (95))
					M.show_message("<span class='game'><i>You hear muffled speech... but nothing is there...</i></span>", 2)
					if(prob(20))
						playsound(src.loc, pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)
				else
					M.show_message("<span class='game'><i>You hear muffled speech... you can almost make out some words...</i></span>", 2)
//				M.show_message("<span class='game'><i>[stutter(message)]</i></span>", 2)
					playsound(src.loc, pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)
*/
