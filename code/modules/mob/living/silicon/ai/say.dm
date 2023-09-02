/mob/living/silicon/ai/compose_freq(atom/movable/speaker, radio_freq)
	var/job = speaker.GetJob()
	var/namepart = "[speaker.GetVoice()][speaker.get_alt_name()]"

	return radio_freq ? "\[[get_radio_name(radio_freq)][job ? " <a href='?src=[REF(src)];track=[html_encode(namepart)]'>([job])</a>": ""]\] " : ""

/mob/living/silicon/ai/radio(message, message_mode, list/spans, language)
	if(incapacitated())
		return FALSE
	if(control_disabled)
		to_chat(src, span_danger("Your radio transmitter is offline!"))
		return FALSE
	return ..()


/// Handles relayed speech
/mob/living/silicon/ai/proc/holopad_talk(message, language)
	message = trim(message)
	if(!message)
		return

	var/obj/machinery/holopad/T = current
	if(!istype(T) || !T.masters[src])
		to_chat(src, span_warning("No holopad connected."))
		return

	var/turf/padturf = get_turf(T)
	var/padloc
	if(padturf)
		padloc = AREACOORD(padturf)
	else
		padloc = "(UNKNOWN)"
	log_talk(message, LOG_SAY, tag = "HOLOPAD in [padloc]")
	send_speech(message, 7, T, "robot", message_language = language)
	to_chat(src, span_notice("Holopad transmitted: [real_name]: \"[message]\""))


/mob/living/silicon/ai/get_message_mode(message)
	var/static/regex/holopad_finder = regex(@"[:.#][hH]")
	if(holopad_finder.Find(message, 1, 1))
		return MODE_RELAYED
	return ..()

///Make sure that the code compiles with AI_VOX undefined
#ifdef AI_VOX
///cooldown between vox announcements, divide by 10 to get the time in seconds
#define VOX_DELAY 400
/mob/living/silicon/ai/proc/announcement_help() //displays a list of available vox words for the user to make sentences with, players can click the words to hear a preview of how they sound

	if(incapacitated())
		return

	var/dat = {"
	<font class='bad'>WARNING:</font> Misuse of the announcement system will get you job banned.<BR><BR>
	Here is a list of words you can type into the 'Announcement' button to create sentences to vocally announce to everyone on the same level at you.<BR>
	<UL><LI>You can also click on the word to PREVIEW it.</LI>
	<LI>You can only say 30 words for every announcement.</LI>
	<LI>Do not use punctuation as you would normally, if you want a pause you can use the full stop and comma characters by separating them with spaces, like so: 'Alpha . Test , Bravo'.</LI>
	<LI>Numbers are in word format, e.g. eight, sixty, etc </LI>
	<LI>Sound effects begin with an 's' before the actual word, e.g. scensor</LI>
	<LI>Use Ctrl+F to see if a word exists in the list.</LI></UL><HR>
	"}

	var/index = 0
	for(var/word in GLOB.vox_sounds) //populate our list of available words for the user to see
		index++
		dat += "<A href='?src=[REF(src)];say_word=[word]'>[capitalize(word)]</A>"
		if(index != length(GLOB.vox_sounds))
			dat += " / "

	var/datum/browser/popup = new(src, "announce_help", "Announcement Help", 500, 400)
	popup.set_content(dat)
	popup.open()


///gets vox "sentence" from player input
/mob/living/silicon/ai/proc/announcement()
	var/static/announcing_vox = 0 // Stores the time of the last announcement
	if(announcing_vox > world.time)
		to_chat(src, span_notice("Please wait [DisplayTimeText(announcing_vox - world.time)]."))
		return

	var/message = tgui_input_text(src, "WARNING: Misuse of this verb can result in you being job banned. More help is available in 'Announcement Help'", "Announcement")

	if(!message || announcing_vox > world.time)
		return

	if(incapacitated())
		return

	if(control_disabled)
		to_chat(src, span_warning("Wireless interface disabled, unable to interact with announcement PA."))
		return

	var/list/words = splittext(trim(message), " ")
	var/list/incorrect_words = list() //needed so we can show the user what words we don't have

	if(length(words) > 30)
		words.len = 30

	for(var/word in words)
		word = lowertext(trim(word))
		if(!word)
			words -= word
			continue
		if(!GLOB.vox_sounds[word])
			incorrect_words += word

	if(length(incorrect_words))
		to_chat(src, span_notice("These words are not available on the announcement system: [english_list(incorrect_words)]."))
		return

	announcing_vox = world.time + VOX_DELAY

	log_game("[key_name(src)] made a vocal announcement with the following message: [message].")
	log_talk(message, LOG_SAY, tag="VOX Announcement")
	to_chat(src, span_notice("The following vocal announcement has been made: [message]."))

	for(var/word in words) //play vox sounds to the rest of our zlevel
		play_vox_word(word, src.z, null)

///play vox words for mobs on our zlevel
/proc/play_vox_word(word, z_level, mob/only_listener)

	word = lowertext(word)

	if(GLOB.vox_sounds[word])

		var/sound_file = GLOB.vox_sounds[word]
		var/sound/voice = sound(sound_file, wait = 1, channel = CHANNEL_VOX)
		voice.status = SOUND_STREAM

	///If there is no single listener, broadcast to everyone in the same z level
		if(!only_listener)
			///Play voice for all mobs in the z level
			var/list/receivers = (GLOB.alive_human_list + GLOB.ai_list + GLOB.observer_list)
			for(var/mob/M in receivers)
				if(!isdeaf(M))
					SEND_SOUND(M, voice)
		else
			SEND_SOUND(only_listener, voice)
		return TRUE
	return FALSE

#undef VOX_DELAY
#endif
