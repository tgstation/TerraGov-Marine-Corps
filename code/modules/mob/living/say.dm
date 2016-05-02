var/list/department_radio_keys = list(
	  ":r" = "right ear",	"#r" = "right ear",		".r" = "right ear",
	  ":l" = "left ear",	"#l" = "left ear",		".l" = "left ear",
	  ":i" = "intercom",	"#i" = "intercom",		".i" = "intercom",
	  ":h" = "department",	"#h" = "department",	".h" = "department",
	  ":+" = "special",		"#+" = "special",		".+" = "special", //activate radio-specific special functions
	  ":w" = "whisper",		"#w" = "whisper",		".w" = "whisper",
	  ":t" = "Syndicate",	"#t" = "Syndicate",		".t" = "Syndicate",

	  ":m" = "MedSci",		"#m" = "MedSci",		".m" = "MedSci",
	  ":e" = "Engi", 		"#e" = "Engi",			".e" = "Engi",
	  ":z" = "Sulaco",		"#z" = "Sulaco",		".z" = "Sulaco",
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
	  ":Z" = "Sulaco",		"#Z" = "Sulaco",		".Z" = "Sulaco",
	  ":V" = "Command",		"#V" = "Command",		".V" = "Command",
	  ":Q" = "Alpha",		"#Q" = "Alpha",			".Q" = "Alpha",
	  ":B" = "Bravo",		"#B" = "Bravo",			".B" = "Bravo",
	  ":C" = "Charlie",		"#C" = "Charlie",		".C" = "Charlie",
	  ":D" = "Delta",		"#D" = "Delta",			".D" = "Delta",
	  ":P" = "MP",			"#P" = "MP",			".P" = "MP",
	  ":U" = "Req",			"#U" = "Req",			".U" = "Req",

	  //kinda localization -- rastaf0
	  //same keys as above, but on russian keyboard layout. This file uses cp1251 as encoding.
	  ":ê" = "right ear",	"#ê" = "right ear",		".ê" = "right ear",
	  ":ä" = "left ear",	"#ä" = "left ear",		".ä" = "left ear",
	  ":ø" = "intercom",	"#ø" = "intercom",		".ø" = "intercom",
	  ":ð" = "department",	"#ð" = "department",	".ð" = "department",
	  ":ñ" = "Command",		"#ñ" = "Command",		".ñ" = "Command",
	  ":ü" = "Medical",		"#ü" = "Medical",		".ü" = "Medical",
	  ":ó" = "Engineering",	"#ó" = "Engineering",	".ó" = "Engineering",
	  ":ö" = "whisper",		"#ö" = "whisper",		".ö" = "whisper",
	  ":å" = "Syndicate",	"#å" = "Syndicate",		".å" = "Syndicate",
)

/mob/living/proc/binarycheck()

	if (istype(src, /mob/living/silicon/pai))
		return

	if (!ishuman(src))
		return

	var/mob/living/carbon/human/H = src
	if (H.l_ear || H.r_ear)
		var/obj/item/device/radio/headset/dongle
		if(istype(H.l_ear,/obj/item/device/radio/headset))
			dongle = H.l_ear
		else
			dongle = H.r_ear
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
				if (isslime(I))
					var/mob/living/carbon/slime/S = I
					if (src in S.Friends)
						S.speech_buffer = list()
						S.speech_buffer.Add(src)
						S.speech_buffer.Add(lowertext(html_decode(message)))
			else if(istype(I, /obj/))
				var/obj/O = I
				hearturfs += O.locs[1]
				listening_obj |= O


		for(var/mob/M in player_list)
			if(M.stat == DEAD && M.client && M.client.prefs && (M.client.prefs.toggles & CHAT_GHOSTEARS))
				listening |= M
				continue
			if(M.loc && M.locs[1] in hearturfs)
				listening |= M

	var/speech_bubble_test = say_test(message)
	var/image/speech_bubble = image('icons/mob/talk.dmi',src,"h[speech_bubble_test]")
	spawn(30) del(speech_bubble)

	for(var/mob/M in listening)
		if(!M.stat)
			M << speech_bubble
		M.hear_say(message, verb, speaking, alt_name, italics, src, speech_sound, sound_vol)

	var/fail = 10
	for(var/obj/O in listening_obj)
		fail--
		if(!fail) break //NOPE
		spawn(0)
			if(O) //It's possible that it could be deleted in the meantime.
				O.hear_talk(src, message, verb, speaking)

	log_say("[name]/[key] : [message]")
	return 1

/mob/living/proc/say_signlang(var/message, var/verb="gestures", var/datum/language/language)
	for (var/mob/O in viewers(src, null))
		O.hear_signlang(message, verb, language, src)

/obj/effect/speech_bubble
	var/mob/parent

/mob/living/proc/GetVoice()
	return name
