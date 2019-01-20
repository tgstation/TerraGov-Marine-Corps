/datum/admins/proc/show_traitor_panel(var/mob/M in mob_list)
	set category = "Admin"
	set desc = "Edit mobs's memory and role"
	set name = "Traitor Panel"

	if(!istype(M))
		to_chat(usr, "This can only be used on instances of type /mob")
		return
	if(!M.mind)
		to_chat(usr, "This mob has no mind!")
		return

	M.mind.edit_memory()
	feedback_add_details("admin_verb","STP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/is_special_character(mob/M as mob) // returns 1 for specail characters and 2 for heroes of gamemode
	if(!ticker || !ticker.mode)
		return 0
	if(!istype(M))
		return 0
	if(M.mind && M.mind.special_role)//If they have a mind and special role, they are some type of traitor or antagonist.
		return 1

	return 0

/client/proc/check_antagonists()
	set name = "Check Antagonists"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	if (ticker && ticker.current_state >= GAME_STATE_PLAYING)
		var/dat = "<html><head><title>Round Status</title></head><body><h1><B>Round Status</B></h1>"
		dat += "Current Game Mode: <B>[ticker.mode.name]</B><BR>"
		dat += "Round Duration: <B>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>"

		if(check_rights(R_DEBUG, FALSE))
			dat += "<br><A HREF='?_src_=vars;Vars=\ref[EvacuationAuthority]'>VV Evacuation Controller</A><br>"
			dat += "<A HREF='?_src_=vars;Vars=\ref[shuttle_controller]'>VV Shuttle Controller</A><br><br>"

		if(check_rights(R_ADMIN))
			dat += "<b>Evacuation:</b> "
			switch(EvacuationAuthority.evac_status)
				if(EVACUATION_STATUS_STANDING_BY) dat += 	"STANDING BY"
				if(EVACUATION_STATUS_INITIATING) dat += 	"IN PROGRESS: [EvacuationAuthority.get_status_panel_eta()]"
				if(EVACUATION_STATUS_COMPLETE) dat += 		"COMPLETE"
			dat += "<br>"

			dat += "<a href='?src=\ref[src];evac_authority=init_evac'>Initiate Evacuation</a><br>"
			dat += "<a href='?src=\ref[src];evac_authority=cancel_evac'>Cancel Evacuation</a><br>"
			dat += "<a href='?src=\ref[src];evac_authority=toggle_evac'>Toggle Evacuation Permission (does not affect evac in progress)</a><br>"
			if(check_rights(R_ADMIN, FALSE))
				dat += "<a href='?src=\ref[src];evac_authority=force_evac'>Force Evacuation Now</a><br>"

		if(check_rights(R_ADMIN, FALSE))
			dat += "<b>Self Destruct:</b> "
			switch(EvacuationAuthority.dest_status)
				if(NUKE_EXPLOSION_INACTIVE) dat += 		"INACTIVE"
				if(NUKE_EXPLOSION_ACTIVE) dat += 		"ACTIVE"
				if(NUKE_EXPLOSION_IN_PROGRESS) dat += 	"IN PROGRESS"
				if(NUKE_EXPLOSION_FINISHED) dat += 		"FINISHED"
			dat += "<br>"

			dat += "<a href='?src=\ref[src];evac_authority=init_dest'>Unlock Self Destruct control panel for humans</a><br>"
			dat += "<a href='?src=\ref[src];evac_authority=cancel_dest'>Lock Self Destruct control panel for humans</a><br>"
			dat += "<a href='?src=\ref[src];evac_authority=use_dest'>Destruct the [MAIN_SHIP_NAME] NOW</a><br>"
			dat += "<a href='?src=\ref[src];evac_authority=toggle_dest'>Toggle Self Destruct Permission (does not affect evac in progress)</a><br>"

		dat += "<br><a href='?src=\ref[src];delay_round_end=1'>[ticker.delay_end ? "End Round Normally" : "Delay Round End"]</a><br>"

		if(ticker.mode.xenomorphs.len)
			dat += "<br><table cellspacing=5><tr><td><B>Aliens</B></td><td></td><td></td></tr>"
			for(var/datum/mind/L in ticker.mode.xenomorphs)
				var/mob/M = L.current
				var/location = get_area(M.loc)
				if(M)
					dat += "<tr><td><A href='?src=\ref[usr];priv_msg=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td>[location]</td>"
					dat += "<td><a href='?src=\ref[usr];track=\ref[M]'>F</a></td>"
					dat += "<td><A href='?src=\ref[src];adminplayeropts=\ref[M]'>PP</A></td></TR>"
			dat += "</table>"

		if(ticker.liaison)
			dat += "<br><table cellspacing=5><tr><td><B>Corporate Liaison</B></td><td></td><td></td></tr>"
			var/mob/M = ticker.liaison.current
			var/location = get_area(M.loc)
			if(M)
				dat += "<tr><td><A href='?src=\ref[usr];priv_msg=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
				dat += "<td>[location]</td>"
				dat += "<td><a href='?src=\ref[usr];track=\ref[M]'>F</a></td>"
				dat += "<td><A href='?src=\ref[src];traitor=\ref[M]'>TP</A></td>"
				dat += "<td><A href='?src=\ref[src];adminplayeropts=\ref[M]'>PP</A></td></TR>"
			dat += "</table>"

		if(ticker.mode.survivors.len)
			dat += "<br><table cellspacing=5><tr><td><B>Survivors</B></td><td></td><td></td></tr>"
			for(var/datum/mind/L in ticker.mode.survivors)
				var/mob/M = L.current
				var/location = get_area(M.loc)
				if(M)
					dat += "<tr><td><A href='?src=\ref[usr];priv_msg=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td>[location]</td>"
					dat += "<td><a href='?src=\ref[usr];track=\ref[M]'>F</a></td>"
					dat += "<td><A href='?src=\ref[src];adminplayeropts=\ref[M]'>PP</A></td></TR>"
			dat += "</table>"

		if(ticker.mode.traitors.len)
			dat += check_role_table("Traitors", ticker.mode.traitors, src)

		dat += "</body></html>"
		usr << browse(dat, "window=roundstatus;size=600x500")
	else
		alert("The game hasn't started yet!")