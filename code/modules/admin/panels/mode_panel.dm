/datum/admins/proc/gamemode_panel()
	set category = "Admin"
	set name = "Mode Panel"

	if(!check_rights(R_ADMIN))
		return

	if(!SSticker?.mode || !EvacuationAuthority)
		return

	var/dat
	var/ref = "[REF(usr.client.holder)];[HrefToken()]"

	dat += "<html><head><title>Round Status</title></head>"
	dat += "<body><h1><b>Round Status</b></h1>"
	dat += "Current Game Mode: <B>[SSticker.mode.name]</B><BR>"
	dat += "Round Duration: <B>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>"

	var/countdown = SSticker.mode.get_queen_countdown()
	if(countdown)
		dat += "Queen Re-Check: [countdown]"

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

	dat += "<br>"

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

	dat += "<br>"

	dat += "<A HREF='?_src_=vars;[HrefToken()];vars=[REF(EvacuationAuthority)]'>VV Evacuation/SD Controller</A><br>"
	dat += "<A HREF='?_src_=vars;[HrefToken()];vars=[REF(GLOB.faxes)]'>VV Faxes List</A><br>"
	dat += "<A HREF='?_src_=vars;[HrefToken()];vars=[REF(GLOB.custom_outfits)]'>VV Outfit List</A><br>"

	dat += "<br><br>"

	if(length(SSticker.mode.xenomorphs))
		dat += "<table cellspacing=5><tr><td><B>Aliens</B></td><td></td><td></td></tr>"
		for(var/datum/mind/L in SSticker.mode.xenomorphs)
			var/mob/M = L.current
			var/location = ""
			if(M)
				location = get_area(M.loc)
				dat += "<tr><td><a href='?priv_msg=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][(M.client?.prefs?.xeno_name && M.client.prefs.xeno_name != "Undefined") ? " - [M.client.prefs.xeno_name]" : ""][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
				dat += "<td>[location]</td>"
				dat += "<td><a href='?src=[ref];playerpanel=[REF(M)]'>PP</A></td></TR>"
		dat += "</table>"

	if(SSticker.liaison)
		dat += "<br><table cellspacing=5><tr><td><B>Corporate Liaison</B></td><td></td><td></td></tr>"
		var/mob/M = SSticker.liaison.current
		var/location = ""
		if(M)
			location = get_area(M.loc)
			dat += "<tr><td><a href='?priv_msg=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
			dat += "<td>[location]</td>"
			dat += "<td><a href='?src=[ref];playerpanel=[REF(M)]'>PP</A></td></TR>"
		dat += "</table>"

	if(length(SSticker.mode.survivors))
		dat += "<br><table cellspacing=5><tr><td><B>Survivors</B></td><td></td><td></td></tr>"
		for(var/datum/mind/L in SSticker.mode.survivors)
			var/mob/M = L.current
			var/location = ""
			if(M)
				location = get_area(M.loc)
				dat += "<tr><td><a href='?priv_msg=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
				dat += "<td>[location]</td>"
				dat += "<td><a href='?src=[ref];playerpanel=[REF(M)]'>PP</A></td></TR>"
		dat += "</table>"

	dat += "</body></html>"

	log_admin("[key_name(usr)] opened the mode panel.")

	usr << browse(dat, "window=roundstatus;size=600x500")