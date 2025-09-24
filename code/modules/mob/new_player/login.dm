/mob/new_player/Login()
	if(GLOB.motd)
		to_chat(src, "<div class='motd'>[GLOB.motd]</div>")

	var/datum/getrev/revdata = GLOB.revdata
	var/tm_info = revdata.GetTestMergeInfo()
	if(tm_info)
		to_chat(src, tm_info)

	if(CONFIG_GET(flag/use_exp_tracking))
		client?.set_exp_from_db()

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = TRUE
		mind.current = src

	. = ..()

	ooc_notes = client.prefs.metadata
	ooc_notes_likes = client.prefs.metadata_likes
	ooc_notes_dislikes = client.prefs.metadata_dislikes
	ooc_notes_maybes = client.prefs.metadata_maybes
	ooc_notes_favs = client.prefs.metadata_favs
	ooc_notes_style = client.prefs.metadata_ooc_style

	sight |= SEE_TURFS

	client?.play_title_music()

	name = "[key](In Lobby)"
