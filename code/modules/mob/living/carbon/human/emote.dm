/mob/living/carbon/human/emote(var/act,var/m_type=1,var/message = null, player_caused)
	var/param = null
	var/comm_paygrade = get_paygrade()

	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)

	for (var/obj/item/implant/I in src)
		if (I.implanted)
			I.trigger(act, src)


	if(act != "help") //you can always use the help emote
		if(stat == DEAD)
			return

		else if(stat && (act != "gasp" || player_caused)) //involuntary gasps can still be emoted when unconscious
			return

	switch(act)
		if ("me")
			if(player_caused)
				if (src.client)
					if (client.prefs.muted & MUTE_IC)
						to_chat(src, "\red You cannot send IC messages (muted).")
						return
					if (src.client.handle_spam_prevention(message,MUTE_IC))
						return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, "[message]", player_caused)

		if ("blink")
			message = "<B>[comm_paygrade][src]</B> blinks."
			m_type = 1

		if ("blink_r")
			message = "<B>[comm_paygrade][src]</B> blinks rapidly."
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
					message = "<B>[comm_paygrade][src]</B> bows to [param]."
				else
					message = "<B>[comm_paygrade][src]</B> bows."
			m_type = 1

		if ("chuckle")
			if (!muzzled)
				message = "<B>[comm_paygrade][src]</B> chuckles."
				m_type = 2
			else
				message = "<B>[comm_paygrade][src]</B> makes a noise."
				m_type = 2

		if ("clap")
			if (is_mob_restrained() || audio_emote_cooldown(player_caused))
				return
			message = "<B>[comm_paygrade][src]</B> claps."
			m_type = 2
			playsound(src.loc, 'sound/misc/clap.ogg', 25, 0)

		if ("collapse")
			KnockOut(2)
			message = "<B>[comm_paygrade][src]</B> collapses!"
			m_type = 2

		if ("cough")
			if (!muzzled)
				message = "<B>[comm_paygrade][src]</B> coughs!"
				m_type = 2
			else
				message = "<B>[comm_paygrade][src]</B> makes a strong noise."
				m_type = 2

		if ("cry")
			message = "<B>[comm_paygrade][src]</B> cries."
			m_type = 1

		if ("drool")
			message = "<B>[comm_paygrade][src]</B> drools."
			m_type = 1

		if ("eyebrow")
			message = "<B>[comm_paygrade][src]</B> raises an eyebrow."
			m_type = 1

		if ("facepalm")
			message = "<B>[comm_paygrade][src]</B> facepalms."
			m_type = 1

		if ("faint")
			message = "<B>[comm_paygrade][src]</B> faints!"
			if(src.sleeping)
				return //Can't faint while asleep
			src.sleeping += 10 //Short-short nap
			m_type = 1

		if ("frown")
			message = "<B>[comm_paygrade][src]</B> frowns."
			m_type = 1

		if ("gasp")
			if (!muzzled)
				message = "<B>[comm_paygrade][src]</B> gasps!"
				m_type = 2
			else
				message = "<B>[comm_paygrade][src]</B> makes a weak noise."
				m_type = 2

		if ("giggle")
			if (!muzzled)
				message = "<B>[comm_paygrade][src]</B> giggles."
				m_type = 2
			else
				message = "<B>[comm_paygrade][src]</B> makes a noise."
				m_type = 2

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
				message = "<B>[comm_paygrade][src]</B> glares at [param]."
			else
				message = "<B>[comm_paygrade][src]</B> glares."

		if ("golfclap")
			if (is_mob_restrained() || audio_emote_cooldown(player_caused))
				return
			message = "<B>[comm_paygrade][src]</B> claps, clearly unimpressed."
			m_type = 2
			playsound(src.loc, 'sound/misc/golfclap.ogg', 25, 0)

		if ("grin")
			message = "<B>[comm_paygrade][src]</B> grins."
			m_type = 1

		if ("grumble")
			if (!muzzled)
				message = "<B>[comm_paygrade][src]</B> grumbles."
				m_type = 2
			else
				message = "<B>[comm_paygrade][src]</B> makes a noise."
				m_type = 2

		if ("handshake")
			m_type = 1
			if (!src.is_mob_restrained() && !src.r_hand)
				var/mob/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					if (M.canmove && !M.r_hand && !M.is_mob_restrained())
						message = "<B>[comm_paygrade][src]</B> shakes hands with [M]."
					else
						message = "<B>[comm_paygrade][src]</B> holds out \his hand to [M]."

		if("hug")
			m_type = 1
			if (!src.is_mob_restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					message = "<B>[comm_paygrade][src]</B> hugs [M]."
				else
					message = "<B>[comm_paygrade][src]</B> hugs \himself."

		if ("laugh")
			if (!muzzled)
				message = "<B>[comm_paygrade][src]</B> laughs!"
				m_type = 2
			else
				message = "<B>[comm_paygrade][src]</B> makes a noise."
				m_type = 2

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
						message = "<B>[comm_paygrade][src]</B> looks at [param]."
					else
						message = "<B>[comm_paygrade][src]</B> looks."
					m_type = 1

		if ("medic")
			if (muzzled || audio_emote_cooldown(player_caused))
				return
			message = "<B>[comm_paygrade][src] calls for a medic!</b>"
			m_type = 2
			if(src.gender == "male")
				if(rand(0,100) < 95)
					playsound(src.loc, 'sound/voice/human_male_medic.ogg', 25, 0)
				else
					playsound(src.loc, 'sound/voice/human_male_medic2.ogg', 25, 0)
			else
				playsound(src.loc, 'sound/voice/human_female_medic.ogg', 25, 0)


		if ("moan")
			message = "<B>[comm_paygrade][src]</B> moans."
			m_type = 1

		if ("mumble")
			message = "<B>[comm_paygrade][src]</B> mumbles."
			m_type = 2

		if ("nod")
			message = "<B>[comm_paygrade][src]</B> nods."
			m_type = 1

		if ("pain")
			if (muzzled || audio_emote_cooldown(player_caused))
				return
			message = "<B>[comm_paygrade][src]</B> cries out in pain!"
			m_type = 2
			if(client && species)
				if(species.screams[gender])
					playsound(loc, species.screams[gender], 50)
				else if(species.screams[NEUTER])
					playsound(loc, species.screams[NEUTER], 50)

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
					message = "<B>[comm_paygrade][src]</B> salutes to [param]."
				else
					message = "<B>[comm_paygrade][src]</b> salutes."
				playsound(src.loc, 'sound/misc/salute.ogg', 15, 1)
			m_type = 1

		if("scream")
			if (muzzled || audio_emote_cooldown(player_caused))
				return
			message = "<B>[comm_paygrade][src]</B> screams!"
			m_type = 2
			if(client && species)
				if(species.screams[gender])
					playsound(loc, species.screams[gender], 50)
				else if(species.screams[NEUTER])
					playsound(loc, species.screams[NEUTER], 50)

		if("shakehead")
			message = "<B>[comm_paygrade][src]</B> shakes \his head."
			m_type = 1

		if ("shiver")
			message = "<B>[comm_paygrade][src]</B> shivers."
			m_type = 1

		if ("shrug")
			message = "<B>[comm_paygrade][src]</B> shrugs."
			m_type = 1

		if ("sigh")
			if (!muzzled)
				message = "<B>[comm_paygrade][src]</B> sighs."
				m_type = 2
			else
				message = "<B>[comm_paygrade][src]</B> makes a weak noise."
				m_type = 2

		if ("signal")
			if (!src.is_mob_restrained())
				var/t1 = round(text2num(param))
				if (isnum(t1))
					if (t1 <= 5 && (!src.r_hand || !src.l_hand))
						message = "<B>[comm_paygrade][src]</B> raises [t1] finger\s."
					else if (t1 <= 10 && (!src.r_hand && !src.l_hand))
						message = "<B>[comm_paygrade][src]</B> raises [t1] finger\s."
			m_type = 1

		if ("smile")
			message = "<B>[comm_paygrade][src]</B> smiles."
			m_type = 1

		if ("sneeze")
			message = "<B>[comm_paygrade][src]</B> sneezes!"
			m_type = 1

		if ("snore")
			message = "<B>[comm_paygrade][src]</B> snores."
			m_type = 1

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
				message = "<B>[comm_paygrade][src]</B> stares at [param]."
			else
				message = "<B>[comm_paygrade][src]</B> stares."

		if ("twitch")
			message = "<B>[comm_paygrade][src]</B> twitches."
			m_type = 1

		if ("wave")
			message = "<B>[comm_paygrade][src]</B> waves."
			m_type = 1

		if ("yawn")
			if (!muzzled)
				message = "<B>[comm_paygrade][src]</B> yawns."
				m_type = 2


		if ("help")
			var/msg = "<br><br><b>To use an emote, type an asterix (*) before a following word. Emotes with a sound are <span style='color: green;'>green</span>. Spamming emotes with sound will likely get you banned. Don't do it.<br><br> \
			blink, \
			blink_r, \
			bow-(mob name), \
			chuckle, \
			<span style='color: green;'>clap</span>, \
			collapse, \
			cough, \
			cry, \
			drool, \
			eyebrow, \
			facepalm, \
			faint, \
			frown, \
			gasp, \
			giggle, \
			glare-(mob name), \
			<span style='color: green;'>golfclap</span>, \
			grin, \
			grumble, \
			handshake, \
			hug-(mob name), \
			laugh, \
			look-(mob name), \
			me, \
			<span style='color: green;'>medic</span>, \
			moan, \
			mumble, \
			nod, \
			point, \
			<span style='color: green;'>salute</span>, \
			scream, \
			shakehead, \
			shiver, \
			shrug, \
			sigh, \
			signal-#1-10, \
			smile, \
			sneeze, \
			snore, \
			stare-(mob name), \
			twitch, \
			wave, \
			yawn</b><br>"
			to_chat(src, msg)
			if (has_species(src,"Yautja"))
				var/yautja_msg = "<br><b>As a Predator, you have the following additional emotes. Tip: The *medic emote has neither a cooldown nor a visibile origin...<br><br>\
				<span style='color: green;'>anytime</span>, \
				<span style='color: green;'>click</span>, \
				<span style='color: green;'>helpme</span>, \
				<span style='color: green;'>iseeyou</span>, \
				<span style='color: green;'>itsatrap</span>, \
				<span style='color: green;'>laugh1</span>, \
				<span style='color: green;'>laugh2</span>, \
				<span style='color: green;'>laugh3</span>, \
				<span style='color: green;'>malescream</span>, \
				<span style='color: green;'>femalescream</span>, \
				me, \
				<span style='color: green;'>overhere</span>, \
				<span style='color: green;'>turnaround</span>, \
				<span style='color: green;'>roar</span></b><br>"
				to_chat(src, yautja_msg)


		// Pred emotes
		if ("anytime")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/voice/pred_anytime.ogg', 25, 0)
		if ("click")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				spawn(2)
					if(rand(0,100) < 50)
						playsound(src.loc, 'sound/voice/pred_click1.ogg', 25, 1)
					else
						playsound(src.loc, 'sound/voice/pred_click2.ogg', 25, 1)
		if ("helpme")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/voice/pred_helpme.ogg', 25, 0)
		if("malescream")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(loc, "male_scream", 50)
		if("femalescream")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(loc, "female_scream", 50)
		if ("iseeyou")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/hallucinations/i_see_you2.ogg', 25, 0)
		if ("itsatrap")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/voice/pred_itsatrap.ogg', 25, 0)
		if ("laugh1")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/voice/pred_laugh1.ogg', 25, 0)
		if ("laugh2")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/voice/pred_laugh2.ogg', 25, 0)
		if ("laugh3")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/voice/pred_laugh3.ogg', 25, 0)
		if ("overhere")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/voice/pred_overhere.ogg', 25, 0)
		if ("roar")
			if(has_species(src,"Yautja") && src.loc)
				message = "<B>[src] roars!</b>"
				m_type = 1
				spawn(2)
					if(rand(0,100) < 50)
						playsound(src.loc, 'sound/voice/pred_roar1.ogg', 50, 1)
					else
						playsound(src.loc, 'sound/voice/pred_roar2.ogg', 50, 1)
		if ("turnaround")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/voice/pred_turnaround.ogg', 25, 0)
		else
			to_chat(src, "\blue Unusable emote '[act]'. Say *help for a list of emotes.")

	if (message)
		log_message(message, LOG_EMOTE)

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in dead_mob_list)
			if(!M.client || istype(M, /mob/new_player))
				continue //skip monkeys, leavers and new players
			if(M.stat == DEAD && M.client.prefs && (M.client.prefs.toggles_chat & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(message)


		if (m_type & 1)
			for (var/mob/O in get_mobs_in_view(world.view,src))
				O.show_message(message, m_type)
		else if (m_type & 2)
			for (var/mob/O in (hearers(src.loc, null)|get_mobs_in_view(world.view,src)))
				O.show_message(message, m_type)


/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose =  copytext(sanitize(input(usr, "This is [src]. \He is...", "Pose", null)  as text), 1, MAX_MESSAGE_LEN)

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	var/HTML = "<body>"
	HTML += "<tt><center>"
	HTML += "<b>Update Flavour Text</b> <hr />"
	HTML += "<br></center>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=general'>General:</a> "
	HTML += TextPreview(flavor_texts["general"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=head'>Head:</a> "
	HTML += TextPreview(flavor_texts["head"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=face'>Face:</a> "
	HTML += TextPreview(flavor_texts["face"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=eyes'>Eyes:</a> "
	HTML += TextPreview(flavor_texts["eyes"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=torso'>Body:</a> "
	HTML += TextPreview(flavor_texts["torso"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=arms'>Arms:</a> "
	HTML += TextPreview(flavor_texts["arms"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=hands'>Hands:</a> "
	HTML += TextPreview(flavor_texts["hands"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=legs'>Legs:</a> "
	HTML += TextPreview(flavor_texts["legs"])
	HTML += "<br>"
	HTML += "<a href='byond://?src=\ref[src];flavor_change=feet'>Feet:</a> "
	HTML += TextPreview(flavor_texts["feet"])
	HTML += "<br>"
	HTML += "<hr />"
	HTML +="<a href='?src=\ref[src];flavor_change=done'>\[Done\]</a>"
	HTML += "<tt>"
	src << browse(HTML, "window=flavor_changes;size=430x300")

/mob/living/carbon/human/proc/audio_emote_cooldown(player_caused)
	if(player_caused)
		if(recent_audio_emote)
			src << "You just did an audible emote. Wait a while."
			return TRUE
		start_audio_emote_cooldown()
	return FALSE

/mob/living/carbon/human/proc/start_audio_emote_cooldown()
	set waitfor = 0
	recent_audio_emote = TRUE
	sleep(50)
	recent_audio_emote = FALSE
