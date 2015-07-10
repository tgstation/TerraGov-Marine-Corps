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
			if(L.key == "x")
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
	else
		hivemind_talk(message)

/mob/living/carbon/Xenomorph/say_understands(var/mob/other,var/datum/language/speaking = null)

	if(istype(other,/mob/living/carbon/Xenomorph))
		return 1
	return ..()


//General proc for hivemind. Lame, but effective.
/mob/living/carbon/Xenomorph/proc/hivemind_talk(var/message)
	if (!message)
		return

	var/rendered
	if(istype(src, /mob/living/carbon/Xenomorph/Queen))
		rendered = "<font size='3' font color='purple'><i><span class='game say'>Hivemind, <span class='name'>[name]</span> <span class='message'> hisses, '[message]'</span></span></i></font>"
	else
		rendered = "<i><span class='game say'>Hivemind, <span class='name'>[name]</span> <span class='message'> hisses, '[message]'</span></span></i>"

	for (var/mob/S in player_list)
		if((istype(S,/mob/living/carbon/Xenomorph) || S.stat == DEAD) && !istype(S,/mob/new_player))
			S.show_message(rendered, 2)

	var/list/listening = hearers(1, src)
	var/list/heard = list()

	for (var/mob/M in listening)
		if(!istype(M, /mob/living/carbon/Xenomorph))
			heard += M

	if (length(heard))
		var/message_b

		message_b = "hsssss"
		message_b = say_quote(message_b)
		message_b = "<i>[message_b]</i>"

		rendered = "<i><span class='game say'><span class='name'>[voice_name]</span> <span class='message'>[message_b]</span></span></i>"

		for (var/mob/M in heard)
			M.show_message(rendered, 2)
