/mob/dead/new_player/Login()
//	winset(client, "outputwindow.output", "max-lines=1")
//	winset(client, "outputwindow.output", "max-lines=100")

	if(CONFIG_GET(flag/use_exp_tracking))
		client.set_exp_from_db()
		client.set_db_player_flags()
	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	..()

	var/motd = global.config.motd
	if(motd)
		to_chat(src, "<div class=\"motd\">[motd]</div>", handle_whitespace=FALSE)

	if(GLOB.rogue_round_id)
		to_chat(src, "<span class='info'>ROUND ID: [GLOB.rogue_round_id]</span>")

	if(client)
		if(client.is_new_player())
			to_chat(src, "<span class='userdanger'>Due to an invasion of goblins trying to play ROGUETOWN, you need to register your discord account or support us on patreon to join.</span>")
			to_chat(src, "<span class='info'>We dislike discord too, but it's necessary. To register your discord or patreon, please click the 'Register' tab in the top right of the window, and then choose one of the options.</span>")
		else
			var/shown_patreon_level = client.patreonlevel()
			if(!shown_patreon_level)
				shown_patreon_level = "None"
			switch(shown_patreon_level)
				if(1)
					shown_patreon_level = "Silver"
				if(2)
					shown_patreon_level = "Gold"
				if(3)
					shown_patreon_level = "Mythril"
				if(4)
					shown_patreon_level = "Merchant"
				if(5)
					shown_patreon_level = "Lord"
			to_chat(src, "<span class='info'>Donator Level: [shown_patreon_level]</span>")

	if(CONFIG_GET(flag/usewhitelist))
		if(!client.whitelisted())
			to_chat(src, "<span class='info'>You are not on the whitelist.</span>")
		else
			to_chat(src, "<span class='info'>You are on the whitelist.</span>")

//	if(motd)
//		to_chat(src, "<B>If this is your first time here,</B> <a href='byond://?src=[REF(src)];rpprompt=1'>read this lore primer.</a>", handle_whitespace=FALSE)

	if(GLOB.admin_notice)
		to_chat(src, "<span class='notice'><b>Admin Notice:</b>\n \t [GLOB.admin_notice]</span>")

	var/spc = CONFIG_GET(number/soft_popcap)
	if(spc && living_player_count() >= spc)
		to_chat(src, "<span class='notice'><b>Server Notice:</b>\n \t [CONFIG_GET(string/soft_popcap_message)]</span>")

	sight |= SEE_TURFS

	new_player_panel()
	if(client)
		client.playtitlemusic()
	if(SSticker.current_state < GAME_STATE_SETTING_UP)
		var/tl = SSticker.GetTimeLeft()
		var/postfix
		if(tl > 0)
			postfix = "in about [DisplayTimeText(tl)]"
		else
			postfix = "soon"
		to_chat(src, "The game will start [postfix].")
		if(client)
			var/usedkey = ckey(key)
			if(usedkey in GLOB.anonymize)
				usedkey = get_fake_key(usedkey)
			var/list/thinz = list("takes a seat.", "settles in.", "joins the session", "joins the table.", "becomes a player.")
			SEND_TEXT(world, "<span class='notice'>[usedkey] [pick(thinz)]</span>")
/*
	if(!client.patreonlevel())
		verbs += /mob/dead/new_player/proc/register_patreon

	if(!client.discord_name())
		verbs += /mob/dead/new_player/proc/register_discord
*/
