/mob/living/carbon/Xenomorph/say(var/message)
	var/verb = "says"
	var/hivemind = FALSE
	var/message_range = world.view
	var/datum/language/language

	if(client?.prefs.muted & MUTE_IC)
		to_chat(src, "<span class='warning'>You cannot speak in IC (Muted).</span>")
		return

	message =  trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(stat == DEAD)
		return say_dead(message)

	if(stat == UNCONSCIOUS)
		return //Unconscious? Nope.

	if(copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2), EMOTE_AUDIBLE, null, TRUE)

	var/datum/language/message_language = get_message_language(message)
	if(message_language)
		// No, you cannot speak in xenocommon just because you know the key
		if(can_speak_in_language(message_language))
			language = message_language
		if(copytext(message, 1, 2) == ";")
			message = copytext(message, 2)
		else
			message = copytext(message, 3)

		// Trim the space if they said ",0 I LOVE LANGUAGES"
		if(findtext(message, " ", 1, 2))
			message = copytext(message, 2)


	if(is_type_in_typecache(language, list(/datum/language/xenohivemind = TRUE)))
		hivemind = TRUE

	message = capitalize(trim_left(message))

	if(!message || stat)
		return

	if(hivemind)
		hivemind_talk(message)
	else
		playsound(loc, "alien_talk", 25, 1)
		return ..(message, language, verb, null, null, message_range, null)


/mob/living/carbon/Xenomorph/proc/hivemind_name()
	return "<span class='game say'>Hivemind, <span class='name'>[name]</span>"

/mob/living/carbon/Xenomorph/Queen/hivemind_name()
	return "<font size='3' font color='purple'><i><span class='game say'>Hivemind, <span class='name'>[name]</span>"

/mob/living/carbon/Xenomorph/proc/hivemind_end()
	return ""

/mob/living/carbon/Xenomorph/Queen/hivemind_end()
	return "</font>"

/mob/living/carbon/Xenomorph/proc/render_hivemind_message(message)
	return message

/mob/living/carbon/Xenomorph/proc/hivemind_talk(message)
	if(!message || src.stat)
		return
	if(!hive)
		return

	if(!hive.living_xeno_queen && hive.xeno_queen_timer > QUEEN_DEATH_TIMER*0.5 && hivenumber == XENO_HIVE_NORMAL)
		to_chat(src, "<span class='warning'>The Queen is dead. The hivemind is weakened. Despair!</span>")
		return

	message = render_hivemind_message(message)

	log_talk(message, LOG_HIVEMIND)

	

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/S = i
		if(!S?.client?.prefs || !(S.client.prefs.toggles_chat & CHAT_GHOSTHIVEMIND))
			continue
		var/track = "(<a href='byond://?src=\ref[S];track=\ref[src]'>follow</a>)"
		S.show_message("[hivemind_name()] [track] <span class='message'>hisses, '[message]'</span></span></i>[hivemind_end()]", 2)

	hive.hive_mind_message(src, message)

/mob/living/carbon/Xenomorph/proc/receive_hivemind_message(mob/living/carbon/Xenomorph/X, message)
	show_message("[X.hivemind_name()] <span class='message'>hisses, '[message]'</span></span></i>[hivemind_end()]", 2)

/mob/living/carbon/Xenomorph/Queen/receive_hivemind_message(mob/living/carbon/Xenomorph/X, message)
	if(ovipositor && X != src)
		show_message("[X.hivemind_name()] (<a href='byond://?src=\ref[src];queentrack=\ref[X]'>watch</a>)<span class='message'>hisses, '[message]'</span></span></i>[hivemind_end()]", 2)
	else
		return ..()


/mob/living/carbon/Xenomorph/get_message_language(message)
	if(copytext(message, 1, 2) == "," || copytext(message, 1, 2) == ".")
		var/key = copytext(message, 2, 3)
		for(var/ld in GLOB.all_languages)
			var/datum/language/LD = ld
			if(initial(LD.key) == key)
				return LD
	else if(copytext(message, 1, 2) == ";")
		return GLOB.language_datum_instances[/datum/language/xenohivemind]
	return null