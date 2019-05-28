/mob/new_player/Login()
	if(GLOB.motd)
		to_chat(src, "<div class='motd'>[GLOB.motd]</div>")

	if(CONFIG_GET(flag/use_exp_tracking))
		client.set_exp_from_db()

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = TRUE
		mind.current = src

	. = ..()

	sight |= SEE_TURFS

	new_player_panel()
	client.playtitlemusic()