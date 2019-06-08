/mob/dead/observer/Login()
	. = ..()

	client.prefs.load_preferences()
	ghost_medhud = client.prefs.ghost_hud & GHOST_HUD_MED
	ghost_sechud = client.prefs.ghost_hud & GHOST_HUD_SEC
	ghost_squadhud = client.prefs.ghost_hud & GHOST_HUD_SQUAD
	ghost_xenohud = client.prefs.ghost_hud & GHOST_HUD_XENO
	ghost_orderhud = client.prefs.ghost_hud & GHOST_HUD_ORDER	
	var/datum/atom_hud/H
	if(ghost_medhud)
		H = GLOB.huds[DATA_HUD_MEDICAL_OBSERVER]
		H.add_hud_to(src)
	if(ghost_sechud)
		H = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
		H.add_hud_to(src)
	if(ghost_squadhud)
		H = GLOB.huds[DATA_HUD_SQUAD]
		H.add_hud_to(src)
	if(ghost_xenohud)
		H = GLOB.huds[DATA_HUD_XENO_STATUS]
		H.add_hud_to(src)
	if(ghost_orderhud)
		H = GLOB.huds[DATA_HUD_ORDER]
		H.add_hud_to(src)		

	GLOB.observer_list += src
	
	ghost_others = client.prefs.ghost_others

	update_icon(client.prefs.ghost_form)
	updateghostimages()
	
	if(length(GLOB.offered_mob_list))
		to_chat(src, "<span class='boldnotice'>There's mobs available for taking! Ghost > Take Offered Mob</span>")