GLOBAL_LIST_INIT(department_radio_prefixes, list(":", "."))

GLOBAL_LIST_INIT(department_radio_keys, list(
	MODE_KEY_R_HAND = MODE_R_HAND,
	MODE_KEY_L_HAND = MODE_L_HAND,
	MODE_KEY_INTERCOM = MODE_INTERCOM,

	MODE_KEY_DEPARTMENT = MODE_DEPARTMENT,

	RADIO_KEY_MEDICAL = RADIO_CHANNEL_MEDICAL,
	RADIO_KEY_ENGINEERING = RADIO_CHANNEL_ENGINEERING,
	RADIO_KEY_COMMAND = RADIO_CHANNEL_COMMAND,
	RADIO_KEY_ALPHA = RADIO_CHANNEL_ALPHA,
	RADIO_KEY_BRAVO = RADIO_CHANNEL_BRAVO,
	RADIO_KEY_CHARLIE = RADIO_CHANNEL_CHARLIE,
	RADIO_KEY_DELTA = RADIO_CHANNEL_DELTA,
	RADIO_KEY_CAS = RADIO_CHANNEL_CAS,
	RADIO_KEY_REQUISITIONS = RADIO_CHANNEL_REQUISITIONS,
))

GLOBAL_LIST_INIT(department_radio_keys_rebel, list(
	MODE_KEY_R_HAND = MODE_R_HAND,
	MODE_KEY_L_HAND = MODE_L_HAND,
	MODE_KEY_INTERCOM = MODE_INTERCOM,

	MODE_KEY_DEPARTMENT = MODE_DEPARTMENT,

	RADIO_KEY_MEDICAL = RADIO_CHANNEL_MEDICAL_REBEL,
	RADIO_KEY_ENGINEERING = RADIO_CHANNEL_ENGINEERING_REBEL,
	RADIO_KEY_COMMAND = RADIO_CHANNEL_COMMAND_REBEL,
	RADIO_KEY_ALPHA = RADIO_CHANNEL_ALPHA_REBEL,
	RADIO_KEY_BRAVO = RADIO_CHANNEL_BRAVO_REBEL,
	RADIO_KEY_CHARLIE = RADIO_CHANNEL_CHARLIE_REBEL,
	RADIO_KEY_DELTA = RADIO_CHANNEL_DELTA_REBEL,
	RADIO_KEY_CAS = RADIO_CHANNEL_CAS_REBEL,
	RADIO_KEY_REQUISITIONS = RADIO_CHANNEL_REQUISITIONS_REBEL,
))

GLOBAL_LIST_INIT(department_radio_keys_som, list(
	MODE_KEY_R_HAND = MODE_R_HAND,
	MODE_KEY_L_HAND = MODE_L_HAND,
	MODE_KEY_INTERCOM = MODE_INTERCOM,

	MODE_KEY_DEPARTMENT = MODE_DEPARTMENT,

	RADIO_KEY_MEDICAL = RADIO_CHANNEL_MEDICAL_SOM,
	RADIO_KEY_ENGINEERING = RADIO_CHANNEL_ENGINEERING_SOM,
	RADIO_KEY_COMMAND = RADIO_CHANNEL_COMMAND_SOM,
	RADIO_KEY_ZULU = RADIO_CHANNEL_ZULU,
	RADIO_KEY_YANKEE = RADIO_CHANNEL_YANKEE,
	RADIO_KEY_XRAY = RADIO_CHANNEL_XRAY,
	RADIO_KEY_WHISKEY = RADIO_CHANNEL_WHISKEY,
))

/mob/living/proc/Ellipsis(original_msg, chance = 50, keep_words)
	if(chance <= 0)
		return "..."
	if(chance >= 100)
		return original_msg

	var/list/words = splittext(original_msg," ")
	var/list/new_words = list()

	var/new_msg = ""

	for(var/w in words)
		if(prob(chance))
			new_words += "..."
			if(!keep_words)
				continue
		new_words += w

	new_msg = jointext(new_words," ")

	return new_msg


/mob/living/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	var/static/list/crit_allowed_modes = list(MODE_WHISPER = TRUE, MODE_ALIEN = TRUE)
	var/static/list/unconscious_allowed_modes = list(MODE_ALIEN = TRUE)
	var/talk_key = get_key(message)

	var/static/list/one_character_prefix = list(MODE_HEADSET = TRUE, MODE_ROBOT = TRUE, MODE_WHISPER = TRUE, MODE_SING = TRUE)

	var/ic_blocked = FALSE
	if(client && !forced && CHAT_FILTER_CHECK(message))
		//The filter doesn't act on the sanitized message, but the raw message.
		ic_blocked = TRUE

	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	if(ic_blocked)
		//The filter warning message shows the sanitized message though.
		to_chat(src, span_warning("That message contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[message]\"</span>"))
		SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		return

	var/datum/saymode/saymode = get_saymode(message, talk_key)
	var/message_mode = get_message_mode(message)
	var/original_message = message
	var/in_critical = InCritical()

	if(one_character_prefix[message_mode])
		message = copytext_char(message, 2)
	else if(message_mode || saymode)
		message = copytext_char(message, 3)
	message = trim_left(message)

	if(stat == DEAD)
		say_dead(original_message)
		return

	if(check_emote(original_message) || !can_speak_basic(original_message, ignore_spam))
		return

	if(in_critical)
		if(!(crit_allowed_modes[message_mode]))
			return
	else if(stat == UNCONSCIOUS)
		if(!(unconscious_allowed_modes[message_mode]))
			return

	// language comma detection.
	var/datum/language/message_language = get_message_language(message)
	if(message_language)
		// No, you cannot speak in xenocommon just because you know the key
		if(can_speak_in_language(message_language))
			language = message_language
		message = copytext_char(message, 3)

		// Trim the space if they said ",0 I LOVE LANGUAGES"
		message = trim_left(message)

	if(!language)
		language = get_default_language()

	// Detection of language needs to be before inherent channels, because
	// AIs use inherent channels for the holopad. Most inherent channels
	// ignore the language argument however.
	if(saymode && !saymode.handle_message(src, message, language))
		return

	if(!can_speak_vocal(message))
		to_chat(src, span_warning("You find yourself unable to speak!"))
		return

	var/message_range = 7

	log_talk(message, LOG_SAY)

	message = treat_message(message)
	SEND_SIGNAL(src, COMSIG_MOB_SAY, args)

	if(!message)
		return

	spans |= speech_span

	if(language)
		var/datum/language/L = GLOB.language_datum_instances[language]
		spans |= L.spans

	if(message_mode == MODE_SING)
		var/randomnote = pick("\u2669", "\u266A", "\u266B")
		spans |= SPAN_SINGING
		message = "[randomnote] [message] [randomnote]"

	var/radio_return = radio(message, message_mode, spans, language)
	if(radio_return & ITALICS)
		spans |= SPAN_ITALICS

	if(radio_return & REDUCE_RANGE)
		message_range = 1

	if(radio_return & NOPASS)
		return TRUE

	send_speech(message, message_range, src, bubble_type, spans, language, message_mode)

	return TRUE


/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if(!client)
		return

	// Create map text prior to modifying message for goonchat
	if (client?.prefs.chat_on_map && stat != UNCONSCIOUS && !isdeaf(src) && (client.prefs.see_chat_non_mob || ismob(speaker)))
		create_chat_message(speaker, message_language, raw_message, spans, message_mode)

	var/deaf_message
	var/deaf_type
	var/avoid_highlight
	if(istype(speaker, /atom/movable/virtualspeaker))
		var/atom/movable/virtualspeaker/virt = speaker
		avoid_highlight = src == virt.source
	else
		avoid_highlight = src == speaker

	if(speaker != src)
		if(!radio_freq) //These checks have to be seperate, else people talking on the radio will make "You can't hear yourself!" appear when hearing people over the radio while deaf.
			deaf_message = "[span_name("[speaker]")] [speaker.verb_say] something but you cannot hear [speaker.p_them()]."
			deaf_type = 1
	else
		deaf_message = span_notice("You can't hear yourself!")
		deaf_type = 2 // Since you should be able to hear yourself without looking

	// Recompose message for AI hrefs, language incomprehension.
	message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mode)
	message = hear_intercept(message, speaker, message_language, raw_message, radio_freq, spans, message_mode)
	show_message(message, 2, deaf_message, deaf_type, avoid_highlight)
	return message


/mob/living/proc/hear_intercept(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	return message


/mob/living/send_speech(message, message_range = 6, obj/source = src, bubble_type = bubble_icon, list/spans, datum/language/message_language=null, message_mode)
	var/static/list/eavesdropping_modes = list(MODE_WHISPER = TRUE, MODE_WHISPER_CRIT = TRUE)
	var/eavesdrop_range = 0
	if(eavesdropping_modes[message_mode])
		eavesdrop_range = EAVESDROP_EXTRA_RANGE
	var/list/listening = get_hearers_in_view(message_range+eavesdrop_range, source)
	var/list/the_dead = list()
	for(var/_M in GLOB.player_list)
		var/mob/M = _M
		if(M.stat != DEAD) //not dead, not important
			continue
		if(!M.client || !client) //client is so that ghosts don't have to listen to mice
			continue
		if(get_dist(M, src) > 7 || M.z != z) //they're out of range of normal hearing
			if(!(M.client.prefs.toggles_chat & CHAT_GHOSTEARS))
				continue
		if((istype(M.remote_control, /mob/camera/aiEye) || isAI(M)) && !GLOB.cameranet.checkTurfVis(src))
			continue // AI can't hear what they can't see
		listening |= M
		the_dead[M] = TRUE

	var/eavesdropping
	var/eavesrendered
	if(eavesdrop_range)
		eavesdropping = stars(message)
		eavesrendered = compose_message(src, message_language, eavesdropping, , spans, message_mode)

	var/rendered = compose_message(src, message_language, message, , spans, message_mode)
	for(var/_AM in listening)
		var/atom/movable/AM = _AM
		if(eavesdrop_range && get_dist(source, AM) > eavesdrop_range && !(the_dead[AM]))
			AM.Hear(eavesrendered, src, message_language, eavesdropping, , spans, message_mode)
		else
			AM.Hear(rendered, src, message_language, message, , spans, message_mode)

	//speech bubble
	var/list/speech_bubble_recipients = list()
	for(var/mob/M in listening)
		if(M.client && !M.client.prefs.chat_on_map)
			speech_bubble_recipients.Add(M.client)
	var/image/I = image('icons/mob/talk.dmi', src, "[bubble_type][say_test(message)]", FLY_LAYER)
	I.appearance_flags = APPEARANCE_UI_TRANSFORM
	INVOKE_ASYNC(GLOBAL_PROC, /.proc/animate_speech_bubble, I, speech_bubble_recipients, TYPING_INDICATOR_LIFETIME)


/mob/living/GetVoice()
	return name

/mob/living/IsVocal()
	. = ..()

	if(HAS_TRAIT(src, TRAIT_MUTED))
		return FALSE

/mob/living/proc/can_speak_vocal(message) //Check AFTER handling of xeno channels
	if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return FALSE

	if(!IsVocal())
		return FALSE

	return TRUE


/mob/living/proc/get_key(message)
	var/prefix = message[1]
	if(length(message) >= 2 && (prefix in GLOB.department_radio_prefixes))
		return lowertext(message[2])

/mob/living/proc/get_message_language(message)
	if(length(message) >= 2 && message[1] == ",")
		var/key = message[2]
		for(var/ld in GLOB.all_languages)
			var/datum/language/LD = ld
			if(initial(LD.key) == key)
				return LD
	return null


/mob/living/proc/treat_message(message)
	// check for and apply punctuation
	var/end = copytext(message, length(message))
	if(!(end in list("!", ".", "?", ":", "\"", "-")))
		message += "."

	SEND_SIGNAL(src, COMSIG_LIVING_TREAT_MESSAGE, args)

	message = capitalize(message)

	return message


/mob/living/proc/radio(message, message_mode, list/spans, language)
	switch(message_mode)
		if(MODE_WHISPER)
			return ITALICS
		if(MODE_R_HAND)
			if(r_hand)
				return r_hand.talk_into(src, message, , spans, language)
			return ITALICS | REDUCE_RANGE
		if(MODE_L_HAND)
			if(l_hand)
				return l_hand.talk_into(src, message, , spans, language)
			return ITALICS | REDUCE_RANGE

		if(MODE_INTERCOM)
			for(var/obj/item/radio/intercom/I in view(1, null))
				I.talk_into(src, message, , spans, language)
			return ITALICS | REDUCE_RANGE

		if(MODE_BINARY)
			return ITALICS | REDUCE_RANGE //Does not return 0 since this is only reached by humans, not borgs or AIs.

	return 0


/mob/living/say_mod(input, message_mode, datum/language/language)
	if(message_mode == MODE_WHISPER)
		. = verb_whisper
	else if(message_mode == MODE_WHISPER_CRIT)
		. = "[verb_whisper] in [p_their()] last breath"
	else if(has_status_effect(/datum/status_effect/speech/stutter))
		. = "stammers"
	else if(message_mode == MODE_SING)
		. = verb_sing
	else
		. = ..()


/mob/living/whisper(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	say("#[message]", bubble_type, spans, sanitize, language, ignore_spam, forced)


///Returns false by default
/mob/proc/binarycheck()
	return FALSE


/mob/living/can_speak(message) //For use outside of Say()
	if(can_speak_basic(message) && can_speak_vocal(message))
		return TRUE


/mob/living/proc/can_speak_basic(message, ignore_spam = FALSE) //Check BEFORE handling of xeno and ling channels
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, span_danger("You cannot speak in IC (muted)."))
			return FALSE
		if(!ignore_spam && client.handle_spam_prevention(message, MUTE_IC))
			return FALSE

	return TRUE


/mob/living/proc/get_saymode(message, talk_key)
	return SSradio.saymodes[talk_key]
