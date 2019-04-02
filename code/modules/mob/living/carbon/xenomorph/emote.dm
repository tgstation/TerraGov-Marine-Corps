/mob/living/carbon/Xenomorph/emote(act, m_type = EMOTE_AUDIBLE, message, player_caused)
	if(stat)
		return

	if(findtext(act, "-"))
		var/t1 = findtext(act, "-")
		act = copytext(act, 1, t1)

	if(stat && act != "help")
		return

	if(istype(src, /mob/living/carbon/Xenomorph/Larva))
		playsound(loc, "alien_roar_larva", 15)
		return

	if(act == "me")
		m_type = EMOTE_VISIBLE
		if(silent)
			return
		if(player_caused)
			if(client)
				if(is_banned_from(ckey, "Emote"))
					to_chat(src, "<span class='warning'>You cannot send emotes (banned).</span>")
					return
				if(client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='warning'>You cannot send IC messages (muted)</span>")
					return
				if(client.handle_spam_prevention(message, MUTE_IC))
					return
		if(stat)
			return
		if(!message)
			return
		return custom_emote(m_type, message, player_caused)

	else if(act == "custom")
		m_type = EMOTE_VISIBLE
		return custom_emote(m_type, message, player_caused)


	else if(act == "help")
		var/msg = "<br><br><b>To use an emote, type an asterix (*) before a following word. Emotes with a sound are <span style='color: green;'>green</span>. Spamming emotes with sound will likely get you banned. Don't do it.<br><br>\
		dance, \
		<span style='color: green;'>growl</span>, \
		<span style='color: green;'>growl1</span>, \
		<span style='color: green;'>growl2</span>, \
		<span style='color: green;'>growl3</span>, \
		<span style='color: green;'>hiss</span>, \
		<span style='color: green;'>hiss1</span>, \
		<span style='color: green;'>hiss2</span>, \
		<span style='color: green;'>hiss3</span>, \
		me, \
		<span style='color: green;'>needhelp</span>, \
		<span style='color: green;'>roar</span>, \
		<span style='color: green;'>roar1</span>, \
		<span style='color: green;'>roar2</span>, \
		<span style='color: green;'>roar3</span>, \
		<span style='color: green;'>roar4</span>, \
		<span style='color: green;'>roar5</span>, \
		<span style='color: green;'>roar6</span>, \
		<span style='color: green;'>tail</span>, \
		<span style='color: green;'>tail1</span>, \
		<span style='color: green;'>tail2</span>, \
		<span style='color: green;'>tail3</span></b><br>"
		to_chat(src, msg)

	else if(audio_emote_cooldown(player_caused))
		return

	if(findtext(act, "growl"))
		message = "<B>The [name]</B> growls."

	else if(findtext(act, "hiss"))
		message = "<B>The [name]</B> hisses."

	else if(findtext(act, "roar"))
		message = "<B>The [name]</B> roars!"

	else if(findtext(act, "tail"))
		message = "<B>The [name]</B> swipes its tail."

	switch(act)
		if("growl")
			playsound(loc, "alien_growl", 15)
		if("growl1")
			playsound(loc, "sound/voice/alien_growl1.ogg", 15)
		if("growl2")
			playsound(loc, "sound/voice/alien_growl2.ogg", 15)
		if("growl3")
			playsound(loc, "sound/voice/alien_growl3.ogg", 15)
		if("hiss")
			playsound(loc, "alien_hiss", 25)
		if("hiss1")
			playsound(loc, "sound/voice/alien_hiss1.ogg", 25)
		if("hiss2")
			playsound(loc, "sound/voice/alien_hiss2.ogg", 25)
		if("hiss3")
			playsound(loc, "sound/voice/alien_hiss3.ogg", 25)
		if("needhelp")
			message = "<B>The [name]</B> needs help!"
			playsound(loc, "alien_help", 25)
		if("roar")
			playsound(loc, "alien_roar", 40)
		if("roar1")
			playsound(loc, "sound/voice/alien_roar1.ogg", 40)
		if("roar2")
			playsound(loc, "sound/voice/alien_roar2.ogg", 40)
		if("roar3")
			playsound(loc, "sound/voice/alien_roar3.ogg", 40)
		if("roar4")
			playsound(loc, "sound/voice/alien_roar4.ogg", 40)
		if("roar5")
			playsound(loc, "sound/voice/alien_roar5.ogg", 40)
		if("roar6")
			playsound(loc, "sound/voice/alien_roar6.ogg", 40)
		if("tail")
			playsound(loc, "alien_tail_swipe", 40)
		if("tail1")
			playsound(loc, "sound/effects/alien_tail_swipe1.ogg", 40)
		if("tail2")
			playsound(loc, "sound/effects/alien_tail_swipe2.ogg", 40)
		if("tail3")
			playsound(loc, "sound/effects/alien_tail_swipe3.ogg", 40)

	if(message)
		log_message(message, LOG_EMOTE)
		if(m_type & EMOTE_VISIBLE)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)