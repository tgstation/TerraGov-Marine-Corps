GLOBAL_LIST_INIT(freqtospan, list(
	"[ALPHA_FREQ]" = "alpharadio",
	"[BRAVO_FREQ]" = "bravoradio",
	"[CHARLIE_FREQ]" = "charlieradio",
	"[DELTA_FREQ]" = "deltaradio",
	"[IMP_FREQ]" = "impradio",
	"[COMM_FREQ]" = "comradio",
	"[AI_FREQ]" = "airadio",
	"[SEC_FREQ]" = "secradio",
	"[ENG_FREQ]" = "engradio",
	"[MED_FREQ]" = "medradio",
	"[SUP_FREQ]" = "supradio"
	))


/atom/movable/proc/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(!can_speak())
		return

	if(message == "" || !message)
		return

	spans |= get_spans()

	if(!language)
		language = get_default_language()

	send_speech(message, 7, src, , spans, message_language = language)


/atom/movable/proc/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	SEND_SIGNAL(src, COMSIG_MOVABLE_HEAR, message, speaker, message_language, raw_message, radio_freq, spans, message_mode)


/atom/movable/proc/can_speak()
	return TRUE


/atom/movable/proc/send_speech(message, range = 7, obj/source = src, bubble_type, list/spans, datum/language/message_language, message_mode)
	var/rendered = compose_message(src, message_language, message, , spans, message_mode)
	for(var/_AM in get_hearers_in_view(range, source))
		var/atom/movable/AM = _AM
		AM.Hear(rendered, src, message_language, message, , spans, message_mode)


//To get robot span classes, stuff like that.
/atom/movable/proc/get_spans()
	return list()


/atom/movable/proc/compose_message(atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode, face_name = FALSE)
	//This proc uses text() because it is faster than appending strings. Thanks BYOND.
	//Basic span
	var/spanpart1 = "<span class='[radio_freq ? get_radio_span(radio_freq) : "game say"]'>"
	//Start name span.
	var/spanpart2 = "<span class='name'>"
	//Radio freq/name display
	var/freqpart = radio_freq ? "\[[get_radio_name(radio_freq)]\] " : ""
	//Speaker name
	var/namepart = "[speaker.GetVoice()][speaker.get_alt_name()]"
	if(face_name && ishuman(speaker))
		var/mob/living/carbon/human/H = speaker
		namepart = "[H.get_face_name()]" //So "fake" speaking like in hallucinations does not give the speaker away if disguised
	//End name span.
	var/endspanpart = "</span>"

	//Message
	var/messagepart = " <span class='message'>[lang_treat(speaker, message_language, raw_message, spans, message_mode)]</span></span>"

	var/languageicon = ""
	var/datum/language/D = GLOB.language_datum_instances[message_language]
	if(istype(D) && D.display_icon(src))
		languageicon = "[D.get_icon()] "

	return "[spanpart1][spanpart2][freqpart][languageicon][compose_track_href(speaker, namepart)][compose_job(speaker, message_language, raw_message, radio_freq)][namepart][endspanpart][messagepart]"


/atom/movable/proc/compose_track_href(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""


/atom/movable/proc/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""


/atom/movable/proc/say_mod(input, message_mode)
	var/ending = copytext(input, length(input))
	if(copytext(input, length(input) - 1) == "!!")
		return verb_yell
	else if(ending == "?")
		return verb_ask
	else if(ending == "!")
		return verb_exclaim
	else
		return verb_say


/atom/movable/proc/say_quote(input, list/spans = list(), message_mode)
	if(!input)
		input = "..."

	if(copytext(input, length(input) - 1) == "!!")
		spans |= SPAN_YELL

	var/spanned = attach_spans(input, spans)
	return "[say_mod(input, message_mode)], \"[spanned]\""


/atom/movable/proc/lang_treat(atom/movable/speaker, datum/language/language, raw_message, list/spans = list(), message_mode)
	if(has_language(language))
		var/atom/movable/AM = speaker.GetSource()
		if(AM) //Basically means "if the speaker is virtual"
			return AM.say_quote(raw_message, spans, message_mode)
		else
			return speaker.say_quote(raw_message, spans, message_mode)
	else if(language)
		var/atom/movable/AM = speaker.GetSource()
		var/datum/language/D = GLOB.language_datum_instances[language]
		raw_message = D.scramble(raw_message)
		if(AM)
			return AM.say_quote(raw_message, spans, message_mode)
		else
			return speaker.say_quote(raw_message, spans, message_mode)
	else
		return "makes a strange sound."


/proc/get_radio_span(freq)
	var/returntext = GLOB.freqtospan["[freq]"]
	if(returntext)
		return returntext
	return "radio"


/proc/get_radio_name(freq)
	var/returntext = reverseradiochannels["[freq]"]
	if(returntext)
		return returntext
	return "[copytext("[freq]", 1, 4)].[copytext("[freq]", 4, 5)]"


/proc/attach_spans(input, list/spans)
	return "[message_spans_start(spans)][input]</span>"


/proc/message_spans_start(list/spans)
	var/output = "<span class='"
	for(var/S in spans)
		output = "[output][S] "
	output = "[output]'>"
	return output


/proc/say_test(text)
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "0"


/proc/get_hearers_in_view(R, atom/source)
	// Returns a list of hearers in view(R) from source (ignoring luminosity). Used in saycode.
	var/turf/T = get_turf(source)
	. = list()

	if(!T)
		return

	var/list/processing_list = list()
	if (R == 0) // if the range is zero, we know exactly where to look for, we can skip view
		processing_list += T.contents // We can shave off one iteration by assuming turfs cannot hear
	else  // A variation of get_hear inlined here to take advantage of the compiler's fastpath for obj/mob in view
		var/lum = T.luminosity
		T.luminosity = 6 // This is the maximum luminosity
		for(var/mob/M in view(R, T))
			processing_list += M
		for(var/obj/O in view(R, T))
			processing_list += O
		T.luminosity = lum

	while(processing_list.len) // recursive_hear_check inlined here
		var/atom/A = processing_list[1]
		. += A
		processing_list.Cut(1, 2)
		processing_list += A.contents


/atom/movable/proc/GetVoice()
	return "[src]"	//Returns the atom's name, prepended with 'The' if it's not a proper noun


/atom/movable/proc/IsVocal()
	return TRUE


/atom/movable/proc/get_alt_name()


//HACKY VIRTUALSPEAKER STUFF BEYOND THIS POINT
//these exist mostly to deal with the AIs hrefs and job stuff.

/atom/movable/proc/GetJob()

/atom/movable/proc/GetSource()

/atom/movable/proc/GetRadio()


//VIRTUALSPEAKERS
/atom/movable/virtualspeaker
	var/job
	var/atom/movable/source
	var/obj/item/radio/radio

INITIALIZE_IMMEDIATE(/atom/movable/virtualspeaker)
/atom/movable/virtualspeaker/Initialize(mapload, atom/movable/M, radio)
	. = ..()
	radio = radio
	source = M
	if (istype(M))
		name = M.GetVoice()
		verb_say = M.verb_say
		verb_ask = M.verb_ask
		verb_exclaim = M.verb_exclaim
		verb_yell = M.verb_yell

	// The mob's job identity
	if(ishuman(M))
		// Humans use their job as seen on the crew manifest. This is so the AI
		// can know their job even if they don't carry an ID.
		var/datum/data/record/findjob = find_record("name", name, GLOB.datacore.general)
		if(findjob)
			job = findjob.fields["rank"]
		else
			job = "Unknown"
	else if(iscarbon(M))  // Carbon nonhuman
		job = "No ID"
	else if(isAI(M))  // AI
		job = "AI"
	else if(iscyborg(M))  // Cyborg
		job = "Cyborg"
	else if(isobj(M))  // Cold, emotionless machines
		job = "Machine"
	else  // Unidentifiable mob
		job = "Unknown"


/atom/movable/virtualspeaker/GetJob()
	return job


/atom/movable/virtualspeaker/GetSource()
	return source


/atom/movable/virtualspeaker/GetRadio()
	return radio