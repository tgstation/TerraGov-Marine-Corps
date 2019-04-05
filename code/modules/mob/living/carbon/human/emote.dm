/mob/living/carbon/human/emote(act, m_type = EMOTE_VISIBLE, message, player_caused)
	var/param
	var/comm_paygrade = get_paygrade()

	if(findtext(act, "-"))
		var/t1 = findtext(act, "-")
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act, "s", -1) && !findtext(act, "_", -2)) //Removes ending s's unless they are prefixed with a '_'
		act = copytext(act, 1, length(act))

	var/muzzled = istype(wear_mask, /obj/item/clothing/mask/muzzle)

	for(var/obj/item/implant/I in src)
		if(I.implanted)
			I.trigger(act, src)

	var/mob/living/carbon/human/H
	if(param)
		for(var/mob/living/carbon/A in view(null, null))
			if(findtext(param, A.name) != 0)
				H = A
				break

	if(act != "help") //you can always use the help emote
		if(stat == DEAD)
			return

	switch(act)
		if("me")
			if(stat || !message)
				return
			if(player_caused && client)
				if(client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='warning'>You cannot send IC messages (muted).</span>")
					return
				if(client.handle_spam_prevention(message, MUTE_IC))
					return
				if(is_banned_from(ckey, "Emote"))
					to_chat(src, "<span class='warning'>You cannot send emotes (banned).</span>")
					return
			return custom_emote(m_type, "[message]", player_caused)

		if("blink")
			message = "<B>[comm_paygrade][src]</B> blinks."

		if("blink_r")
			message = "<B>[comm_paygrade][src]</B> blinks rapidly."

		if("bow")
			if(!buckled)
				if(param)
					message = "<B>[comm_paygrade][src]</B> bows to [param]."
				else
					message = "<B>[comm_paygrade][src]</B> bows."

		if("chuckle")
			m_type = EMOTE_AUDIBLE
			if(!muzzled)
				message = "<B>[comm_paygrade][src]</B> chuckles."
			else
				message = "<B>[comm_paygrade][src]</B> makes a noise."

		if("clap")
			m_type = EMOTE_AUDIBLE
			if(restrained() || audio_emote_cooldown(player_caused))
				return
			message = "<B>[comm_paygrade][src]</B> claps."
			playsound(src.loc, 'sound/misc/clap.ogg', 25, 0)

		if("collapse")
			KnockOut(2)
			message = "<B>[comm_paygrade][src]</B> collapses!"

		if("cough")
			m_type = EMOTE_AUDIBLE
			if(!muzzled)
				message = "<B>[comm_paygrade][src]</B> coughs!"
			else
				message = "<B>[comm_paygrade][src]</B> makes a strong noise."

		if("cry")
			message = "<B>[comm_paygrade][src]</B> cries."

		if("dab")
			if(!CONFIG_GET(flag/fun_allowed)) //fun_allowed is in the config folder. change it in game by Debug>debug controllers> ctrl+f fun_allowed.
				return
			if(incapacitated())
				to_chat(src, "You cannot dab in your current state.")
				return
			var/datum/limb/l_arm/A = get_limb("l_arm")
			var/datum/limb/r_arm/B = get_limb("r_arm")
			if((!A || A.limb_status & LIMB_DESTROYED) && (!B || B.limb_status & LIMB_DESTROYED))
				to_chat(src, "You cannot dab without your arms.")
				return

			message = "<B>[comm_paygrade][src]</B> dabs"
			var/risk = rand (1, 100)
			switch(risk)
				if(1 to 3)
					if(A || A.limb_status && !LIMB_DESTROYED)
						A.droplimb()
						message += " so hard their left arm goes flying off"
				if(4 to 6)
					if(B || B.limb_status && !LIMB_DESTROYED)
						B.droplimb()
						message += " so hard their right arm goes flying off"
			message += "."

		if("drool")
			message = "<B>[comm_paygrade][src]</B> drools."

		if("eyebrow")
			message = "<B>[comm_paygrade][src]</B> raises an eyebrow."

		if("facepalm")
			message = "<B>[comm_paygrade][src]</B> facepalms."

		if("faint")
			message = "<B>[comm_paygrade][src]</B> faints!"
			if(sleeping)
				return
			sleeping += 10

		if("frown")
			message = "<B>[comm_paygrade][src]</B> frowns."

		if("gasp")
			m_type = EMOTE_AUDIBLE
			if(!muzzled)
				message = "<B>[comm_paygrade][src]</B> gasps!"
			else
				message = "<B>[comm_paygrade][src]</B> makes a weak noise."

		if("giggle")
			m_type = EMOTE_AUDIBLE
			if(!muzzled)
				message = "<B>[comm_paygrade][src]</B> giggles."
			else
				message = "<B>[comm_paygrade][src]</B> makes a noise."

		if("glare")
			if(param)
				message = "<B>[comm_paygrade][src]</B> glares at [param]."
			else
				message = "<B>[comm_paygrade][src]</B> glares."

		if("golfclap")
			m_type = EMOTE_AUDIBLE
			if(restrained() || audio_emote_cooldown(player_caused))
				return
			message = "<B>[comm_paygrade][src]</B> claps, clearly unimpressed."
			playsound(src.loc, 'sound/misc/golfclap.ogg', 25, 0)

		if("grin")
			message = "<B>[comm_paygrade][src]</B> grins."

		if("grumble")
			m_type = EMOTE_AUDIBLE
			if(!muzzled)
				message = "<B>[comm_paygrade][src]</B> grumbles."
			else
				message = "<B>[comm_paygrade][src]</B> makes a noise."

		if("handshake")
			if(!restrained() && !(r_hand && l_hand) && param)
				if(H.canmove && H.r_hand && !H.restrained())
					message = "<B>[comm_paygrade][src]</B> shakes hands with [H]."
				else
					message = "<B>[comm_paygrade][src]</B> holds out [p_their()] hand to [H]."

		if("hug")
			if(!restrained())
				if(param)
					message = "<B>[comm_paygrade][src]</B> hugs [H]."
				else
					message = "<B>[comm_paygrade][src]</B> hugs [p_them()]self."

		if("laugh")
			m_type = EMOTE_AUDIBLE
			if(!muzzled)
				message = "<B>[comm_paygrade][src]</B> laughs!"
			else
				message = "<B>[comm_paygrade][src]</B> makes a noise."

		if("look")
			if(param)
				message = "<B>[comm_paygrade][src]</B> looks at [param]."
			else
				message = "<B>[comm_paygrade][src]</B> looks."

		if("medic")
			m_type = EMOTE_AUDIBLE
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			message = "<B>[comm_paygrade][src] calls for a medic!</b>"
			var/image/medic = image('icons/mob/talk.dmi', src, icon_state = "medic")
			add_emote_overlay(medic)
			if(gender == "male")
				if(prob(95))
					playsound(loc, 'sound/voice/human_male_medic.ogg', 25, 0)
				else
					playsound(loc, 'sound/voice/human_male_medic2.ogg', 25, 0)
			else
				playsound(loc, 'sound/voice/human_female_medic.ogg', 25, 0)

		if("moan")
			m_type = EMOTE_AUDIBLE
			message = "<B>[comm_paygrade][src]</B> moans."

		if("mumble")
			m_type = EMOTE_AUDIBLE
			message = "<B>[comm_paygrade][src]</B> mumbles."

		if("nod")
			message = "<B>[comm_paygrade][src]</B> nods."

		if("pain")
			m_type = EMOTE_AUDIBLE
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			var/image/pain = image('icons/mob/talk.dmi', src, icon_state = "pain")
			add_emote_overlay(pain)
			message = "<B>[comm_paygrade][src]</B> cries out in pain!"
			if(species)
				if(species.paincries[gender])
					playsound(loc, species.paincries[gender], 50)
				else if(species.screams[NEUTER])
					playsound(loc, species.paincries[NEUTER], 50)

		if("salute")
			m_type = EMOTE_AUDIBLE
			if(audio_emote_cooldown(player_caused) || buckled)
				return
			if(param)
				message = "<B>[comm_paygrade][src]</B> salutes to [param]."
			else
				message = "<B>[comm_paygrade][src]</b> salutes."
			playsound(src.loc, 'sound/misc/salute.ogg', 20, 1)

		if("scream")
			m_type = EMOTE_AUDIBLE
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			message = "<B>[comm_paygrade][src]</B> screams!"
			var/image/scream = image('icons/mob/talk.dmi', src, icon_state = "scream")
			add_emote_overlay(scream)
			if(client && species)
				if(species.screams[gender])
					playsound(loc, species.screams[gender], 50)
				else if(species.screams[NEUTER])
					playsound(loc, species.screams[NEUTER], 50)

		if("shakehead")
			message = "<B>[comm_paygrade][src]</B> shakes [p_their()] head."

		if("shiver")
			message = "<B>[comm_paygrade][src]</B> shivers."

		if("shrug")
			message = "<B>[comm_paygrade][src]</B> shrugs."

		if("sigh")
			m_type = EMOTE_AUDIBLE
			if(!muzzled)
				message = "<B>[comm_paygrade][src]</B> sighs."
			else
				message = "<B>[comm_paygrade][src]</B> makes a weak noise."

		if("signal")
			if(restrained())
				return
			var/t1 = round(text2num(param))
			if(isnum(t1))
				if(t1 <= 5 && (!r_hand || !l_hand))
					message = "<B>[comm_paygrade][src]</B> raises [t1] finger\s."
				else if(t1 <= 10 && (!r_hand && !l_hand))
					message = "<B>[comm_paygrade][src]</B> raises [t1] finger\s."

		if("smile")
			message = "<B>[comm_paygrade][src]</B> smiles."

		if("sneeze")
			m_type = EMOTE_AUDIBLE
			message = "<B>[comm_paygrade][src]</B> sneezes!"

		if("snore")
			m_type = EMOTE_AUDIBLE
			message = "<B>[comm_paygrade][src]</B> snores."

		if("stare")
			if(param)
				message = "<B>[comm_paygrade][src]</B> stares at [H]."
			else
				message = "<B>[comm_paygrade][src]</B> stares."

		if("twitch")
			message = "<B>[comm_paygrade][src]</B> twitches."

		if("wave")
			if(restrained())
				return
			message = "<B>[comm_paygrade][src]</B> waves."

		if("yawn")
			m_type = EMOTE_AUDIBLE
			if(muzzled)
				return
			message = "<B>[comm_paygrade][src]</B> yawns."

		if("help")
			//this is the default *help message
			var/msg = {"<br><br><b>To use an emote, type an asterix (*) before a following word. Emotes with a sound are <span style='color: green;'>green</span>. Spamming emotes with sound will likely get you in trouble, don't do it.<br><br> \
blink, blink_r, bow-(mob name), chuckle, <span style='color: green;'>clap</span>, collapse, cough, cry, drool, eyebrow, facepalm,
faint, frown, gasp, giggle, glare-(mob name), <span style='color: green;'>golfclap</span>, grin, grumble, handshake, hug-(mob name),
laugh, look-(mob name), me, <span style='color: green;'>medic</span>, moan, mumble, nod, point, <span style='color: green;'>salute</span>,
<span style='color: green;'>scream</span>, shakehead, shiver, shrug, sigh, signal-#1-10, smile, sneeze, snore, stare-(mob name), twitch, wave, yawn</b><br>"}
			
			if(CONFIG_GET(flag/fun_allowed)) //this is the *help message when fun_allowed = 1.
				msg = {"<br><br><b>To use an emote, type an asterix (*) before a following word. Emotes with a sound are <span style='color: green;'>green</span>. Emotes that are <span style='color: red;'>RED</span> are done at your own risk. Spamming emotes with sound will likely get you in trouble, don't do it.<br><br> \
blink, blink_r, bow-(mob name), chuckle, <span style='color: green;'>clap</span>, collapse, cough, cry, <span style='color: red;'>dab</span>, drool, eyebrow, facepalm, 
faint, frown, gasp, giggle, glare-(mob name), <span style='color: green;'>golfclap</span>, grin, grumble, handshake, hug-(mob name), 
laugh, look-(mob name), me, <span style='color: green;'>medic</span>, moan, mumble, nod, point, <span style='color: green;'>salute</span>, 
<span style='color: green;'>scream</span>, shakehead, shiver, shrug, sigh, signal-#1-10, smile, sneeze, snore, stare-(mob name), twitch, wave, yawn</b><br>"}
		
			to_chat(src, msg)


	if(message)
		log_message(message, LOG_EMOTE)

		for(var/mob/M in GLOB.dead_mob_list)
			if(!M.client || isnewplayer(M))
				continue
			if(M.stat == DEAD && M.client.prefs && (M.client.prefs.toggles_chat & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(message, m_type)

		if(m_type == EMOTE_VISIBLE)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if(m_type == EMOTE_AUDIBLE)
			for(var/mob/O in hearers(loc, null))
				O.show_message(message, m_type)