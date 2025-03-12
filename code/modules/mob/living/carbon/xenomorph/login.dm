/mob/living/carbon/xenomorph/Login()
	. = ..()

	if(client.prefs?.xeno_name != "Undefined" && !is_banned_from(ckey, "Appearance"))
		nicknumber = client.prefs.xeno_name
	else
		//Reset the nicknumber, otherwise we could keep the old minds custom name/random number
		nicknumber = 0
		generate_nicknumber()

	hud_update_rank()
	generate_name()
