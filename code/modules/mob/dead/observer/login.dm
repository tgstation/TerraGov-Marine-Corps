/mob/dead/observer/Login()
	ghost_medhud = client.prefs.ghost_medhud
	ghost_sechud = client.prefs.ghost_sechud
	ghost_squadhud = client.prefs.ghost_squadhud
	ghost_xenohud = client.prefs.ghost_xenohud
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