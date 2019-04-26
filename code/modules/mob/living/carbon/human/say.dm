/mob/living/carbon/human/say(message, datum/language/language, verb = "says", alt_name = "", italics = FALSE, message_range = world.view, sound/speech_sound, sound_vol)
	if(copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2), EMOTE_AUDIBLE, null, TRUE)

	. = ..()
	
	if(!.)
		return

	language = .

	var/datum/language/message_language = get_message_language(message)
	if(message_language)
		message = copytext(message, 3)

		if(findtext(message, " ", 1, 2))
			message = copytext(message, 2)

	var/message_mode = parse_message_mode(message, "headset")
	//parse the radio code and consume it
	if(message_mode)
		if(message_mode == "headset")
			message = copytext(message, 2)	//it would be really nice if the parse procs could do this for us.
		else
			message = copytext(message, 3)

	message = capitalize(trim(message))

	var/list/obj/item/used_radios = new

	switch(message_mode)
		if("headset")
			message_mode = null
			if(wear_ear && istype(wear_ear, /obj/item/radio))
				var/obj/item/radio/R = wear_ear
				used_radios += R
		if("intercom")
			message_mode = null
			for(var/obj/item/radio/intercom/I in view(1))
				used_radios += I
		if("whisper")
			whisper_say(message, language, alt_name)
			return
		else
			if(message_mode)
				if(wear_ear && istype(wear_ear, /obj/item/radio))
					used_radios += wear_ear

	//speaking into radios
	if(length(used_radios))
		if(speech_sound)
			sound_vol *= 0.5

		for(var/mob/living/M in hearers(message_range, src))
			if(M != src)
				M.show_message("<span class='notice'>[src] talks into [length(used_radios) ? used_radios[1] : "the radio."]</span>")
		if(species?.count_human)
			playsound(loc, 'sound/effects/radiostatic.ogg', 15, 1)

		italics = TRUE
		message_range = 2

		log_talk("([message_mode]):[message]", LOG_TELECOMMS)

	for(var/obj/item/radio/R in used_radios)
		spawn(0)
			R.talk_into(src, message, message_mode, verb, language)


/mob/living/carbon/human/GetVoice()
	if(istype(wear_mask, /obj/item/clothing/mask/gas/voice))
		var/obj/item/clothing/mask/gas/voice/V = wear_mask
		if(V.vchange)
			return V.voice
		else
			return name
	if(GetSpecialVoice())
		return GetSpecialVoice()
	return real_name


/mob/living/carbon/human/proc/SetSpecialVoice(new_voice)
	if(!new_voice)
		return
	special_voice = new_voice


/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""


/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice