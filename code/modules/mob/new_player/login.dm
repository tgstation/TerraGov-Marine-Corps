/mob/new_player/Login()
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
	if(GLOB.motd)
		to_chat(src, "<div class='motd'>[GLOB.motd]</div>")

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = TRUE
		mind.current = src

	if(length(GLOB.newplayer_start))
		loc = pick(GLOB.newplayer_start)
	else
		loc = locate(1,1,1)
	lastarea = get_area(src.loc)

	sight |= SEE_TURFS
	GLOB.player_list |= src

	new_player_panel()

	if(CONFIG_GET(flag/use_exp_tracking))
		client.set_exp_from_db()

	spawn(40)
		if(client)
			client.playtitlemusic()
			version_check()