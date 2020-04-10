/mob/dead/observer/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message)
		return

	if(check_emote(message))
		return

	. = say_dead(message)


/mob/dead/observer/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	var/atom/movable/to_follow = speaker
	var/list/view_size = getviewsize(client.view)
	if(radio_freq)
		var/atom/movable/virtualspeaker/V = speaker
		if(isAI(V.source))
			var/mob/living/silicon/ai/S = V.source
			to_follow = S.eyeobj
		else
			to_follow = V.source

	else if(client && in_view_range(src, to_follow))
		raw_message = "<b>[raw_message]</b>"

	var/link = FOLLOW_LINK(src, to_follow)
	// Recompose the message, because it's scrambled by default
	message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mode)
	to_chat(src, "[link] [message]")
