/mob/living/carbon/human/say(var/message)

	var/verb = "says"
	var/alt_name = ""
	var/message_range = world.view
	var/italics = 0

	if(client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (Muted)."
			return

	message =  trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(stat == 2)
		return say_dead(message)

	var/message_mode = parse_message_mode(message, "headset")

	if(copytext(message,1,2) == "*")
		return emote(copytext(message,2), 1, null, TRUE) //TRUE arg means emote was caused by player (e.g. no an auto scream when hurt).

	if(name != GetVoice())
		alt_name = "(as [get_id_name("Unknown")])"

	//parse the radio code and consume it
	if (message_mode)
		if (message_mode == "headset")
			message = copytext(message,2)	//it would be really nice if the parse procs could do this for us.
		else
			message = copytext(message,3)

	//parse the language code and consume it
	var/datum/language/speaking = parse_language(message)
	if(speaking)
		message = copytext(message,3)
	else if(species.default_language)
		speaking = all_languages[species.default_language]

	var/ending = copytext(message, length(message))
	if (speaking)
		// This is broadcast to all mobs with the language,
		// irrespective of distance or anything else.
		if(speaking.flags & HIVEMIND)
			speaking.broadcast(src,trim(message))
			return
		//If we've gotten this far, keep going!
		verb = speaking.get_spoken_verb(ending)
	else
		if(ending=="!")
			verb=pick("exclaims","shouts","yells")
		if(ending=="?")
			verb="asks"

	if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return

	message = capitalize(trim(message))

	if(speech_problem_flag)
		var/list/handle_r = handle_speech_problems(message)
		message = handle_r[1]
		verb = handle_r[2]
		speech_problem_flag = handle_r[3]

	if(!message || stat)
		return

	var/list/obj/item/used_radios = new

	switch (message_mode)
		if("headset")
			message_mode = null
			if(wear_ear && istype(wear_ear,/obj/item/device/radio))
				var/obj/item/device/radio/R = wear_ear
				used_radios += R
		if("intercom")
			message_mode = null
			for(var/obj/item/device/radio/intercom/I in view(1))
				used_radios += I
		if("whisper")
			whisper_say(message, speaking, alt_name)
			return
		else
			if(message_mode)
				if(wear_ear && istype(wear_ear,/obj/item/device/radio))
					used_radios += wear_ear

	var/sound/speech_sound
	var/sound_vol
	if(species.speech_sounds && prob(species.speech_chance))
		speech_sound = sound(pick(species.speech_sounds))
		sound_vol = 70

	//speaking into radios
	if(used_radios.len)

		if (speech_sound)
			sound_vol *= 0.5

		for(var/mob/living/M in hearers(message_range, src))
			if(M != src)
				M.show_message("<span class='notice'>[src] talks into [used_radios.len ? used_radios[1] : "the radio."]</span>")
		if(has_species(src,"Human"))
			playsound(src.loc, 'sound/effects/radiostatic.ogg', 15, 1)

		italics = 1
		message_range = 2

	..(message, speaking, verb, alt_name, italics, message_range, speech_sound, sound_vol)	//ohgod we should really be passing a datum here.

	for(var/obj/item/device/radio/R in used_radios)
		spawn(0)
			R.talk_into(src,message, message_mode, verb, speaking)

/mob/living/carbon/human/proc/forcesay(var/forcesay_type = SUDDEN)
	if (!client || stat != CONSCIOUS)
		return

	var/say_text = winget(client, "input", "text")
	if (length(say_text) < 8)
		return

	var/regex/say_regex = regex("say \"(;|:)*", "i")
	say_text = say_regex.Replace(say_text, "")

	switch (forcesay_type)
		if (SUDDEN)
			say_text += "-"
		if (GRADUAL)
			say_text += "..."
		if (PAINFUL)
			say_text += pick("-OW!", "-UGH!", "-ACK!")
		if (EXTREMELY_PAINFUL)
			say_text += pick("-AAAGH!", "-AAARGH!", "-AAAHH!")

	say(say_text)
	winset(client, "input", "text=[null]")

/mob/living/carbon/human/say_understands(var/mob/other,var/datum/language/speaking = null)

	if(species.can_understand(other))
		return 1

	//These only pertain to common. Languages are handled by mob/say_understands()
	if (!speaking)
		if (istype(other, /mob/living/silicon))
			return 1
		if (istype(other, /mob/living/brain))
			return 1

	//This is already covered by mob/say_understands()
	//if (istype(other, /mob/living/simple_animal))
	//	if((other.universal_speak && !speaking) || src.universal_speak || src.universal_understand)
	//		return 1
	//	return 0

	return ..()

/mob/living/carbon/human/GetVoice()
	if(istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
		var/obj/item/clothing/mask/gas/voice/V = src.wear_mask
		if(V.vchange)
			return V.voice
		else
			return name
	if(GetSpecialVoice())
		return GetSpecialVoice()
	return real_name

/mob/living/carbon/human/proc/SetSpecialVoice(var/new_voice)
	if(new_voice)
		special_voice = new_voice
	return

/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""
	return

/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice


/*
   ***Deprecated***
   let this be handled at the hear_say or hear_radio proc
   This is left in for robot speaking when humans gain binary channel access until I get around to rewriting
   robot_talk() proc.
   There is no language handling build into it however there is at the /mob level so we accept the call
   for it but just ignore it.
*/

/mob/living/carbon/human/say_quote(var/message, var/datum/language/speaking = null)
	var/verb = "says"
	var/ending = copytext(message, length(message))

	if(speaking)
		verb = speaking.get_spoken_verb(ending)
	else
		if(ending == "!")
			verb=pick("exclaims","shouts","yells")
		else if(ending == "?")
			verb="asks"

	return verb

/mob/living/carbon/human/proc/handle_speech_problems(var/message)
	var/list/returns[3]
	var/verb = "says"
	var/handled = 0
	if(silent)
		message = ""
		handled = 1
	if(sdisabilities & MUTE)
		message = ""
		handled = 1
	if(wear_mask)
		if(istype(wear_mask, /obj/item/clothing/mask/horsehead))
			var/obj/item/clothing/mask/horsehead/hoers = wear_mask
			if(hoers.voicechange)
				message = pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!")
				verb = pick("whinnies","neighs", "says")
				handled = 1

	if((HULK in mutations) && health >= 25 && length(message))
		message = "[uppertext(message)]!!!"
		verb = pick("yells","roars","hollers")
		handled = 1
	if(slurring)
		message = slur(message)
		verb = pick("stammers","stutters")
		handled = 1
	if(stuttering)
		message = NewStutter(message)
		verb = pick("stammers", "stutters")
		handled = 1
	var/braindam = getBrainLoss()
	if(braindam >= 60)
		handled = 1
		if(prob(braindam/4))
			message = stutter(message)
			verb = pick("stammers", "stutters")
		if(prob(braindam))
			message = uppertext(message)
			verb = pick("yells like an idiot","says rather loudly")

	returns[1] = message
	returns[2] = verb
	returns[3] = handled

	return returns
