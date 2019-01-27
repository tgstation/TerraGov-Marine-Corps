/proc/is_special_character(mob/M as mob)
	if(!ticker?.mode)
		return FALSE
	if(!istype(M))
		return FALSE
	if(!M.mind?.special_role)
		return FALSE
	return TRUE


/datum/admins/proc/gamemode_panel()
	set category = "Admin"
	set name = "Gamemode Panel"

	if(!check_rights(R_ADMIN))
		return

	if(!ticker || !ticker.current_state > GAME_STATE_PLAYING)
		return

	var/dat
	var/ref = "[REF(usr.client.holder)];[HrefToken()]"

	dat += "<html><head><title>Round Status</title></head>"
	dat += "<body><h1><b>Round Status</b></h1>"
	dat += "Current Game Mode: <B>[ticker.mode?.name]</B><BR>"
	dat += "Round Duration: <B>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>"

	dat += "<b>Evacuation:</b> "
	switch(EvacuationAuthority.evac_status)
		if(EVACUATION_STATUS_STANDING_BY) 
			dat += "STANDING BY"
		if(EVACUATION_STATUS_INITIATING) 
			dat += "IN PROGRESS: [EvacuationAuthority.get_status_panel_eta()]"
		if(EVACUATION_STATUS_COMPLETE) 
			dat += "COMPLETE"
	dat += "<br>"

	dat += "<a href='?src=[ref];evac_authority=init_evac'>Initiate Evacuation</a><br>"
	dat += "<a href='?src=[ref];evac_authority=cancel_evac'>Cancel Evacuation</a><br>"
	dat += "<a href='?src=[ref];evac_authority=toggle_evac'>Toggle Evacuation Permission</a><br>"
	dat += "<a href='?src=[ref];evac_authority=force_evac'>Force Evacuation Now</a><br>"

	dat += "<b>Self Destruct:</b> "
	switch(EvacuationAuthority.dest_status)
		if(NUKE_EXPLOSION_INACTIVE)
			dat += "INACTIVE"
		if(NUKE_EXPLOSION_ACTIVE)
			dat += "ACTIVE"
		if(NUKE_EXPLOSION_IN_PROGRESS)
			dat += "IN PROGRESS"
		if(NUKE_EXPLOSION_FINISHED)
			dat += "FINISHED"
	dat += "<br>"

	dat += "<a href='?src=[ref];evac_authority=init_dest'>Unlock Self Destruct control panel for humans</a><br>"
	dat += "<a href='?src=[ref];evac_authority=cancel_dest'>Lock Self Destruct control panel for humans</a><br>"
	dat += "<a href='?src=[ref];evac_authority=use_dest'>Destruct the [MAIN_SHIP_NAME] NOW</a><br>"
	dat += "<a href='?src=[ref];evac_authority=toggle_dest'>Toggle Self Destruct Permission (does not affect evac in progress)</a><br>"

	if(ticker.mode.xenomorphs.len)
		dat += "<br><table cellspacing=5><tr><td><B>Aliens</B></td><td></td><td></td></tr>"
		for(var/datum/mind/L in ticker.mode.xenomorphs)
			var/mob/M = L.current
			var/location = get_area(M.loc)
			if(M)
				dat += "<tr><td><a href='?priv_msg=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
				dat += "<td>[location]</td>"
				dat += "<td><a href='?src=[ref];adminplayeropts=[REF(M)]'>PP</A></td></TR>"
		dat += "</table>"

	if(ticker.liaison)
		dat += "<br><table cellspacing=5><tr><td><B>Corporate Liaison</B></td><td></td><td></td></tr>"
		var/mob/M = ticker.liaison.current
		var/location = get_area(M.loc)
		if(M)
			dat += "<tr><td><a href='?priv_msg=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
			dat += "<td>[location]</td>"
			dat += "<td><a href='?src=[ref];adminplayeropts=[REF(M)]'>PP</A></td></TR>"
		dat += "</table>"

	if(ticker.mode.survivors.len)
		dat += "<br><table cellspacing=5><tr><td><B>Survivors</B></td><td></td><td></td></tr>"
		for(var/datum/mind/L in ticker.mode.survivors)
			var/mob/M = L.current
			var/location = get_area(M.loc)
			if(M)
				dat += "<tr><td><a href='?priv_msg=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
				dat += "<td>[location]</td>"
				dat += "<td><a href='?src=[ref];adminplayeropts=[REF(M)]'>PP</A></td></TR>"
		dat += "</table>"

	dat += "</body></html>"
	usr << browse(dat, "window=roundstatus;size=600x500")