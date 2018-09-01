/mob/living/carbon/Xenomorph/emote(var/act, var/m_type = 1, var/message = null, player_caused)
	if(stat) return
	if(findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		act = copytext(act, 1, t1)

	//if(findtext(act,"s",-1) && !findtext(act,"_",-2)) //Removes ending s's unless they are prefixed with a '_'
	//	act = copytext(act,1,length(act))
	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)

	if(stat && act != "help")
		return

	if(emotedown)
		to_chat(src, "STOP SPAMMING")
		return

	if(istype(src, /mob/living/carbon/Xenomorph/Larva))
		playsound(loc, "alien_roar_larva", 15)
		return

	switch(act)
		if("me")
			if(silent)
				return
			if(player_caused)
				if(client)
					if (client.prefs.muted & MUTE_IC)
						to_chat(src, "<span class='warning'>You cannot send IC messages (muted)</span>")
						return
					if(client.handle_spam_prevention(message, MUTE_IC))
						return
			if(stat)
				return
			if(!message)
				return
			return custom_emote(m_type, message, player_caused)

		if("custom")
			return custom_emote(m_type, message, player_caused)
		if("growl")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> growls."
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_growl.ogg', 25, 1)
				else
					playsound(loc, "alien_growl", 15)
		if("growl1")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> growls."
				playsound(loc, "sound/voice/alien_growl1.ogg", 15)
		if("growl2")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> growls."
				playsound(loc, "sound/voice/alien_growl2.ogg", 15)
		if("growl3")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> growls."
				playsound(loc, "sound/voice/alien_growl3.ogg", 15)
		if("hiss")
			if (!muzzled)
				m_type = 2
				message = "<B>The [name]</B> hisses."
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_hiss.ogg', 25, 1)
				else
					playsound(loc, "alien_hiss", 25)
		if("hiss1")
			if (!muzzled)
				m_type = 2
				message = "<B>The [name]</B> hisses."
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_hiss.ogg', 25, 1)
				else
					playsound(loc, "sound/voice/alien_hiss1.ogg", 25)
		if("hiss2")
			if (!muzzled)
				m_type = 2
				message = "<B>The [name]</B> hisses."
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_hiss.ogg', 25, 1)
				else
					playsound(loc, "sound/voice/alien_hiss2.ogg", 25)
		if("hiss3")
			if (!muzzled)
				m_type = 2
				message = "<B>The [name]</B> hisses."
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_hiss.ogg', 25, 1)
				else
					playsound(loc, "sound/voice/alien_hiss3.ogg", 25)
		if("needhelp")
			if (!muzzled)
				m_type = 2
				message = "<B>The [name]</B> needs help!"
				playsound(loc, "alien_help", 25)
		if("roar")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> roars!"
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_roar.ogg', 40, 1)
				else
					playsound(loc, "alien_roar", 40)
		if("roar1")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> roars!"
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_roar.ogg', 40, 1)
				else
					playsound(loc, "sound/voice/alien_roar1.ogg", 40)
		if("roar2")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> roars!"
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_roar.ogg', 40, 1)
				else
					playsound(loc, "sound/voice/alien_roar2.ogg", 40)
		if("roar3")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> roars!"
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_roar.ogg', 40, 1)
				else
					playsound(loc, "sound/voice/alien_roar3.ogg", 40)
		if("roar4")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> roars!"
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_roar.ogg', 40, 1)
				else
					playsound(loc, "sound/voice/alien_roar4.ogg", 40)
		if("roar5")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> roars!"
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_roar.ogg', 40, 1)
				else
					playsound(loc, "sound/voice/alien_roar5.ogg", 40)
		if("roar6")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> roars!"
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_roar.ogg', 40, 1)
				else
					playsound(loc, "sound/voice/alien_roar6.ogg", 40)
		if("tail")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> swipes its tail."
				playsound(loc, "alien_tail_swipe", 40)
		if("tail1")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> swipes its tail."
				playsound(loc, "sound/effects/alien_tail_swipe1.ogg", 40)
		if("tail2")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> swipes its tail."
				playsound(loc, "sound/effects/alien_tail_swipe2.ogg", 40)
		if("tail3")
			if(!muzzled)
				m_type = 2
				message = "<B>The [name]</B> swipes its tail."
				playsound(loc, "sound/effects/alien_tail_swipe3.ogg", 40)
		if("dance")
			if(!src.is_mob_restrained())
			//	message = "<B>The [name]</B> dances around!"
				m_type = 1
				spawn(0)
					for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2))
						canmove = 0
						dir = i
						sleep(1)
				canmove = 1

		if("help")
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
		else
			to_chat(src, text("Invalid Emote: []", act))
	if(message)
		log_message(message, LOG_EMOTE)
		if(m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)

	if(player_caused)
		emotedown = 1
		spawn(50)
			emotedown = 0
