/mob/living/carbon/hellhound/emote(var/act,var/m_type=1,var/message = null, player_caused)

//	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
//		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	if(stat) return

	switch(act)
		if ("me")
			return
		if ("custom")
			return
		if("scratch")
			if (!src.is_mob_restrained())
				message = "<B>The [src.name]</B> scratches."
				m_type = 1
		if("roar")
			message = "<B>The [src.name] roars!</b>"
			m_type = 2
			playsound(src.loc, 'sound/voice/ed209_20sec.ogg', 25, 1)
		if("tail")
			message = "<B>The [src.name]</B> waves its tail."
			m_type = 1
		if("paw")
			if (!src.is_mob_restrained())
				message = "<B>The [src.name]</B> flails its paw."
				m_type = 1
		if("sway")
			message = "<B>The [src.name]</B> sways around dizzily."
			m_type = 1
		if("snore")
			message = "<B>The [src.name]</B> snores."
			m_type = 1
		if("whimper")
			message = "<B>The [src.name]</B> whimpers."
			m_type = 1
		if("grunt")
			message = "<B>The [src.name]</B> grunts."
			m_type = 1
		if("rumble")
			message = "<B>The [src.name]</B> rumbles deeply."
			m_type = 1
		if("howl")
			message = "<B>The [src.name]</B> howls!"
			m_type = 1
		if("growl")
			message = "<B>The [src.name]</B> emits a strange, menacing growl."
			m_type = 1
		if("stare")
			message = "<B>The [src.name]</B> stares."
			m_type = 1
		if("sniff")
			message = "<B>The [src.name]</B> sniffs about."
			m_type = 1
		if("dance")
			if (!src.is_mob_restrained())
				message = "<B>The [src.name]</B> dances around!"
				m_type = 1
				spawn(0)
					for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
						dir = i
						sleep(1)
		if("help")
			text += "scratch, whimper, roar, tail, paw, sway, snore, grunt, rumble, howl, growl, stare, sniff, dance"
			to_chat(src, text)
			return
		else
			to_chat(src, text("Invalid Emote: []", act))
			return
	if (message)
		if(src.client)
			log_message(message, LOG_EMOTE)
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(703)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(746)
	return