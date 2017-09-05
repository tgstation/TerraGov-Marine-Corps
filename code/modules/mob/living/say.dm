var/list/department_radio_keys = list(
	  ":i" = "intercom",	"#i" = "intercom",		".i" = "intercom",
	  ":h" = "department",	"#h" = "department",	".h" = "department",
	  ":+" = "special",		"#+" = "special",		".+" = "special", //activate radio-specific special functions
	  ":w" = "whisper",		"#w" = "whisper",		".w" = "whisper",
	  ":t" = "Syndicate",	"#t" = "Syndicate",		".t" = "Syndicate",

	  ":m" = "MedSci",		"#m" = "MedSci",		".m" = "MedSci",
	  ":e" = "Engi", 		"#e" = "Engi",			".e" = "Engi",
	  ":z" = "Almayer",		"#z" = "Almayer",		".z" = "Almayer",
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
	  ":Z" = "Almayer",		"#Z" = "Almayer",		".Z" = "Almayer",
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
		var/obj/item/device/radio/headset/dongle
		if(istype(H.wear_ear,/obj/item/device/radio/headset))
			dongle = H.wear_ear
		if(!istype(dongle)) return
		if(dongle.translate_binary) return 1

/mob/living/say(var/message, var/datum/language/speaking = null, var/verb="says", var/alt_name="", var/italics=0, var/message_range = world.view, var/sound/speech_sound, var/sound_vol)

	var/turf/T = get_turf(src)

	//handle nonverbal and sign languages here
	if (speaking)
		if (speaking.flags & NONVERBAL)
			if (prob(30))
				src.custom_emote(1, "[pick(speaking.signlang_verb)].")

		if (speaking.flags & SIGNLANG)
			say_signlang(message, pick(speaking.signlang_verb), speaking)
			return 1

	var/list/listening = list()
	var/list/listening_obj = list()

	if(T)
		//make sure the air can transmit speech - speaker's side
		/*
		var/datum/gas_mixture/environment = T.return_air()
		if(environment)
			var/pressure = (environment)? environment.return_pressure() : 0
			if(pressure < SOUND_MINIMUM_PRESSURE)
				message_range = 1

			if (pressure < ONE_ATMOSPHERE*0.4) //sound distortion pressure, to help clue people in that the air is thin, even if it isn't a vacuum yet
				italics = 1
				sound_vol *= 0.5 //muffle the sound a bit, so it's like we're actually talking through contact
		*/
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


		for(var/mob/M in player_list)
			if(M.stat == DEAD && M.client && M.client.prefs && (M.client.prefs.toggles_chat & CHAT_GHOSTEARS))
				listening |= M
				continue
			if(M.loc && M.locs[1] in hearturfs)
				listening |= M

	var/speech_bubble_test = say_test(message)
	var/image/speech_bubble = image('icons/mob/talk.dmi',src,"h[speech_bubble_test]")

	var/not_dead_speaker = (stat != DEAD)
	for(var/mob/M in listening)
		if(not_dead_speaker)
			M << speech_bubble
		M.hear_say(message, verb, speaking, alt_name, italics, src, speech_sound, sound_vol)

	spawn(30)
		if(client) client.images -= speech_bubble
		if(not_dead_speaker)
			for(var/mob/M in listening)
				if(M.client) M.client.images -= speech_bubble
		cdel(speech_bubble)


	for(var/obj/O in listening_obj)
		spawn(0)
			if(O) //It's possible that it could be deleted in the meantime.
				O.hear_talk(src, message, verb, speaking, italics)

	log_say("[name]/[key] : [message]")
	return 1

/mob/living/proc/say_signlang(var/message, var/verb="gestures", var/datum/language/language)
	for (var/mob/O in viewers(src, null))
		O.hear_signlang(message, verb, language, src)

/obj/effect/speech_bubble
	var/mob/parent

/mob/living/proc/GetVoice()
	return name
