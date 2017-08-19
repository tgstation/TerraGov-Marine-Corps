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
		src << "STOP SPAMMING"
		return
	switch(act)
		if("me")
			if(silent)
				return
			if(player_caused)
				if(client)
					if (client.prefs.muted & MUTE_IC)
						src << "<span class='warning'>You cannot send IC messages (muted)</span>"
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
		if("roar")
			if(!muzzled)
				m_type = 2
				message = "<B>The [src.name]</B> roars!"
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_roar.ogg', 75, 1)
				else
					if(mob_size != MOB_SIZE_BIG)
						playsound(loc, 'sound/voice/alien_roar_small.ogg', 25, 1)
					else
						playsound(loc, 'sound/voice/alien_roar_large.ogg', 50, 1)
		if("growl")
			if(!muzzled)
				m_type = 2
				message = "<B>The [src.name]</B> growls."
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_growl.ogg', 25, 1)
				else
					if(mob_size != MOB_SIZE_BIG)
						playsound(loc, 'sound/voice/alien_growl_small.ogg', 15, 1)
					else
						playsound(loc, 'sound/voice/alien_growl_large.ogg', 25, 1)
		if("hiss")
			if (!muzzled)
				m_type = 2
				message = "<B>The [src.name]</B> hisses."
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_hiss.ogg', 25, 1)
				else
					if(mob_size != MOB_SIZE_BIG)
						playsound(loc, 'sound/voice/alien_hiss_small.ogg', 25, 1)
					else
						playsound(loc, 'sound/voice/alien_hiss_large.ogg', 25, 1)
		if("tail")
			if(!muzzled)
				m_type = 2
				message = "<B>The [src.name]</B> lashes its tail."
				playsound(src.loc, 'sound/voice/alien_tail.ogg', 25, 1)
		if("dance")
			if(!src.is_mob_restrained())
			//	message = "<B>The [src.name]</B> dances around!"
				m_type = 1
				spawn(0)
					for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2))
						canmove = 0
						dir = i
						sleep(1)
				canmove = 1

		if("help")
			src << "<br><br><b>To use an emote, type an asterix (*) before a following word. Emotes with a sound are <span style='color: green;'>green</span>. Spamming emotes with sound will likely get you banned. Don't do it.<br><br>\
			dance, \
			<span style='color: green;'>growl</span>, \
			<span style='color: green;'>hiss</span>, \
			me, \
			<span style='color: green;'>roar</span>, \
			<span style='color: green;'>tail</span></b><br>"
		else
			src << text("Invalid Emote: []", act)
	if(message)
		log_emote("[name]/[key] : [message]")
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
