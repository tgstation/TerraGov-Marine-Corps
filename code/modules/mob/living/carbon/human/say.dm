/mob/living/carbon/human/say_mod(input, message_mode)
	if(slurring)
		return "slurs"
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
		if(H.translate_binary)
			return TRUE


/mob/living/carbon/human/radio(message, message_mode, list/spans, language)
	. = ..()
	if(. != 0)
		return .

	switch(message_mode)
		if(MODE_HEADSET)
			if(wear_ear)
				wear_ear.talk_into(src, message, , spans, language)
			return ITALICS | REDUCE_RANGE

		if(MODE_DEPARTMENT)
			if(wear_ear)
				wear_ear.talk_into(src, message, message_mode, spans, language)
			return ITALICS | REDUCE_RANGE

	if(message_mode in radiochannels)
		if(wear_ear)
			wear_ear.talk_into(src, message, message_mode, spans, language)
			return ITALICS | REDUCE_RANGE

	return 0


/mob/living/carbon/human/get_alt_name()
	if(name != GetVoice())
		return " (as [get_id_name("Unknown")])"


/mob/living/carbon/human/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	var/datum/job/J = SSjob.GetJob(mind ? mind.assigned_role : job)
	if(!istype(J))
		return

	return "[get_paygrades(J.paygrade, TRUE, gender)] "