/mob/living/silicon/robot/emote(var/act,var/m_type=1,var/message = null, player_caused)
	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	switch(act)
		if ("me")
			if(player_caused)
				if (src.client)
					if(client.prefs.muted & MUTE_IC)
						src << "You cannot send IC messages (muted)."
						return
					if (src.client.handle_spam_prevention(message,MUTE_IC))
						return
			if (stat)
				return
			if(!(message))
				return
			else
				return custom_emote(m_type, message, player_caused)

		if ("custom")
			return custom_emote(m_type, message, player_caused)

		if ("salute")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "<B>[src]</B> salutes to [param]."
				else
					message = "<B>[src]</b> salutes."
			m_type = 1
		if ("bow")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "<B>[src]</B> bows to [param]."
				else
					message = "<B>[src]</B> bows."
			m_type = 1

		if ("clap")
			if (!src.is_mob_restrained())
				message = "<B>[src]</B> claps."
				m_type = 2
		if ("flap")
			if (!src.is_mob_restrained())
				message = "<B>[src]</B> flaps his wings."
				m_type = 2

		if ("aflap")
			if (!src.is_mob_restrained())
				message = "<B>[src]</B> flaps his wings ANGRILY!"
				m_type = 2

		if ("twitch")
			message = "<B>[src]</B> twitches violently."
			m_type = 1

		if ("twitch_s")
			message = "<B>[src]</B> twitches."
			m_type = 1

		if ("nod")
			message = "<B>[src]</B> nods."
			m_type = 1

		if ("deathgasp")
			message = "<B>[src]</B> shudders violently for a moment, then becomes motionless, its eyes slowly darkening."
			m_type = 1

		if ("glare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> glares at [param]."
			else
				message = "<B>[src]</B> glares."

		if ("stare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> stares at [param]."
			else
				message = "<B>[src]</B> stares."

		if ("look")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break

			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> looks at [param]."
			else
				message = "<B>[src]</B> looks."
			m_type = 1

		if("beep")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> beeps at [param]."
			else
				message = "<B>[src]</B> beeps."
			playsound(src.loc, 'sound/machines/twobeep.ogg', 25, 0)
			m_type = 1

		if("ping")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> pings at [param]."
			else
				message = "<B>[src]</B> pings."
			playsound(src.loc, 'sound/machines/ping.ogg', 25, 0)
			m_type = 1

		if("buzz")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> buzzes at [param]."
			else
				message = "<B>[src]</B> buzzes."
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 25, 0)
			m_type = 1

		if("alert")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> sounds an alert at [param]!"
			else
				message = "<B>[src]</B> sounds an alert!"
			playsound(src.loc, 'sound/machines/beepalert.ogg', 25, 0)
			m_type = 1

		if("sad")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> makes a sad beep at [param] :("
			else
				message = "<B>[src]</B> makes a sad beep :("
			playsound(src.loc, 'sound/machines/beepsad.ogg', 25, 0)
			m_type = 1

		if("confused")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> makes a confused beep at [param]."
			else
				message = "<B>[src]</B> makes a confused beep."
			playsound(src.loc, 'sound/machines/beepconfused.ogg', 25, 0)
			m_type = 1

		if("spark")
			src.spark_system.start()

		if("law")
			if (istype(module,/obj/item/circuitboard/robot_module/security))
				message = "<B>[src]</B> shows its legal authorization barcode."

				playsound(src.loc, 'sound/voice/biamthelaw.ogg', 25, 0)
				m_type = 2
			else
				src << "You are not THE LAW, pal."

		if("halt")
			if (istype(module,/obj/item/circuitboard/robot_module/security))
				message = "<B>[src]</B>'s speakers skreech, \"Halt! Security!\"."

				playsound(src.loc, 'sound/voice/halt.ogg', 25, 0)
				m_type = 2
			else
				src << "You are not security."

		if ("help")
			src << "salute, bow-(none)/mob, clap, flap, aflap, twitch, twitch_s, nod, deathgasp, glare-(none)/mob, stare-(none)/mob, look, \nbeep, ping, buzz, alert, sad, confused, spark, law, halt"
		else
			src << "\blue Unusable emote '[act]'. Say *help for a list."

	if ((message && stat == CONSCIOUS))
		if (m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
	return
