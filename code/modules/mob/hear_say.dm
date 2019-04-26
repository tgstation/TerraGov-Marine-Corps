/mob/proc/hear_radio(var/message, var/verb="says", var/datum/language/language=null, var/part_a, var/part_b, var/mob/speaker = null, var/hard_to_hear = 0, var/vname ="", var/command = 0)
	if(!client)
		return

	if(sleeping || stat == UNCONSCIOUS) //If unconscious or sleeping
		hear_sleep(message)
		return
	var/comm_paygrade = ""

	var/track = null
	var/link = isobserver(src) ? "[FOLLOW_LINK(src, speaker)] " : ""

	var/style = "body"

	var/sound_to_play
	if(istype(speaker, /mob/living/silicon/decoy/ship_ai)) //For the AI stuff. TODO: Change.
		var/mob/living/silicon/decoy/ship_ai/AI = speaker
		sound_to_play = AI.ai_sound

	if(!language)
		language = GLOB.language_datum_instances[get_default_language()]

	if(!can_speak_in_language(language))
		if(istype(speaker,/mob/living/simple_animal))
			var/mob/living/simple_animal/S = speaker
			message = pick(S.speak)
		else
			message = language.scramble(message)

	if(hard_to_hear)
		message = stars(message)

	var/speaker_name = speaker.name

	if(vname)
		speaker_name = vname

	if(ishuman(speaker))
		var/mob/living/carbon/human/H = speaker
		comm_paygrade = H.get_paygrade()
		if(H.voice)
			speaker_name = H.voice

	if(hard_to_hear)
		speaker_name = "unknown"

	var/changed_voice

	if(isAI(src) && !hard_to_hear)
		var/jobname // the mob's "job"
		var/mob/living/carbon/human/impersonating //The crewmember being impersonated, if any.

		if (ishuman(speaker))
			var/mob/living/carbon/human/H = speaker

			if((H.wear_id && istype(H.wear_id,/obj/item/card/id/syndicate)) && (H.wear_mask && istype(H.wear_mask,/obj/item/clothing/mask/gas/voice)))

				changed_voice = 1
				var/mob/living/carbon/human/I = locate(speaker_name)

				if(I)
					impersonating = I
					jobname = impersonating.get_assignment()
					comm_paygrade = impersonating.get_paygrade()
				else
					jobname = "Unknown"
					comm_paygrade = ""
			else
				jobname = H.get_assignment()
				comm_paygrade = H.get_paygrade()

		else if (iscarbon(speaker)) // Nonhuman carbon mob
			jobname = "No id"
			comm_paygrade = ""
		else if (isAI(speaker))
			jobname = "AI"
			comm_paygrade = ""
		else if (iscyborg(speaker))
			jobname = "Cyborg"
			comm_paygrade = ""
		else
			jobname = "Unknown"
			comm_paygrade = ""

		if(changed_voice)
			if(impersonating)
				track = "[speaker_name] ([jobname])"
			else
				track = "[speaker_name] ([jobname])"
		else
			track = "[speaker_name] ([jobname])"

	if(isobserver(src))
		if(speaker_name != speaker.real_name && !isAI(speaker)) //Announce computer and various stuff that broadcasts doesn't use it's real name but AI's can't pretend to be other mobs.
			speaker_name = "[speaker.real_name] ([speaker_name])"
		track = "[speaker_name]"

	if(sdisabilities & DEAF || ear_deaf)
		if(prob(20))
			to_chat(src, "<span class='warning'>You feel your headset vibrate but can hear nothing from it!</span>")
	else if(track)
		if(!command)
			to_chat(src, "[link][part_a][comm_paygrade][track][part_b][verb], <span class=\"[style]\">\"[message]\"</span></span></span>")
		else
			to_chat(src, "<font size='[command]'>[link][part_a][comm_paygrade][track][part_b][verb], <span class=\"[style]\">\"[message]\"</span></span></span></font>")
		if(sound_to_play) src << sound(sound_to_play, volume = 65)
	else
		if(!command)
			to_chat(src, "[link][part_a][comm_paygrade][speaker_name][part_b][verb], <span class=\"[style]\">\"[message]\"</span></span></span>")
		else
			to_chat(src, "<font size = '[command]'>[link][part_a][comm_paygrade][speaker_name][part_b][verb], <span class=\"[style]\">\"[message]\"</span></span></span></font>")
		if(sound_to_play) src << sound(sound_to_play, volume = 65)


/mob/proc/hear_sleep(message)
	var/heard = ""
	if(prob(15))
		var/list/punctuation = list(",", "!", ".", ";", "?")
		var/list/messages = text2list(message, " ")
		var/R = rand(1, messages.len)
		var/heardword = messages[R]
		if(copytext(heardword,1, 1) in punctuation)
			heardword = copytext(heardword,2)
		if(copytext(heardword,-1) in punctuation)
			heardword = copytext(heardword,1,lentext(heardword))
		heard = "<span class = 'game_say'>...You hear something about...[heardword]</span>"

	else
		heard = "<span class = 'game_say'>...<i>You almost hear someone talking</i>...</span>"

	to_chat(src, heard)
