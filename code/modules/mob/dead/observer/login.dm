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
		H = GLOB.huds[DATA_HUD_SQUAD_TERRAGOV]
		H.add_hud_to(src)
		H = GLOB.huds[DATA_HUD_SQUAD_REBEL]
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

	if(!length(actions))
		for(var/path in subtypesof(/datum/action/observer_action))
			var/datum/action/observer_action/A = new path()
			A.give_action(src)
		var/datum/action/toggle_rightclick/rclick = new
		rclick.give_action(src)
		var/datum/action/minimap/observer/mini = new
		mini.give_action(src)

	if(length(GLOB.offered_mob_list))
		to_chat(src, span_boldnotice("There's mobs available for taking! Ghost > Take Offered Mob"))
