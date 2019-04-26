/mob/living/carbon/human/verb/whisper(message as text)
	set name = "Whisper"
	set category = "IC"

	var/alt_name

	log_talk(message, LOG_WHISPER)

	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot whisper (muted).</span>")
			return

		if(client.handle_spam_prevention(message, MUTE_IC))
			return

	if(stat == DEAD)
		return say_dead(message)

	else if(stat)
		return

	message =  trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))	//made consistent with say

	if(name != GetVoice())
		alt_name = "(as [get_id_name("Unknown")])"

	whisper_say(message, alt_name)


//This is used by both the whisper verb and human/say() to handle whispering
/mob/living/carbon/human/proc/whisper_say(message, datum/language/language, alt_name = "", verb = "whispers")
	var/message_range = 1
	var/eavesdropping_range = 2
	var/watching_range = 5
	var/italics = 1

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

	if(!language)
		language = GLOB.language_datum_instances[get_default_language()]

	verb = language.get_spoken_verb(src) + pick(" quietly", " softly")

	message = capitalize(trim(message))

	//TODO: handle_speech_problems for silent
	if (!message || silent)
		return

	// Mute disability
	//TODO: handle_speech_problems
	if (src.sdisabilities & MUTE)
		return

	//TODO: handle_speech_problems
	if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
		return

	//looks like this only appears in whisper. Should it be elsewhere as well? Maybe handle_speech_problems?
	if(istype(src.wear_mask, /obj/item/clothing/mask/gas/voice/space_ninja)&&src.wear_mask:voice=="Unknown")
		if(copytext(message, 1, 2) != "*")
			var/list/temp_message = text2list(message, " ")
			var/list/pick_list = list()
			for(var/i = 1, i <= temp_message.len, i++)
				pick_list += i
			for(var/i=1, i <= abs(temp_message.len/3), i++)
				var/H = pick(pick_list)
				if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":")) continue
				temp_message[H] = ninjaspeak(temp_message[H])
				pick_list -= H
			message = list2text(temp_message, " ")
			message = oldreplacetext(message, "o", "�")
			message = oldreplacetext(message, "p", "�")
			message = oldreplacetext(message, "l", "�")
			message = oldreplacetext(message, "s", "�")
			message = oldreplacetext(message, "u", "�")
			message = oldreplacetext(message, "b", "�")

	//TODO: handle_speech_problems
	if (src.stuttering)
		message = stutter(message)

	var/list/listening = hearers(message_range, src)
	listening |= src

	//ghosts
	for (var/mob/M in GLOB.dead_mob_list)	//does this include players who joined as observers as well?
		if (!(M.client))
			continue
		if(M.stat == DEAD && M.client && (M.client.prefs.toggles_chat & CHAT_GHOSTEARS))
			listening |= M

	//Pass whispers on to anything inside the immediate listeners.
	for(var/mob/L in listening)
		for(var/mob/C in L.contents)
			if(istype(C,/mob/living))
				listening += C

	//pass on the message to objects that can hear us.
	for (var/obj/O in view(message_range, src))
		spawn (0)
			if (O)
				O.hear_talk(src, message)	//O.hear_talk(src, message, verb, speaking)

	var/list/eavesdropping = hearers(eavesdropping_range, src)
	eavesdropping -= src
	eavesdropping -= listening

	var/list/watching  = hearers(watching_range, src)
	watching  -= src
	watching  -= listening
	watching  -= eavesdropping

	//now mobs
	var/speech_bubble_test = say_test(message)
	var/image/speech_bubble = image('icons/mob/talk.dmi',src,"h[speech_bubble_test]")

	var/not_dead_speaker = (stat != DEAD)
	for(var/mob/M in listening)
		if(not_dead_speaker)
			SEND_IMAGE(M, speech_bubble)
		M.hear_say(message, verb, language, alt_name, italics, src)

	if (eavesdropping.len)
		var/new_message = stars(message)	//hopefully passing the message twice through stars() won't hurt... I guess if you already don't understand the language, when they speak it too quietly to hear normally you would be able to catch even less.
		for(var/mob/M in eavesdropping)
			if(not_dead_speaker)
				SEND_IMAGE(M, speech_bubble)
			M.hear_say(new_message, verb, language, alt_name, italics, src)

	addtimer(CALLBACK(src, .proc/remove_speech_bubble, client, speech_bubble, (not_dead_speaker?listening : null)), 30)

	if (watching.len)
		var/rendered = "<span class='game say'><span class='name'>[src.name]</span> whispers something.</span>"
		for (var/mob/M in watching)
			M.show_message(rendered, 2)
