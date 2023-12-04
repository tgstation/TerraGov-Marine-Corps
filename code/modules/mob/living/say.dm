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

GLOBAL_LIST_INIT(department_radio_keys_som, list(
	MODE_KEY_R_HAND = MODE_R_HAND,
	MODE_KEY_L_HAND = MODE_L_HAND,
	MODE_KEY_INTERCOM = MODE_INTERCOM,

	MODE_KEY_DEPARTMENT = MODE_DEPARTMENT,

	RADIO_KEY_MEDICAL = RADIO_CHANNEL_MEDICAL_SOM,
	RADIO_KEY_ENGINEERING = RADIO_CHANNEL_ENGINEERING_SOM,
	RADIO_KEY_COMMAND = RADIO_CHANNEL_COMMAND_SOM,
	RADIO_KEY_ALPHA = RADIO_CHANNEL_ZULU,
	RADIO_KEY_BRAVO = RADIO_CHANNEL_YANKEE,
	RADIO_KEY_CHARLIE = RADIO_CHANNEL_XRAY,
	RADIO_KEY_DELTA = RADIO_CHANNEL_WHISKEY,
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


	var/datum/saymode/saymode = get_saymode(message, talk_key)
	var/message_mode = get_message_mode(message)
	var/original_message = message
	var/in_critical = InCritical()

	if(one_character_prefix[message_mode])
		message = copytext_char(message, 2)
	else if(message_mode || saymode)
		message = copytext_char(message, 3)
	message = trim_left(message)

	var/list/filter_result
	var/list/soft_filter_result
	if(client && !forced)
		//The filter doesn't act on the sanitized message, but the raw message.
		filter_result = CAN_BYPASS_FILTER(src) ? null : is_ic_filtered(message)
		if(!filter_result)
			soft_filter_result = CAN_BYPASS_FILTER(src) ? null : is_soft_ic_filtered(message)

	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	if(filter_result)
		//The filter warning message shows the sanitized message though.
		to_chat(src, span_warning("That message contained a word prohibited in IC chat! Consider reviewing the server rules."))
		to_chat(src, span_warning("\"[message]\""))
		REPORT_CHAT_FILTER_TO_USER(src, filter_result)
		log_filter("IC", message, filter_result)
		SSblackbox.record_feedback("tally", "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		return FALSE

	if(soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			SSblackbox.record_feedback("tally", "soft_ic_blocked_words", 1, lowertext(config.soft_ic_filter_regex.match))
			log_filter("Soft IC", message, filter_result)
			return FALSE
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[message]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[message]\"")
		SSblackbox.record_feedback("tally", "passed_soft_ic_blocked_words", 1, lowertext(config.soft_ic_filter_regex.match))
		log_filter("Soft IC (Passed)", message, filter_result)

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

	var/list/message_data = treat_message(message) // unfortunately we still need this
	message = message_data["message"]
	var/tts_message = message_data["tts_message"]
	var/list/tts_filter = message_data["tts_filter"]

	// Detection of language needs to be before inherent channels, because
	// AIs use inherent channels for the holopad. Most inherent channels
	// ignore the language argument however.
	if(saymode && !saymode.handle_message(src, message, language))
		return

	if(!can_speak_vocal(message))
		to_chat(src, span_warning("You find yourself unable to speak!"))
		return

	var/message_range = 7

	log_talk(original_message, LOG_SAY)

	var/last_message = message
	var/sigreturn = SEND_SIGNAL(src, COMSIG_MOB_SAY, args)
	if(last_message != message)
		tts_message = message
	if(sigreturn & COMPONENT_UPPERCASE_SPEECH)
		message = uppertext(message)

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

	send_speech(message, message_range, src, bubble_type, spans, language, message_mode, tts_message = tts_message, tts_filter = tts_filter)

	return TRUE


/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if(!client)
		return FALSE

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
	var/message_success = show_message(message, 2, deaf_message, deaf_type, avoid_highlight)
	return message_success


/mob/living/proc/hear_intercept(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	return message


/mob/living/send_speech(message_raw, message_range = 6, obj/source = src, bubble_type = bubble_icon, list/spans, datum/language/message_language=null, message_mode, tts_message, list/tts_filter)
	var/static/list/eavesdropping_modes = list(MODE_WHISPER = TRUE, MODE_WHISPER_CRIT = TRUE)
	var/eavesdrop_range = 0
	if(eavesdropping_modes[message_mode])
		eavesdrop_range = EAVESDROP_EXTRA_RANGE
	var/list/listening = get_hearers_in_view(message_range+eavesdrop_range, source)
	var/turf/src_turf = get_turf(src)
	for(var/mob/player_mob AS in SSmobs.dead_players_by_zlevel[src_turf.z])
		if(!client || isnull(player_mob)) //client is so that ghosts don't have to listen to mice
			continue
		if(get_dist(player_mob, src) > 7) //they're out of range of normal hearing
			if(!(player_mob?.client?.prefs.toggles_chat & CHAT_GHOSTEARS))
				continue
		listening |= player_mob

	var/eavesdropping
	var/eavesrendered
	if(eavesdrop_range)
		eavesdropping = stars(message_raw)
		eavesrendered = compose_message(src, message_language, eavesdropping, null, spans, message_mode)

	var/list/listened = list()
	var/rendered = compose_message(src, message_language, message_raw, null, spans, message_mode)
	for(var/atom/movable/listening_movable as anything in listening)
		if(!listening_movable)
			stack_trace("somehow theres a null returned from get_hearers_in_view() in send_speech!")
			continue
		var/heard
		if(eavesdrop_range && get_dist(source, listening_movable) > eavesdrop_range && !isobserver(listening_movable))
			heard = listening_movable.Hear(eavesrendered, src, message_language, eavesdropping, null, spans, message_mode)
		else
			heard = listening_movable.Hear(rendered, src, message_language, message_raw, null, spans, message_mode)
		if(heard && !isobserver(listening_movable)) // observers excluded cus we dont want tts to trigger on them(tts handles that)
			listened += listening_movable
	//Note, TG has a found_client var they use, piggybacking on unrelated say popups and runechat code
	//we dont do that since it'd probably be much more expensive to loop over listeners instead of just doing
	if(voice && !(client?.prefs.muted & MUTE_TTS) && !is_banned_from(ckey, "TTS"))
		var/tts_message_to_use = tts_message
		if(!tts_message_to_use)
			tts_message_to_use = message_raw

		var/list/filter = list()
		var/list/special_filter = list()
		var/voice_to_use = voice
		var/use_radio = FALSE
		if(length(voice_filter) > 0)
			filter += voice_filter

		if(length(tts_filter) > 0)
			filter += tts_filter.Join(",")
		if(ishuman(src))
			var/mob/living/carbon/human/human_speaker = src
			if(human_speaker.wear_mask)
				var/obj/item/clothing/mask/worn_mask = human_speaker.wear_mask
				if(istype(worn_mask))
					if(worn_mask.voice_override)
						voice_to_use = worn_mask.voice_override
					if(worn_mask.voice_filter)
						filter += worn_mask.voice_filter
					use_radio = worn_mask.use_radio_beeps_tts
		if(use_radio)
			special_filter += TTS_FILTER_RADIO
		if(issilicon(src))
			special_filter += TTS_FILTER_SILICON

		INVOKE_ASYNC(SStts, TYPE_PROC_REF(/datum/controller/subsystem/tts, queue_tts_message), src, html_decode(tts_message_to_use), message_language, voice_to_use, filter.Join(","), listened, message_range = message_range, volume_offset = (job?.job_flags & JOB_FLAG_LOUDER_TTS) ? 20 : 0, pitch = pitch, special_filters = special_filter.Join("|"))

	//speech bubble
	var/list/speech_bubble_recipients = list()
	for(var/mob/M in listening)
		if(M.client)
			speech_bubble_recipients.Add(M.client)
	var/image/I = image('icons/mob/effects/talk.dmi', src, "[bubble_type][say_test(message_raw)]", FLY_LAYER)
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay), I, speech_bubble_recipients, 30)

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


/mob/living/proc/treat_message(message, tts_message, tts_filter, capitalize_message = TRUE)
	RETURN_TYPE(/list)
	// check for and apply punctuation
	var/end = copytext(message, length(message))
	if(!(end in list("!", ".", "?", ":", "\"", "-")))
		message += "."

	tts_filter = list()
	var/list/data = list(message, tts_message, tts_filter)
	SEND_SIGNAL(src, COMSIG_LIVING_TREAT_MESSAGE, data)
	message = data[TREAT_MESSAGE_ARG]
	tts_message = data[TREAT_TTS_MESSAGE_ARG]
	tts_filter = data[TREAT_TTS_FILTER_ARG]

	if(!tts_message)
		tts_message = message

	if(capitalize_message)
		message = capitalize(message)
		tts_message = capitalize(tts_message)

	///caps the length of individual letters to 3: ex: heeeeeeyy -> heeeyy
	/// prevents TTS from choking on unrealistic text while keeping emphasis
	var/static/regex/length_regex = regex(@"(.+)\1\1\1", "gi")
	while(length_regex.Find(tts_message))
		var/replacement = tts_message[length_regex.index]+tts_message[length_regex.index]+tts_message[length_regex.index]
		tts_message = replacetext(tts_message, length_regex.match, replacement, length_regex.index)

	return list("message" = message, "tts_message" = tts_message, "tts_filter" = tts_filter)


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
		if(is_banned_from(ckey, "IC"))
			to_chat(src, span_warning("You are banned from IC chat."))
			return
		if(!ignore_spam && client.handle_spam_prevention(message, MUTE_IC))
			return FALSE

	return TRUE


/mob/living/proc/get_saymode(message, talk_key)
	return SSradio.saymodes[talk_key]
