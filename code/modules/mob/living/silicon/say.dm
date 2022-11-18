/mob/living/proc/robot_talk(message)
	log_talk(message, LOG_SAY)
	//Capitalization
	message = capitalize(message)
	//checks for and apply punctuation
	var/end = copytext_char(message, length_char(message))
	if(!(end in list("!", ".", "?", ":", "\"", "-")))
		message += "."

	var/desig = "Silicon"
	if(issilicon(src) || issynth(src))
		var/mob/living/S = src
		desig = trim_left(S.job.title)
	var/message_a = say_quote(message)
	var/rendered = "Robotic Talk, [span_name("[name]")] [span_message("[message_a]")]"
	for(var/mob/M in GLOB.player_list)
		if(M.binarycheck())
			if(isAI(M))
				var/renderedAI = span_binarysay("Robotic Talk, <a href='?src=[REF(M)];track=[html_encode(name)]'>[span_name("[name] ([desig])")]</a> [span_message("[message_a]")]")
				to_chat(M, renderedAI)
			else
				to_chat(M, span_binarysay("[rendered]"))
		if(isobserver(M))
			var/following = src
			// If the AI talks on binary chat, we still want to follow
			// it's camera eye, like if it talked on the radio
			if(isAI(src))
				var/mob/living/silicon/ai/AI = src
				following = AI.eyeobj
			var/link = FOLLOW_LINK(M, following)
			to_chat(M, span_binarysay("[link] [rendered]"))


/mob/living/silicon/binarycheck()
	return TRUE


/mob/living/silicon/radio(message, message_mode, list/spans, language)
	. = ..()
	if(. != 0)
		return

	if(message_mode == MODE_ROBOT)
		if(radio)
			radio.talk_into(src, message, , spans, language)
		return REDUCE_RANGE

	else if(message_mode in GLOB.radiochannels)
		if(radio)
			radio.talk_into(src, message, message_mode, spans, language)
			return ITALICS | REDUCE_RANGE

	return 0


/mob/living/silicon/get_message_mode(message)
	. = ..()
	if(..() == MODE_HEADSET)
		return MODE_ROBOT
