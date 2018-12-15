/mob/living/carbon/human/emote(var/act, var/message = null, player_caused)
	var/param = null
	var/comm_paygrade = get_paygrade()

	if(findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
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
				M = A
				break

	if(!H || !istype(H))
		param = null

	if(act != "help") //you can always use the help emote
		if(stat == DEAD)
			return

	switch(act)
		if("me")
			if(player_caused && client)
				if(client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='warning'>You cannot send IC messages (muted).</span>")
					return
				if(client.handle_spam_prevention(message, MUTE_IC))
					return
			if(stat)
				return
			if(!(message))
				return
			return custom_emote("[message]", player_caused)

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
			if(!muzzled)
				message = "<B>[comm_paygrade][src]</B> chuckles."
			else
				message = "<B>[comm_paygrade][src]</B> makes a noise."

		if("clap")
			if(is_mob_restrained() || audio_emote_cooldown(player_caused))
				return
			message = "<B>[comm_paygrade][src]</B> claps."
			playsound(src.loc, 'sound/misc/clap.ogg', 25, 0)

		if("collapse")
			KnockOut(2)
			message = "<B>[comm_paygrade][src]</B> collapses!"

		if("cough")
			if(!muzzled)
				message = "<B>[comm_paygrade][src]</B> coughs!"
			else
				message = "<B>[comm_paygrade][src]</B> makes a strong noise."

		if("cry")
			message = "<B>[comm_paygrade][src]</B> cries."

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
			if(!muzzled)
				message = "<B>[comm_paygrade][src]</B> gasps!"
			else
				message = "<B>[comm_paygrade][src]</B> makes a weak noise."

		if("giggle")
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
			if(is_mob_restrained() || audio_emote_cooldown(player_caused))
				return
			message = "<B>[comm_paygrade][src]</B> claps, clearly unimpressed."
			playsound(src.loc, 'sound/misc/golfclap.ogg', 25, 0)

		if("grin")
			message = "<B>[comm_paygrade][src]</B> grins."

		if("grumble")
			if(!muzzled)
				message = "<B>[comm_paygrade][src]</B> grumbles."
			else
				message = "<B>[comm_paygrade][src]</B> makes a noise."

		if("handshake")
			if(!is_mob_restrained() && r_hand && param)
				if(M.canmove && M.r_hand && !M.is_mob_restrained())
					message = "<B>[comm_paygrade][src]</B> shakes hands with [H]."
				else
					message = "<B>[comm_paygrade][src]</B> holds out \his hand to [H]."

		if("hug")
			if(!is_mob_restrained())
				if(param)
					message = "<B>[comm_paygrade][src]</B> hugs [H]."
				else
					message = "<B>[comm_paygrade][src]</B> hugs \himself."

		if("laugh")
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
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			message = "<B>[comm_paygrade][src] calls for a medic!</b>"
			if(gender == "male")
				if(prob(95))
					playsound(src.loc, 'sound/voice/human_male_medic.ogg', 25, 0)
				else
					playsound(src.loc, 'sound/voice/human_male_medic2.ogg', 25, 0)
			else
				playsound(src.loc, 'sound/voice/human_female_medic.ogg', 25, 0)


		if("moan")
			message = "<B>[comm_paygrade][src]</B> moans."

		if("mumble")
			message = "<B>[comm_paygrade][src]</B> mumbles."

		if("nod")
			message = "<B>[comm_paygrade][src]</B> nods."

		if("pain")
			if (muzzled || audio_emote_cooldown(player_caused))
				return
			message = "<B>[comm_paygrade][src]</B> cries out in pain!"
			if(species)
				if(species.screams[gender])
					playsound(loc, species.screams[gender], 50)
				else if(species.screams[NEUTER])
					playsound(loc, species.screams[NEUTER], 50)

		if("salute")
			if(audio_emote_cooldown(player_caused) || buckled)
				return	
			if(param)
				message = "<B>[comm_paygrade][src]</B> salutes to [param]."
			else
				message = "<B>[comm_paygrade][src]</b> salutes."
			playsound(src.loc, 'sound/misc/salute.ogg', 20, 1)

		if("scream")
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			message = "<B>[comm_paygrade][src]</B> screams!"
			if(client && species)
				if(species.screams[gender])
					playsound(loc, species.screams[gender], 50)
				else if(species.screams[NEUTER])
					playsound(loc, species.screams[NEUTER], 50)

		if("shakehead")
			message = "<B>[comm_paygrade][src]</B> shakes \his head."

		if("shiver")
			message = "<B>[comm_paygrade][src]</B> shivers."

		if("shrug")
			message = "<B>[comm_paygrade][src]</B> shrugs."

		if("sigh")
			if(!muzzled)
				message = "<B>[comm_paygrade][src]</B> sighs."
			else
				message = "<B>[comm_paygrade][src]</B> makes a weak noise."

		if("signal")
			if(!is_mob_restrained())
				var/t1 = round(text2num(param))
				if(isnum(t1))
					if(t1 <= 5 && (!r_hand || !sl_hand))
						message = "<B>[comm_paygrade][src]</B> raises [t1] finger\s."
					else if(t1 <= 10 && (!r_hand && !l_hand))
						message = "<B>[comm_paygrade][src]</B> raises [t1] finger\s."

		if("smile")
			message = "<B>[comm_paygrade][src]</B> smiles."

		if("sneeze")
			message = "<B>[comm_paygrade][src]</B> sneezes!"

		if("snore")
			message = "<B>[comm_paygrade][src]</B> snores."

		if("stare")
			if(M)
				message = "<B>[comm_paygrade][src]</B> stares at [H]."
			else
				message = "<B>[comm_paygrade][src]</B> stares."

		if("twitch")
			message = "<B>[comm_paygrade][src]</B> twitches."

		if("wave")
			if(is_mob_restrained())
				return
			message = "<B>[comm_paygrade][src]</B> waves."

		if("yawn")
			if(muzzled)
				return
			message = "<B>[comm_paygrade][src]</B> yawns."

		if("help")
			var/msg = {"<br><br><b>To use an emote, type an asterix (*) before a following word. Emotes with a sound are <span style='color: green;'>green</span>. Spamming emotes with sound will likely get you banned. Don't do it.<br><br> \
			blink, blink_r, bow-(mob name), chuckle, <span style='color: green;'>clap</span>, collapse, cough, cry, drool, eyebrow, facepalm, 
			faint, frown, gasp, giggle, glare-(mob name), <span style='color: green;'>golfclap</span>, grin, grumble, handshake, hug-(mob name), 
			laugh, look-(mob name), me, <span style='color: green;'>medic</span>, moan, mumble, nod, point, <span style='color: green;'>salute</span>, 
			scream, shakehead, shiver, shrug, sigh, signal-#1-10, smile, sneeze, snore, stare-(mob name), twitch, wave, yawn</b><br>"}
			to_chat(src, msg)
			if(has_species(src,"Yautja"))
				var/yautja_msg = {"<br><b>As a Predator, you have the following additional emotes. Tip: The *medic emote has neither a cooldown nor a visibile origin...<br><br>\
				<span style='color: green;'>anytime</span>, <span style='color: green;'>click</span>, <span style='color: green;'>helpme</span>, 
				<span style='color: green;'>iseeyou</span>, <span style='color: green;'>itsatrap</span>, <span style='color: green;'>laugh1</span>, 
				<span style='color: green;'>laugh2</span>, <span style='color: green;'>laugh3</span>, <span style='color: green;'>malescream</span>, 
				<span style='color: green;'>femalescream</span>, me, <span style='color: green;'>overhere</span>, <span style='color: green;'>turnaround</span>, 
				<span style='color: green;'>roar</span></b><br>"}
				to_chat(src, yautja_msg)

		//Predator only emotes (why this isn't a separate override is beyond me.)
		if("anytime")
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			if(has_species(src, "Yautja"))
				playsound(loc, 'sound/voice/pred_anytime.ogg', 25, 0)
		if("click")
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			if(has_species(src, "Yautja"))
				spawn(2)
					if(rand(0,100) < 50)
						playsound(loc, 'sound/voice/pred_click1.ogg', 25, 1)
					else
						playsound(loc, 'sound/voice/pred_click2.ogg', 25, 1)
		if("helpme")
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			if(has_species(src, "Yautja"))
				playsound(loc, 'sound/voice/pred_helpme.ogg', 25, 0)
		if("malescream")
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			if(has_species(src, "Yautja"))
				playsound(loc, "male_scream", 50)
		if("femalescream")
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			if(has_species(src, "Yautja"))
				playsound(loc, "female_scream", 50)
		if("iseeyou")
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			if(has_species(src, "Yautja"))
				playsound(loc, 'sound/hallucinations/i_see_you2.ogg', 25, 0)
		if("itsatrap")
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			if(has_species(src, "Yautja"))
				playsound(loc, 'sound/voice/pred_itsatrap.ogg', 25, 0)
		if("laugh1")
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			if(has_species(src, "Yautja"))
				playsound(loc, 'sound/voice/pred_laugh1.ogg', 25, 0)
		if("laugh2")
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			if(has_species(src, "Yautja"))
				playsound(loc, 'sound/voice/pred_laugh2.ogg', 25, 0)
		if("laugh3")
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			if(has_species(src, "Yautja"))
				playsound(loc, 'sound/voice/pred_laugh3.ogg', 25, 0)
		if("overhere")
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			if(has_species(src, "Yautja"))
				playsound(loc, 'sound/voice/pred_overhere.ogg', 25, 0)
		if("roar")
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			if(has_species(src, "Yautja"))
				message = "<B>[src] roars!</b>"
				spawn(2)
					if(prob(50))
						playsound(loc, 'sound/voice/pred_roar1.ogg', 50, 1)
					else
						playsound(loc, 'sound/voice/pred_roar2.ogg', 50, 1)
		if("turnaround")
			if(muzzled || audio_emote_cooldown(player_caused))
				return
			if(has_species(src,"Yautja"))
				playsound(loc, 'sound/voice/pred_turnaround.ogg', 25, 0)
		else
			to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list of emotes.</span>")


	if(message)
		log_message(message, LOG_EMOTE)

		for(var/mob/M in dead_mob_list)
			if(!M.client || istype(M, /mob/new_player))
				continue
			if(M.stat == DEAD && M.client.prefs && (M.client.prefs.toggles_chat & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(message)

		for(var/mob/O in get_mobs_in_view(world.view, src))
			O.show_message(message, m_type)


/mob/living/carbon/human/proc/audio_emote_cooldown(player_caused)
	if(player_caused)
		if(recent_audio_emote)
			to_chat(usr, "<span class='notice'>You just did an audible emote. Wait a while.</span>")
			return TRUE
		start_audio_emote_cooldown()
	return FALSE


/mob/living/carbon/human/proc/start_audio_emote_cooldown()
	set waitfor = 0
	recent_audio_emote = TRUE
	sleep(50)
	recent_audio_emote = FALSE