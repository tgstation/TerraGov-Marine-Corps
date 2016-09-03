/mob/living/carbon/human/emote(var/act,var/m_type=1,var/message = null)
	var/param = null
	var/comm_paygrade = get_paygrade()

	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)

	for (var/obj/item/weapon/implant/I in src)
		if (I.implanted)
			I.trigger(act, src)

	if(src.stat == 2.0)
		return

	// if(has_species(src,"Human"))
	switch(act)
		if ("me")
			if (src.client)
				if (client.prefs.muted & MUTE_IC)
					src << "\red You cannot send IC messages (muted)."
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, "[message]")

		if ("blink")
			message = "<B>[comm_paygrade][src]</B> blinks."
			m_type = 1

		if ("blink_r")
			message = "blinks rapidly."
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

		// if ("burp")
		// 	if(!burped)
		// 		message = "<B>[src]</B> burps."
		// 		m_type = 1
		// 		if(rand(0,100) < 70)
		// 			playsound(src.loc, 'sound/misc/burp_short.ogg', 50, 0)
		// 		else
		// 			playsound(src.loc, 'sound/misc/burp_long.ogg', 50, 0)
		// 		burped = 1
		// 		spawn(6000)
		// 			burped = 0
		// 	else
		// 		src << "You strain yourself. Ouch!"
		// 		src.halloss += 10
		// 		return

		if ("chuckle")
			if(miming)
				message = "<B>[comm_paygrade][src]</B> appears to chuckle."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[comm_paygrade][src]</B> chuckles."
					m_type = 2
				else
					message = "<B>[comm_paygrade][src]</B> makes a noise."
					m_type = 2

		if ("clap")
			if(!clapped)
				if (!src.restrained())
					message = "<B>[comm_paygrade][src]</B> claps."
					m_type = 2
					if(miming)
						m_type = 1
					playsound(src.loc, 'sound/misc/clap.ogg', 50, 0)
					clapped = 1
					spawn(600)
						clapped = 0
			else
				src << "You just did that. Wait a while."
				return

		if ("collapse")
			Paralyse(2)
			message = "<B>[comm_paygrade][src]</B> collapses!"
			m_type = 2
			if(miming)
				m_type = 1

		if ("cough")
			if(miming)
				message = "<B>[comm_paygrade][src]</B> appears to cough!"
				m_type = 1
			else
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
			message = "facepalms."
			m_type = 1

		if ("faint")
			message = "<B>[comm_paygrade][src]</B> faints!"
			if(src.sleeping)
				return //Can't faint while asleep
			src.sleeping += 10 //Short-short nap
			m_type = 1

		// if ("fart")
		// 	if(!farted)
		// 		message = "<B>[src]</B> farts."
		// 		m_type = 1
		// 		farted = 1
		// 		if(rand(0,100) < 50)
		// 			playsound(src.loc, 'sound/misc/fart_short.ogg', 50, 0)
		// 		else
		// 			playsound(src.loc, 'sound/misc/fart_long.ogg', 50, 0)
		// 		spawn(6000)
		// 			farted = 0
		// 	else
		// 		src << "You strain yourself. Ouch!"
		// 		src.halloss += 10
		// 		return

		if ("frown")
			message = "<B>[comm_paygrade][src]</B> frowns."
			m_type = 1

		if ("gasp")
			if(miming)
				message = "<B>[comm_paygrade][src]</B> appears to be gasping!"
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[comm_paygrade][src]</B> gasps!"
					m_type = 2
				else
					message = "<B>[comm_paygrade][src]</B> makes a weak noise."
					m_type = 2

		if ("giggle")
			if(miming)
				message = "<B>[comm_paygrade][src]</B> giggles silently!"
				m_type = 1
			else
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
			if(!golfclapped)
				if (!src.restrained())
					message = "<B>[comm_paygrade][src]</B> claps, clearly unimpressed."
					m_type = 2
					if(miming)
						m_type = 1
					playsound(src.loc, 'sound/misc/golfclap.ogg', 50, 0)
					golfclapped = 1
					spawn(600)
						golfclapped = 0
			else
				src << "You just did that. Wait a while."
				return

		if ("grin")
			message = "<B>[comm_paygrade][src]</B> grins."
			m_type = 1

		if ("grumble")
			if(miming)
				message = "<B>[comm_paygrade][src]</B> grumbles."
				m_type = 1
			if (!muzzled)
				message = "<B>[comm_paygrade][src]</B> grumbles."
				m_type = 2
			else
				message = "<B>[comm_paygrade][src]</B> makes a noise."
				m_type = 2

		if ("handshake")
			m_type = 1
			if (!src.restrained() && !src.r_hand)
				var/mob/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					if (M.canmove && !M.r_hand && !M.restrained())
						message = "<B>[comm_paygrade][src]</B> shakes hands with [M]."
					else
						message = "<B>[comm_paygrade][src]</B> holds out \his hand to [M]."

		if("hug")
			m_type = 1
			if (!src.restrained())
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
			if(miming)
				message = "<B>[comm_paygrade][src]</B> acts out a laugh."
				m_type = 1
			else
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
			if (has_species(src,"Yautja"))
				playsound(src.loc, 'sound/misc/medic_female.ogg', 30, 0)
				return
			if(!medicd)
				if (!muzzled && !stat)
					message = "<B>[comm_paygrade][src] calls for a medic!</b>"
					m_type = 1
					if(src.gender == "male")
						if(rand(0,100) < 95)
							playsound(src.loc, 'sound/misc/medic_male.ogg', 30, 0)
						else
							playsound(src.loc, 'sound/misc/medic_male2.ogg', 30, 0)
					else
						playsound(src.loc, 'sound/misc/medic_female.ogg', 30, 0)
					medicd = 1
					spawn(600)
						medicd = 0
			else
				src << "You just did that. Wait a while."
				return

		if ("moan")
			message = "<B>[comm_paygrade][src]</B> moans."
			m_type = 1

		if ("mumble")
			message = "<B>[comm_paygrade][src]</B> mumbles."
			m_type = 2
			if(miming)
				m_type = 1

		if ("nod")
			message = "<B>[comm_paygrade][src]</B> nods."
			m_type = 1

		if ("point")
			if (!src.restrained())
				var/mob/M = null
				if (param)
					for (var/atom/A as mob|obj|turf|area in view(null, null))
						if (param == A.name)
							M = A
							break

				if (!M)
					message = "<B>[comm_paygrade][src]</B> points."
				else
					M.point()

				if (M)
					message = "<B>[comm_paygrade][src]</B> points to [M]."
				else
			m_type = 1

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
				playsound(src.loc, 'sound/misc/salute.ogg', 50, 1)
			m_type = 1

		if("scream")
			message = "<B>[comm_paygrade][src]</B> screams!"
			m_type = 1

		if("shakehead")
			message = "<B>[comm_paygrade][src]</B> shakes \his head."
			m_type = 1

		if ("shiver")
			message = "shivers."
			m_type = 1

		if ("shrug")
			message = "<B>[comm_paygrade][src]</B> shrugs."
			m_type = 1

		if ("sigh")
			if(miming)
				message = "<B>[comm_paygrade][src]</B> sighs."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[comm_paygrade][src]</B> sighs."
					m_type = 2
				else
					message = "<B>[comm_paygrade][src]</B> makes a weak noise."
					m_type = 2

		if ("signal")
			if (!src.restrained())
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
				if(miming)
					m_type = 1


		if ("help")
			src << "<br><br><b>To use an emote, type an asterix (*) before a following word. Emotes with a sound are <span style='color: green;'>green</span>. Spamming emotes with sound will likely get you banned. Don't do it.<br><br> \
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
			if (has_species(src,"Yautja"))
				src << "<br><b>As a Predator, you have the following additional emotes. Tip: The *medic emote has neither a cooldown nor a visibile origin...<br><br>\
				<span style='color: green;'>anytime</span>, \
				<span style='color: green;'>click</span>, \
				<span style='color: green;'>iseeyou</span>, \
				<span style='color: green;'>laugh1</span>, \
				<span style='color: green;'>laugh2</span>, \
				<span style='color: green;'>laugh3</span>, \
				me, \
				<span style='color: green;'>overhere</span>, \
				<span style='color: green;'>turnaround</span>, \
				<span style='color: green;'>roar</span></b><br>"


		// Pred emotes
		if ("anytime")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/voice/pred_anytime.ogg', 100, 0)
		if ("click")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				spawn(2)
					if(rand(0,100) < 50)
						playsound(src.loc, 'sound/voice/pred_click1.ogg', 100, 1)
					else
						playsound(src.loc, 'sound/voice/pred_click2.ogg', 100, 1)
		if ("iseeyou")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/hallucinations/i_see_you2.ogg', 100, 0)
		if ("laugh1")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/voice/pred_laugh1.ogg', 100, 0)
		if ("laugh2")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/voice/pred_laugh2.ogg', 100, 0)
		if ("laugh3")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/voice/pred_laugh3.ogg', 100, 0)
		if ("overhere")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/voice/pred_overhere.ogg', 100, 0)
		if ("roar")
			if(has_species(src,"Yautja") && src.loc)
				message = "<B>[src] roars!</b>"
				m_type = 1
				spawn(2)
					if(rand(0,100) < 50)
						playsound(src.loc, 'sound/voice/pred_roar1.ogg', 100, 1)
					else
						playsound(src.loc, 'sound/voice/pred_roar2.ogg', 100, 1)
		if ("turnaround")
			if(has_species(src,"Yautja") && src.loc)
				m_type = 1
				playsound(src.loc, 'sound/voice/pred_turnaround.ogg', 100, 0)
		else
			src << "\blue Unusable emote '[act]'. Say *help for a list of emotes."

	if (message)
		log_emote("[name]/[key] : [message]")

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in dead_mob_list)
			if(!M.client || istype(M, /mob/new_player))
				continue //skip monkeys, leavers and new players
			if(M.stat == DEAD && (M.client.prefs.toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
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
