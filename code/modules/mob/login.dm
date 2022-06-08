/mob/Login()
	if(!client) //Yes, this can happen. Thanks BYOND.
		return
	ip_address	= client.address
	computer_id	= client.computer_id
	GLOB.player_list |= src
	log_message("[src] has logged in.", LOG_OOC)
	world.update_status()
	client.images = list()
	client.screen = list()				//remove hud items just in case

	if(!hud_used)
		create_mob_hud()
	if(hud_used)
		hud_used.show_hud(hud_used.hud_version)

	next_move = 1
	sight |= SEE_SELF

	. = ..()

	reload_huds()

	reload_fullscreens()

	reset_perspective(loc)

	add_click_catcher()

	if(client)
		if(client.view_size)
			client.view_size.reset_to_default() // Resets the client.view in case it was changed.
		else
			client.change_view(get_screen_size(client.prefs.widescreenpref))

		if(client.player_details)
			for(var/foo in client.player_details.post_login_callbacks)
				var/datum/callback/CB = foo
				CB.Invoke()
			log_played_names(client.ckey, name, real_name)
		if(SSvote.vote_happening && !actions_by_path[/datum/action/innate/vote])
			var/datum/action/innate/vote/vote = new
			if(SSvote.question)
				vote.name = "Vote: [SSvote.question]"
			vote.give_action(src)

	update_movespeed()
	log_mob_tag("\[[tag]\] NEW OWNER: [key_name(src)]")
	SEND_SIGNAL(src, COMSIG_MOB_LOGIN)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_LOGIN, src)
