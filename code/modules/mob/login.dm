/mob/Login()
	GLOB.player_list |= src
	lastKnownIP	= client.address
	computer_id	= client.computer_id
	log_message("[src] has logged in.", LOG_OOC)
	world.update_status()
	client.images = list()
	client.screen = list()				//remove hud items just in case

	if(!hud_used) 
		create_hud()
	if(hud_used) 
		hud_used.show_hud(hud_used.hud_version)

	reload_fullscreens()

	next_move = 1
	sight |= SEE_SELF
	. = ..()

	reset_view(loc)

	add_click_catcher()
	refresh_huds()

	if(client?.player_details)
		for(var/foo in client.player_details.post_login_callbacks)
			var/datum/callback/CB = foo
			CB.Invoke()
		log_played_names(client.ckey, name, real_name)