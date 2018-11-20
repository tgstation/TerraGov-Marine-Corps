/mob/living/carbon/Xenomorph/say(var/message)
	var/verb = "says"
	var/forced = 0
	var/message_range = world.view

	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (Muted).</span>")
			return

	message =  trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(stat == DEAD)
		return say_dead(message)

	if(stat == UNCONSCIOUS)
		return //Unconscious? Nope.

	if(copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2))

	var/datum/language/speaking = null

	if(copytext(message, 1, 2) != ";")
		if(length(message) >= 2)
			var/channel_prefix = copytext(message, 1, 3)
			if(languages.len)
				for(var/datum/language/L in languages)
					if(lowertext(channel_prefix) == ":[L.key]" || lowertext(channel_prefix) == ".[L.key]")
						verb = L.speech_verb
						speaking = L
						break

		if(!(xeno_caste.caste_flags & CASTE_IS_ROBOTIC))
			if(isnull(speaking) || speaking.key != "a") //Not hivemind? Then default to xenocommon. BRUTE FORCE YO
				for(var/datum/language/L in languages)
					if(L.key == "x")
						verb = L.speech_verb
						speaking = L
						forced = 1
						break
		else
			if(!speaking || isnull(speaking))
				for(var/datum/language/L in languages)
					if(L.key == "0")
						verb = L.speech_verb
						speaking = L
						forced = 1
						break
	else
		message = trim(copytext(message,2))

	if(speaking && !forced)
		message = trim(copytext(message,3))

	message = capitalize(trim_left(message))

	if(!message || stat)
		return

	if(forced)
		if(xeno_caste.caste_flags & CASTE_IS_ROBOTIC)
			var/noise = pick('sound/machines/ping.ogg','sound/machines/twobeep.ogg')
			verb = pick("beeps", "buzzes", "pings")
			playsound(src.loc, noise, 25, 1)
		else if(isXenoPredalien(src))
			playsound(loc, 'sound/voice/predalien_click.ogg', 25, 1)
		else
			playsound(loc, "alien_talk", 25, 1)
		..(message, speaking, verb, null, null, message_range, null)
	else
		hivemind_talk(message)

/mob/living/carbon/Xenomorph/say_understands(var/mob/other,var/datum/language/speaking = null)
	if(isXeno(other))
		return TRUE
	return ..()

//General proc for hivemind. Lame, but effective.
/mob/living/carbon/Xenomorph/proc/hivemind_talk(var/message)
	if(!message || src.stat)
		return
	var/datum/hive_status/hive
	if(hivenumber && hivenumber <= hive_datum.len)
		hive = hive_datum[hivenumber]
	else
		return
	if(!hive.living_xeno_queen && hive.xeno_queen_timer > QUEEN_DEATH_TIMER*0.5 && hivenumber == 1)
		to_chat(src, "<span class='warning'>The Queen is dead. The hivemind is weakened. Despair!</span>")
		return
	var/rendered
	if(isXenoQueen(src))
		rendered = "<font size='3' font color='purple'><i><span class='game say'>Hivemind, <span class='name'>[name]</span> <span class='message'> hisses, '[message]'</span></span></i></font>"
	else if(xeno_caste.caste_flags & CASTE_IS_ROBOTIC)
		var/message_b = pick("high-pitched blast of static","series of pings","long string of numbers","loud, mechanical squeal", "series of beeps")
		rendered = "<i><span class='game say'>Hivemind, <span class='name'>[name]</span> emits a [message_b]!</span></i>"
	else
		rendered = "<i><span class='game say'>Hivemind, <span class='name'>[name]</span> <span class='message'> hisses, '[message]'</span></span></i>"
	log_talk(message, LOG_HIVEMIND)
	var/track = ""
	var/ghostrend
	for (var/mob/S in player_list)
		if(isnull(S) || (!isXeno(S) && S.stat != DEAD) || istype(S,/mob/new_player))
			continue
		if(istype(S,/mob/dead/observer))
			if(S.client.prefs && S.client.prefs.toggles_chat & CHAT_GHOSTHIVEMIND)
				track = "(<a href='byond://?src=\ref[S];track=\ref[src]'>follow</a>)"
				if(isXenoQueen(src))
					ghostrend = "<font size='3' font color='purple'><i><span class='game say'>Hivemind, <span class='name'>[name]</span> [track]<span class='message'> hisses, '[message]'</span></span></i></font>"
				else
					ghostrend = "<i><span class='game say'>Hivemind, <span class='name'>[name]</span> [track]<span class='message'> hisses, '[message]'</span></span></i>"
				S.show_message(ghostrend, 2)
		else if(S != src && S == hive.living_xeno_queen && hive.living_xeno_queen.ovipositor)
			var/queenrend = "<i><span class='game say'>Hivemind, <span class='name'>[name]</span> (<a href='byond://?src=\ref[S];queentrack=\ref[src]'>watch</a>)<span class='message'> hisses, '[message]'</span></span></i>"
			S.show_message(queenrend, 2)
		else if(hivenumber == xeno_hivenumber(S))
			S.show_message(rendered, 2)
