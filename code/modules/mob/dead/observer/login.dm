/mob/dead/observer/Login()
	. = ..()
	SSmobs.dead_players_by_zlevel[z] += src
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(observer_z_changed))

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
		H = GLOB.huds[DATA_HUD_SQUAD_SOM]
		H.add_hud_to(src)
	if(ghost_xenohud)
		H = GLOB.huds[DATA_HUD_XENO_STATUS]
		H.add_hud_to(src)
	if(ghost_orderhud)
		H = GLOB.huds[DATA_HUD_ORDER]
		H.add_hud_to(src)

	GLOB.observer_list |= src

	ghost_others = client.prefs.ghost_others
	ghost_orbit = client.prefs.ghost_orbit

	pick_form(client.prefs.ghost_form)
	updateghostimages()

	for(var/path in subtypesof(/datum/action/observer_action))
		if(!actions_by_path[path])
			var/datum/action/observer_action/A = new path(src)
			A.give_action(src)
	if(!SSticker.mode)
		RegisterSignal(SSdcs, COMSIG_GLOB_GAMEMODE_LOADED, PROC_REF(load_ghost_gamemode_actions))
	else
		load_ghost_gamemode_actions()

	client.AddComponent(/datum/component/larva_queue)

	if(!actions_by_path[/datum/action/minimap/observer])
		var/datum/action/minimap/observer/mini = new(src)
		mini.give_action(src)

	if(length(GLOB.offered_mob_list))
		to_chat(src, span_boldnotice("There's mobs available for taking! Ghost > Take Offered Mob"))

///Warn the ghost and send them into their body after a few seconds
/mob/dead/observer/proc/revived_while_away()
	SIGNAL_HANDLER
	to_chat(src, assemble_alert(
		title = "Revived",
		subtitle = "You were revived while disconnected.",
		message = "Someone resuscitated you while you were disconnected. [isnull(can_reenter_corpse) ? "You're currently unable to re-enter your body." : "You will re-enter your body in a few seconds."]",
		color_override = "red"
	))
	if(!isnull(can_reenter_corpse))
		addtimer(CALLBACK(src, TYPE_VERB_REF(/mob/dead/observer, reenter_corpse)), 6 SECONDS)

///Loads any gamemode specific ghost actions
/mob/dead/observer/proc/load_ghost_gamemode_actions()
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, COMSIG_GLOB_GAMEMODE_LOADED)
	for(var/path in SSticker.mode.ghost_verbs())
		if(!actions_by_path[path])
			var/datum/action/action = new path(src)
			action.give_action(src)
