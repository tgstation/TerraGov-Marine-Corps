/mob/Login()
	GLOB.player_list |= src
	ip_address	= client.address
	computer_id	= client.computer_id
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

	reset_view(loc)

	add_click_catcher()

	if(client?.player_details)
		for(var/foo in client.player_details.post_login_callbacks)
			var/datum/callback/CB = foo
			CB.Invoke()
		log_played_names(client.ckey, name, real_name)