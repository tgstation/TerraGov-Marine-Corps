/mob/living/carbon/human/say_mod(input, message_mode, datum/language/language)
	if(slurring)
		return "slurs"
	if(HAS_TRAIT(src, TRAIT_DROOLING))
		return "drools"
	else
		. = ..()


/mob/living/carbon/human/GetVoice()
	if(GetSpecialVoice())
		return GetSpecialVoice()
	return real_name


/mob/living/carbon/human/proc/SetSpecialVoice(new_voice)
	if(new_voice)
		special_voice = new_voice


/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""


/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice


/mob/living/carbon/human/binarycheck()
	if(wear_ear)
		var/obj/item/radio/headset/H = wear_ear
		if(!istype(H))
			return FALSE


/mob/living/carbon/human/radio(message, message_mode, list/spans, language)
	. = ..()
	if(. != 0)
		return

	if(isxeno(loc))
		message = Gibberish(message, 100)

	switch(message_mode)
		if(MODE_HEADSET)
			if(wear_ear)
				playsound(loc, 'sound/effects/radiostatic.ogg', 15, 1)
				wear_ear.talk_into(src, message, , spans, language)
			return ITALICS | REDUCE_RANGE

		if(MODE_DEPARTMENT)
			if(wear_ear)
				playsound(loc, 'sound/effects/radiostatic.ogg', 15, 1)
				wear_ear.talk_into(src, message, message_mode, spans, language)
			return ITALICS | REDUCE_RANGE

	if(message_mode in GLOB.radiochannels)
		if(wear_ear)
			playsound(loc, 'sound/effects/radiostatic.ogg', 15, 1)
			wear_ear.talk_into(src, message, message_mode, spans, language)
			return ITALICS | REDUCE_RANGE

	return 0


/mob/living/carbon/human/get_alt_name()
	if(name != GetVoice())
		return " (as [get_id_name("Unknown")])"
