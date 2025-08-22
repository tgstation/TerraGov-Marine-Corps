/mob/living/carbon/xenomorph/Login()
	. = ..()

	if(client.prefs?.xeno_name != "Undefined" && !is_banned_from(ckey, "Appearance"))
		nicknumber = client.prefs.xeno_name
	else
		//Reset the nicknumber, otherwise we could keep the old minds custom name/random number
		nicknumber = 0
		generate_nicknumber()

	if(client.prefs)
		xeno_desc = client.prefs.xeno_desc
		xenoprofile_pic = client.prefs.xenoprofile_pic
		xenogender = client.prefs.xenogender
		ooc_notes = client.prefs.metadata
		ooc_notes_likes = client.prefs.metadata_likes
		ooc_notes_dislikes = client.prefs.metadata_dislikes
		ooc_notes_maybes = client.prefs.metadata_maybes
		ooc_notes_favs = client.prefs.metadata_favs
		ooc_notes_style = client.prefs.metadata_ooc_style
	update_xeno_gender()

	hud_update_rank()
	generate_name()
