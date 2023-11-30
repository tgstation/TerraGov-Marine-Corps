GLOBAL_LIST_INIT(freqtospan, list(
	"[FREQ_ALPHA]" = "alpharadio",
	"[FREQ_BRAVO]" = "bravoradio",
	"[FREQ_CHARLIE]" = "charlieradio",
	"[FREQ_DELTA]" = "deltaradio",
	"[FREQ_IMPERIAL]" = "impradio",
	"[FREQ_COMMAND]" = "comradio",
	"[FREQ_AI]" = "airadio",
	"[FREQ_CAS]" = "casradio",
	"[FREQ_ENGINEERING]" = "engradio",
	"[FREQ_MEDICAL]" = "medradio",
	"[FREQ_REQUISITIONS]" = "supradio",
	"[FREQ_ZULU]" = "zuluradio",
	"[FREQ_YANKEE]" = "yankeeradio",
	"[FREQ_XRAY]" = "xrayradio",
	"[FREQ_WHISKEY]" = "whiskeyradio",
	"[FREQ_COMMAND_SOM]" = "comradio",
	"[FREQ_ENGINEERING_SOM]" = "engradio",
	"[FREQ_MEDICAL_SOM]" = "medradio",
	))


/atom/movable/proc/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(!can_speak())
		return

	if(!message)
		return

	spans |= speech_span

	if(!language)
		language = get_default_language()

	send_speech(message, 7, src, , spans, message_language = language)


/atom/movable/proc/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOVABLE_HEAR, message, speaker, message_language, raw_message, radio_freq, spans, message_mode)
	return TRUE


/atom/movable/proc/can_speak()
	return TRUE


/atom/movable/proc/send_speech(message, range = 7, obj/source = src, bubble_type, list/spans, datum/language/message_language, list/message_mods = list(), tts_message, list/tts_filter)
	var/found_client = FALSE
	var/rendered = compose_message(src, message_language, message, , spans, message_mods)
	var/list/listeners = get_hearers_in_view(range, source)
	var/list/listened = list()
	for(var/atom/movable/hearing_movable as anything in listeners)
		if(!hearing_movable)//theoretically this should use as anything because it shouldnt be able to get nulls but there are reports that it does.
			stack_trace("somehow theres a null returned from get_hearers_in_view() in send_speech!")
			continue
		if(hearing_movable.Hear(rendered, src, message_language, message, , spans, message_mods))
			listened += hearing_movable
		if(!found_client && length(hearing_movable.client_mobs_in_contents))
			found_client = TRUE

	var/tts_message_to_use = tts_message
	if(!tts_message_to_use)
		tts_message_to_use = message

	var/list/filter = list()
	var/list/special_filter = list()
	var/voice_to_use = voice
	var/use_radio = FALSE
	if(length(voice_filter) > 0)
		filter += voice_filter

	if(length(tts_filter) > 0)
		filter += tts_filter.Join(",")
	if(use_radio)
		special_filter += TTS_FILTER_RADIO

	if(voice && found_client)
		INVOKE_ASYNC(SStts, TYPE_PROC_REF(/datum/controller/subsystem/tts, queue_tts_message), src, html_decode(tts_message_to_use), message_language, voice_to_use, filter.Join(","), listened, message_range = range, pitch = pitch, special_filters = special_filter.Join("|"))

#define CMSG_FREQPART compose_freq(speaker, radio_freq)
#define CMSG_JOBPART compose_job(speaker, message_language, raw_message, radio_freq)
/atom/movable/proc/compose_message(atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode, face_name = FALSE)
	//Basic span
	var/spanpart1 = "<span class='[radio_freq ? get_radio_span(radio_freq) : "game say"]'>"
	//Start name span.
	var/spanpart2 = "<span class='name'>"
	//Speaker name
	var/namepart = "[speaker.GetVoice()][speaker.get_alt_name()]"
	if(face_name && ishuman(speaker))
		var/mob/living/carbon/human/H = speaker
		namepart = "[H.get_face_name()]" //So "fake" speaking like in hallucinations does not give the speaker away if disguised
	//End name span.
	var/endspanpart = "</span>"

	//Message
	var/messagepart = " [span_message("[say_emphasis(lang_treat(speaker, message_language, raw_message, spans, message_mode))]")]</span>"

	var/languageicon = ""
	var/datum/language/D = GLOB.language_datum_instances[message_language]
	if(istype(D) && D.display_icon(src))
		languageicon = "[D.get_icon()] "

	return "[spanpart1][spanpart2][CMSG_FREQPART][languageicon][CMSG_JOBPART][compose_name_href(namepart)][endspanpart][messagepart]"

/**
	Allows us to wrap the name for specific cases like AI tracking or observer tracking

	Arguments
	- name {string} the name of the mob to modify.
*/
/atom/movable/proc/compose_name_href(name)
	return name

/atom/movable/proc/compose_freq(atom/movable/speaker, radio_freq)
	var/job = speaker.GetJob()
	return radio_freq ? "\[[get_radio_name(radio_freq)][job ? " ([job])": ""]\] " : ""


/atom/movable/proc/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	if(ishuman(speaker))
		var/mob/living/carbon/human/H = speaker

		var/paygrade = H.get_paygrade()
		if(paygrade)
			return "[paygrade] "	//Attempt to read off the id before defaulting to job

		var/datum/job/J = H.job
		if(!istype(J))
			return ""

		paygrade = get_paygrades(J.paygrade, TRUE, gender)
		return paygrade ? "[paygrade] " : ""
	else if(istype(speaker, /atom/movable/virtualspeaker))
		var/atom/movable/virtualspeaker/VT = speaker
		if(!ishuman(VT.source))
			return
		var/mob/living/carbon/human/H = VT.source
		var/paygrade = H.get_paygrade()
		if(paygrade)
			return "[paygrade] "	//Attempt to read off the id before defaulting to job

		var/datum/job/J = H.job
		if(!istype(J))
			return ""

		paygrade = get_paygrades(J.paygrade, TRUE, gender)
		return paygrade ? "[paygrade] " : ""
	else
		return ""



/atom/movable/proc/say_mod(input, message_mode, datum/language/language)
	var/ending = copytext_char(input, -1)
	if(copytext_char(input, -2) == "!!")
		return verb_yell
	else if(language)
		var/datum/language/L = GLOB.language_datum_instances[language]
		return L.get_spoken_verb(copytext_char(input, length(input)))
	else if(ending == "?")
		return verb_ask
	else if(ending == "!")
		return verb_exclaim
	else
		return verb_say


/atom/movable/proc/say_quote(input, list/spans = list(speech_span), message_mode, datum/language/language)
	if(!input)
		input = "..."

	if(copytext_char(input, -2) == "!!")
		spans |= SPAN_YELL

	var/spanned = attach_spans(input, spans)
	return "[say_mod(input, message_mode, language)], \"[spanned]\""


#define ENCODE_HTML_EPHASIS(input, char, html, varname) \
	var/static/regex/##varname = regex("[char]{2}(.+?)[char]{2}", "g");\
	input = varname.Replace_char(input, "<[html]>$1</[html]>")

/atom/movable/proc/say_emphasis(input)
	ENCODE_HTML_EPHASIS(input, "\\|", "i", italics)
	ENCODE_HTML_EPHASIS(input, "\\+", "b", bold)
	ENCODE_HTML_EPHASIS(input, "_", "u", underline)
	return input

#undef ENCODE_HTML_EPHASIS


/atom/movable/proc/lang_treat(atom/movable/speaker, datum/language/language, raw_message, list/spans, message_mode, no_quote = FALSE)
	if(has_language(language))
		var/atom/movable/AM = speaker.GetSource()
		if(AM) //Basically means "if the speaker is virtual"
			return no_quote ? raw_message : AM.say_quote(raw_message, spans, message_mode, language)
		else
			return no_quote ? raw_message : speaker.say_quote(raw_message, spans, message_mode, language)
	else if(language)
		var/atom/movable/AM = speaker.GetSource()
		var/datum/language/D = GLOB.language_datum_instances[language]
		raw_message = D.scramble(raw_message)
		if(AM)
			return no_quote ? raw_message : AM.say_quote(raw_message, spans, message_mode, language)
		else
			return no_quote ? raw_message : speaker.say_quote(raw_message, spans, message_mode, language)
	else
		return "makes a strange sound."


/proc/get_radio_span(freq)
	var/returntext = GLOB.freqtospan["[freq]"]
	if(returntext)
		return returntext
	if((freq < FREQ_CUSTOM_SQUAD_MAX) && (freq >= FREQ_CUSTOM_SQUAD_MIN))
		var/squad_color = GLOB.custom_squad_radio_freqs["[freq]"].color
		return GLOB.custom_squad_colors[squad_color]
	return "radio"


/proc/get_radio_name(freq)
	var/returntext = GLOB.reverseradiochannels["[freq]"]
	if(returntext)
		return returntext
	if((freq < FREQ_CUSTOM_SQUAD_MAX) && (freq > FREQ_CUSTOM_SQUAD_MIN))
		for(var/datum/squad/squad in SSjob.active_squads)
			if(freq == squad.radio_freq)
				return squad.name
	return "[copytext_char("[freq]", 1, 4)].[copytext_char("[freq]", 4, 5)]"


/proc/attach_spans(input, list/spans)
	return "[message_spans_start(spans)][input]</span>"


/proc/message_spans_start(list/spans)
	var/output = "<span class='"
	for(var/S in spans)
		output = "[output][S] "
	output = "[output]'>"
	return output


/proc/say_test(text)
	var/ending = copytext_char(text, -1)
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "4"

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
	if(istype(M))
		name = M.GetVoice()
		verb_say = M.verb_say
		verb_ask = M.verb_ask
		verb_exclaim = M.verb_exclaim
		verb_yell = M.verb_yell

	if(isliving(M))
		var/mob/living/living_speaker = M
		if(living_speaker.job)
			job = living_speaker.job.comm_title
		else
			job = ""
	else if(isobj(M))  // Cold, emotionless machines
		job = "Machine"


/atom/movable/virtualspeaker/GetJob()
	return job


/atom/movable/virtualspeaker/GetSource()
	return source


/atom/movable/virtualspeaker/GetRadio()
	return radio
