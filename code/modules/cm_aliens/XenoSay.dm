/mob/living/carbon/Xenomorph/say(var/message)
	var/verb = "says"
	var/forced = 0
	var/message_range = world.view

	if(client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (Muted)."
			return

	message =  trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(stat == 2)
		return say_dead(message)

	if(copytext(message,1,2) == "*")
		return emote(copytext(message,2))

	var/datum/language/speaking = null

	if(length(message) >= 2)
		var/channel_prefix = copytext(message, 1 ,3)
		if(languages.len)
			for(var/datum/language/L in languages)
				if(lowertext(channel_prefix) == ":[L.key]")
					verb = L.speech_verb
					speaking = L
					break

	if(isnull(speaking) || speaking.key != "a") //Not hivemind? Then default to xenocommon. BRUTE FORCE YO
		for(var/datum/language/L in languages)
			if(L.key == "4")
				verb = L.speech_verb
				speaking = L
				forced = 1
				break

	if(speaking && !forced)
		message = trim(copytext(message,3))

	message = capitalize(trim_left(message))

	if(!message || stat)
		return

	if(forced)

		playsound(loc, "hiss", 25, 1, 1)

	..(message, speaking, verb, null, null, message_range, null)

/mob/living/carbon/Xenomorph/say_understands(var/mob/other,var/datum/language/speaking = null)

	if(istype(other,/mob/living/carbon/Xenomorph) && !speaking)
		return 1
	return ..()