//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
/mob/proc/update_Login_details()
	//Multikey checks and logging
	lastKnownIP	= client.address
	computer_id	= client.computer_id
	log_access("Login: [key_name(src)] from [lastKnownIP ? lastKnownIP : "localhost"]-[computer_id] || BYOND v[client.byond_version].[client.byond_build]")
	for(var/mob/M in GLOB.player_list)
		if(M == src)	continue
		if( M.key && (M.key != key) )
			var/matches
			if( (M.lastKnownIP == client.address) )
				matches += "IP ([client.address])"
			if( (client.connection != "web") && (M.computer_id == client.computer_id) )
				if(matches)	matches += " and "
				matches += "ID ([client.computer_id])"
				spawn() alert("You have logged in already with another key this round, please log out of this one NOW or risk being banned!")
			if(matches)
				if(M.client)
					log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)].")
					message_admins("[ADMIN_TPMONTY(src)] has the same [matches] as [ADMIN_TPMONTY(M)].")
				else
					log_access("[key_name(src)] has the same [matches] as [key_name(M)] (no longer logged in).")
					message_admins("[ADMIN_TPMONTY(src)] has the same [matches] as [ADMIN_TPMONTY(M)] (no longer logged in).")

/mob/Login()

	GLOB.player_list |= src
	update_Login_details()
	world.update_status()

	client.images = null
	client.screen = null				//remove hud items just in case
	if(!hud_used) create_hud()
	if(hud_used) hud_used.show_hud(hud_used.hud_version)

	log_message("[src] has logged in.", LOG_OOC)

	reload_fullscreens()

	next_move = 1
	sight |= SEE_SELF
	..()

	reset_view(loc)

	//updating atom HUD
	refresh_huds()