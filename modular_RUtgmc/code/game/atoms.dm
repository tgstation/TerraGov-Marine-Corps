
/atom/prepare_huds()
	hud_list = new
	for(var/hud in hud_possible) //Providing huds.
		var/image/new_hud = image('modular_RUtgmc/icons/mob/hud.dmi', src, "")
		new_hud.appearance_flags = KEEP_APART
		hud_list[hud] = new_hud
