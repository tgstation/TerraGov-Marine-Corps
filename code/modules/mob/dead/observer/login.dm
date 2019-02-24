/mob/dead/observer/Login()
	if(!client)
		return

	client.prefs.load_preferences()
	ghost_medhud = client.prefs.ghost_hud & GHOST_HUD_MED
	ghost_sechud = client.prefs.ghost_hud & GHOST_HUD_SEC
	ghost_squadhud = client.prefs.ghost_hud & GHOST_HUD_SQUAD
	ghost_xenohud = client.prefs.ghost_hud & GHOST_HUD_XENO
	var/datum/mob_hud/H
	if(ghost_medhud)
		H = huds[MOB_HUD_MEDICAL_OBSERVER]
		H.add_hud_to(src)
	if(ghost_sechud)
		H = huds[MOB_HUD_SECURITY_ADVANCED]
		H.add_hud_to(src)
	if(ghost_squadhud)
		H = huds[MOB_HUD_SQUAD]
		H.add_hud_to(src)
	if(ghost_xenohud)
		H = huds[MOB_HUD_XENO_STATUS]
		H.add_hud_to(src)

	return ..()