/mob/new_player/Login()
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
	if(join_motd)
		src << "<div class=\"motd\">[join_motd]</div>"

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	if(length(newplayer_start))
		loc = pick(newplayer_start)
	else
		loc = locate(1,1,1)
	lastarea = get_area(src.loc)

	sight |= SEE_TURFS
	player_list |= src

	new_player_panel()

	spawn(40)
		if(client)
			// handle_privacy_poll() //This is in poll.dm and could be used to run polls for all first-time logins. It won't reappear after they vote.
			client.playtitlemusic()
			version_check()