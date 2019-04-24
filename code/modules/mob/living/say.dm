var/list/department_radio_keys = list(
	  ":i" = "intercom",	"#i" = "intercom",		".i" = "intercom",
	  ":h" = "department",	"#h" = "department",	".h" = "department",
	  ":+" = "special",		"#+" = "special",		".+" = "special", //activate radio-specific special functions
	  ":w" = "whisper",		"#w" = "whisper",		".w" = "whisper",
	  ":t" = "Syndicate",	"#t" = "Syndicate",		".t" = "Syndicate",

	  ":m" = "MedSci",		"#m" = "MedSci",		".m" = "MedSci",
	  ":e" = "Engi", 		"#e" = "Engi",			".e" = "Engi",
	  ":z" = "Theseus",		"#z" = "Theseus",		".z" = "Theseus",
	  ":v" = "Command",		"#v" = "Command",		".v" = "Command",
	  ":q" = "Alpha",		"#q" = "Alpha",			".q" = "Alpha",
	  ":b" = "Bravo",		"#b" = "Bravo",			".b" = "Bravo",
	  ":c" = "Charlie",		"#c" = "Charlie",		".c" = "Charlie",
	  ":d" = "Delta",		"#d" = "Delta",			".d" = "Delta",
	  ":p" = "MP",			"#p" = "MP",			".p" = "MP",
	  ":u" = "Req",			"#u" = "Req",			".u" = "Req",

	  ":R" = "right ear",	"#R" = "right ear",		".R" = "right ear",
	  ":L" = "left ear",	"#L" = "left ear",		".L" = "left ear",
	  ":I" = "intercom",	"#I" = "intercom",		".I" = "intercom",
	  ":H" = "department",	"#H" = "department",	".H" = "department",
	  ":W" = "whisper",		"#W" = "whisper",		".W" = "whisper",
	  ":T" = "Syndicate",	"#T" = "Syndicate",		".T" = "Syndicate",

	  ":M" = "MedSci",		"#M" = "MedSci",		".M" = "MedSci",
	  ":E" = "Engi", 		"#E" = "Engi",			".E" = "Engi",
	  ":Z" = "Theseus",		"#Z" = "Theseus",		".Z" = "Theseus",
	  ":V" = "Command",		"#V" = "Command",		".V" = "Command",
	  ":Q" = "Alpha",		"#Q" = "Alpha",			".Q" = "Alpha",
	  ":B" = "Bravo",		"#B" = "Bravo",			".B" = "Bravo",
	  ":C" = "Charlie",		"#C" = "Charlie",		".C" = "Charlie",
	  ":D" = "Delta",		"#D" = "Delta",			".D" = "Delta",
	  ":P" = "MP",			"#P" = "MP",			".P" = "MP",
	  ":U" = "Req",			"#U" = "Req",			".U" = "Req",

	  //kinda localization -- rastaf0
	  //same keys as above, but on russian keyboard layout. This file uses cp1251 as encoding.
	  ":�" = "right ear",	"#�" = "right ear",		".�" = "right ear",
	  ":�" = "left ear",	"#�" = "left ear",		".�" = "left ear",
	  ":�" = "intercom",	"#�" = "intercom",		".�" = "intercom",
	  ":�" = "department",	"#�" = "department",	".�" = "department",
	  ":�" = "Command",		"#�" = "Command",		".�" = "Command",
	  ":�" = "Medical",		"#�" = "Medical",		".�" = "Medical",
	  ":�" = "Engineering",	"#�" = "Engineering",	".�" = "Engineering",
	  ":�" = "whisper",		"#�" = "whisper",		".�" = "whisper",
	  ":�" = "Syndicate",	"#�" = "Syndicate",		".�" = "Syndicate",
)

/mob/living/proc/binarycheck()
	if (!ishuman(src))
		return

	var/mob/living/carbon/human/H = src
	if (H.wear_ear)
		var/obj/item/radio/headset/dongle
		if(istype(H.wear_ear,/obj/item/radio/headset))
			dongle = H.wear_ear
		if(!istype(dongle)) return
		if(dongle.translate_binary) return 1


/mob/living/say(message, datum/language/language, verb = "says", alt_name="", var/italics=0, var/message_range = world.view, var/sound/speech_sound, var/sound_vol)
	if(!message)
		return

	if(client?.prefs.muted & MUTE_IC)
		to_chat(src, "<span class='warning'>You cannot speak in IC (Muted).</span>")
		return	

	if(stat == DEAD)
		say_dead(message)
		return

	var/turf/T = get_turf(src)


	var/list/listening = list()
	var/list/listening_obj = list()

	if(T)
		var/list/hear = hear(message_range, T)
		var/list/hearturfs = list()

		for(var/I in hear)
			if(istype(I, /mob/))
				var/mob/M = I
				listening += M
				hearturfs += M.locs[1]
				for(var/obj/O in M.contents)
					listening_obj |= O
			else if(istype(I, /obj/))
				var/obj/O = I
				hearturfs += O.locs[1]
				listening_obj |= O


		for(var/mob/M in GLOB.player_list)
			if(M.stat == DEAD && M.client && M.client.prefs && (M.client.prefs.toggles_chat & CHAT_GHOSTEARS))
				listening |= M
				continue
			if(M.loc && M.locs[1] in hearturfs)
				listening |= M

	var/speech_bubble_test = say_test(message)
	var/image/speech_bubble = image('icons/mob/talk.dmi', src, "h[speech_bubble_test]")

	// language comma detection.
	var/datum/language/message_language = get_message_language(message)
	if(message_language)
		// No, you cannot speak in xenocommon just because you know the key
		if(can_speak_in_language(message_language))
			language =  GLOB.language_datum_instances[message_language]
		message = copytext(message, 3)

		// Trim the space if they said ",0 I LOVE LANGUAGES"
		if(findtext(message, " ", 1, 2))
			message = copytext(message, 2)

	var/message_mode = parse_message_mode(message, "headset")
	//parse the radio code and consume it
	if(message_mode)
		if(message_mode == "headset")
			message = copytext(message, 2)	//it would be really nice if the parse procs could do this for us.
		else
			message = copytext(message, 3)
	else
		log_talk(message, LOG_SAY)

	if(!language)
		language = GLOB.language_datum_instances[get_default_language()]

	verb = language.get_spoken_verb(copytext(message, length(message)))

	var/not_dead_speaker = (stat != DEAD)
	for(var/mob/M in listening)
		if(not_dead_speaker)
			SEND_IMAGE(M, speech_bubble)
		M.hear_say(message, verb, language, alt_name, italics, src, speech_sound, sound_vol)

	addtimer(CALLBACK(src, .proc/remove_speech_bubble, client, speech_bubble, (not_dead_speaker ? listening : null)), 30)

	for(var/obj/O in listening_obj)
		spawn(0)
			if(O) //It's possible that it could be deleted in the meantime.
				O.hear_talk(src, message, verb, language, italics)

	return language


/mob/living/proc/remove_speech_bubble(client/C, image/speech_bubble, list/listening)
	if(C)
		C.images -= speech_bubble
	if(listening)
		for(var/mob/M in listening)
			if(M.client)
				M.client.images -= speech_bubble
	qdel(speech_bubble)


/mob/living/proc/say_signlang(var/message, var/verb="gestures", var/datum/language/language)
	for (var/mob/O in viewers(src, null))
		O.hear_signlang(message, verb, language, src)

/obj/effect/speech_bubble
	var/mob/parent

/mob/living/proc/GetVoice()
	return name


/mob/living/proc/get_message_language(message)
	if(copytext(message, 1, 2) == ",")
		var/key = copytext(message, 2, 3)
		for(var/ld in GLOB.all_languages)
			var/datum/language/LD = ld
			if(initial(LD.key) == key)
				return LD
	return null