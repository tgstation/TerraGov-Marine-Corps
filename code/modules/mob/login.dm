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
		client.change_view(WORLD_VIEW)
		client.pixel_x = 0
		client.pixel_y = 0

		if(client.player_details)
			for(var/foo in client.player_details.post_login_callbacks)
				var/datum/callback/CB = foo
				CB.Invoke()
			log_played_names(client.ckey, name, real_name)

	update_movespeed()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_LOGIN, src)
