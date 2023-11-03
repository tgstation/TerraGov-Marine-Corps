/mob/Login()
	if(!client) //Yes, this can happen. Thanks BYOND.
		return
	ip_address = client.address
	computer_id = client.computer_id
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

	// DO NOT CALL PARENT HERE
	// BYOND's internal implementation of login does two things
	// 1: Set statobj to the mob being logged into (We got this covered)
	// 2: And I quote "If the mob has no location, place it near (1,1,1) if possible"
	// See, near is doing an agressive amount of legwork there
	// What it actually does is takes the area that (1,1,1) is in, and loops through all those turfs
	// If you successfully move into one, it stops
	// Because we want Move() to mean standard movements rather then just what byond treats it as (ALL moves)
	// We don't allow moves from nullspace -> somewhere. This means the loop has to iterate all the turfs in (1,1,1)'s area
	// For us, (1,1,1) is a space tile. This means roughly 200,000! calls to Move()
	// You do not want this

	if(!client)
		return

	canon_client = client
	clear_important_client_contents(client)
	enable_client_mobs_in_contents(client)

	if(key != client.key)
		key = client.key
	reset_perspective(loc)

	reload_huds()
	reload_fullscreens()

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
	SEND_SIGNAL(client, COMSIG_CLIENT_MOB_LOGIN)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_LOGIN, src)
	client.init_verbs()
