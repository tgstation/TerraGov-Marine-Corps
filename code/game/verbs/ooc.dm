/client/verb/ooc(msg as text)
	set name = "OOC"
	set category = "OOC"

	if(!mob)
		return
	if(IsGuestKey(key))
		to_chat(src, "Guests may not use OOC.")
		return

	if(!check_rights(R_ADMIN, FALSE))
		msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
	else
		msg = noscript(msg)

	if(!msg)
		return

	if(!(prefs.toggles_chat & CHAT_OOC))
		to_chat(src, "<span class='warning'>You have OOC muted.</span>")
		return

	if(!check_rights(R_ADMIN, FALSE))
		if(!GLOB.ooc_allowed)
			to_chat(src, "<span class='warning'>OOC is globally muted</span>")
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='warning'>OOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='warning'>You cannot use OOC (muted).</span>")
			return
		if(handle_spam_prevention(msg, MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<span class='danger'>Advertising other servers is not allowed.</span>")
			log_admin_private("[key_name(usr)] has attempted to advertise in OOC: [msg]")
			message_admins("[ADMIN_TPMONTY(usr)] has attempted to advertise in OOC: [msg]")
			return

	if(is_banned_from(ckey, "OOC"))
		to_chat(src, "<span class='warning'>You have been banned from OOC.</span>")
		return

	mob.log_talk(msg, LOG_OOC)

	var/display_colour = "#002eb8"
	if(holder?.rank && !holder.fakekey)
		switch(holder.rank.name)
			if("Host")
				display_colour = "#000000"	//black
			if("Project Lead")
				display_colour = "#800080"	//dark purple
			if("Headcoder")
				display_colour = "#800080"	//dark blue
			if("Headmin")
				display_colour = "#640000"	//dark red
			if("Headmentor")
				display_colour = "#004100"	//dark green
			if("Admin")
				display_colour = "#b4001e"	//red
			if("Trial Admin")
				display_colour = "#f03200"	//darker orange
			if("Admin Candidate")
				display_colour = "#ff5a1e"	//lighter orange
			if("Admin Observer")
				display_colour = "#1e4cd6"	//VERY slightly different light blue
			if("Mentor")
				display_colour = "#008000"	//green
			if("Maintainer")
				display_colour = "#0064ff"	//different light blue
			if("Debugger")
				display_colour = "#0064ff"	//different light blue
			if("Contributor")
				display_colour = "#1e4cd6"	//VERY slightly different light blue
			else
				display_colour = "#643200"	//brown, mostly /tg/ folks

		if(check_rights(R_COLOR))
			if(CONFIG_GET(flag/allow_admin_ooccolor))
				display_colour = prefs.ooccolor

	for(var/client/C in GLOB.clients)
		if(C.prefs.toggles_chat & CHAT_OOC)
			var/display_name = key
			if(holder?.fakekey)
				if(check_other_rights(C, R_ADMIN, FALSE))
					display_name = "[holder.fakekey]/([key])"
				else
					display_name = holder.fakekey
			to_chat(C, "<font color='[display_colour]'><span class='ooc'><span class='prefix'>OOC: [display_name]</span>: <span class='message'>[msg]</span></span></font>")


/client/verb/looc(msg as text)
	set name = "LOOC"
	set category = "OOC"

	var/admin = check_rights(R_ADMIN, FALSE)

	if(!mob)
		return

	if(mob.stat == DEAD && !admin)
		to_chat(src, "<span class='warning'>You must be alive to use LOOC.</span>")
		return

	if(IsGuestKey(key))
		to_chat(src, "Guests may not use LOOC.")
		return

	if(!admin)
		msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
	else
		msg = noscript(msg)

	if(!msg)
		return

	if(!(prefs.toggles_chat & CHAT_LOOC))
		to_chat(src, "<span class='warning'>You have LOOC muted.</span>")
		return

	if(!admin)
		if(!CONFIG_GET(flag/looc_enabled))
			to_chat(src, "<span class='warning'>LOOC is globally muted</span>")
			return
		if(prefs.muted & MUTE_LOOC)
			to_chat(src, "<span class='warning'>You cannot use LOOC (muted).</span>")
			return
		if(handle_spam_prevention(msg, MUTE_LOOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin_private("[key_name(usr)] has attempted to advertise in LOOC: [msg]")
			message_admins("[ADMIN_TPMONTY(usr)] has attempted to advertise in LOOC: [msg]")
			return

	if(is_banned_from(ckey, "LOOC"))
		to_chat(src, "<span class='warning'>You have been banned from LOOC.</span>")
		return

	mob.log_talk(msg, LOG_LOOC)

	var/message

	if(admin && isobserver(mob))
		message = "<font color='#6699CC'><span class='ooc'><span class='prefix'>LOOC:</span> [usr.client.holder.fakekey ? "Administrator" : usr.client.key]: <span class='message'>[msg]</span></span></font>"
		for(var/mob/M in range(mob))
			to_chat(M, message)
	else
		message = "<font color='#6699CC'><span class='ooc'><span class='prefix'>LOOC:</span> [mob.name]: <span class='message'>[msg]</span></span></font>"
		for(var/mob/M in range(mob))
			to_chat(M, message)

	for(var/client/C in GLOB.admins)
		if(!check_other_rights(C, R_ADMIN, FALSE) || C.mob == mob)
			continue
		if(C.prefs.toggles_chat & CHAT_LOOC)
			to_chat(C, "<font color='#6699CC'><span class='ooc'><span class='prefix'>LOOC: [ADMIN_TPMONTY(mob)]</span>: <span class='message'>[msg]</span></span></font>")


/client/verb/motd()
	set name = "MOTD"
	set category = "OOC"
	set desc ="Check the Message of the Day"

	if(GLOB.motd)
		to_chat(src, "<span class='motd'>[GLOB.motd]</span>")
	else
		to_chat(src, "<span class='warning'>The motd is not set in the server configuration.</span>")


/client/verb/stop_sounds()
	set name = "Stop Sounds"
	set category = "OOC"
	set desc = "Stop Current Sounds"

	SEND_SOUND(src, sound(null))
	if(chatOutput && !chatOutput.broken && chatOutput.loaded)
		chatOutput.stopMusic()


/client/verb/tracked_playtime()
	set category = "OOC"
	set name = "View Tracked Playtime"
	set desc = "View the amount of playtime for roles the server has tracked."

	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(usr, "<span class='notice'>Sorry, tracking is currently disabled.</span>")
		return

	var/list/body = list()
	body += get_exp_report()

	var/datum/browser/popup = new(src, "playerplaytime[ckey]", "<div align='center'>Playtime for [key]</div>", 550, 615)
	popup.set_content(body.Join())
	popup.open(FALSE)


/client/verb/view_admin_remarks()
	set category = "OOC"
	set name = "View Admin Remarks"

	if(!CONFIG_GET(flag/see_own_notes))
		to_chat(usr, "<span class='notice'>Sorry, that function is not enabled on this server.</span>")
		return

	browse_messages(null, ckey, null, TRUE)
	

/client/verb/fit_viewport()
	set name = "Fit Viewport"
	set category = "OOC"
	set desc = "Fit the width of the map window to match the viewport"

	// Fetch aspect ratio
	var/view_size = getviewsize(view)
	var/aspect_ratio = view_size[1] / view_size[2]

	// Calculate desired pixel width using window size and aspect ratio
	var/sizes = params2list(winget(src, "mainwindow.split;mapwindow", "size"))
	var/map_size = splittext(sizes["mapwindow.size"], "x")
	var/height = text2num(map_size[2])
	var/desired_width = round(height * aspect_ratio)
	if (text2num(map_size[1]) == desired_width)
		// Nothing to do
		return

	var/split_size = splittext(sizes["mainwindow.split.size"], "x")
	var/split_width = text2num(split_size[1])

	// Calculate and apply a best estimate
	// +4 pixels are for the width of the splitter's handle
	var/pct = 100 * (desired_width + 4) / split_width
	winset(src, "mainwindow.split", "splitter=[pct]")

	// Apply an ever-lowering offset until we finish or fail
	var/delta
	for(var/safety in 1 to 10)
		var/after_size = winget(src, "mapwindow", "size")
		map_size = splittext(after_size, "x")
		var/got_width = text2num(map_size[1])

		if (got_width == desired_width)
			// success
			return
		else if (isnull(delta))
			// calculate a probable delta value based on the difference
			delta = 100 * (desired_width - got_width) / split_width
		else if ((delta > 0 && got_width > desired_width) || (delta < 0 && got_width < desired_width))
			// if we overshot, halve the delta and reverse direction
			delta = -delta/2

		pct += delta
		winset(src, "mainwindow.split", "splitter=[pct]")


/client/verb/update_ping(time as num)
	set instant = TRUE
	set name = ".update_ping"
	var/ping = pingfromtime(time)
	lastping = ping
	if(!avgping)
		avgping = ping
	else
		avgping = MC_AVERAGE_SLOW(avgping, ping)


/client/proc/pingfromtime(time)
	return ((world.time + world.tick_lag * TICK_USAGE_REAL / 100) - time) * 100


/client/verb/display_ping(time as num)
	set instant = TRUE
	set name = ".display_ping"
	to_chat(src, "<span class='notice'>Round trip ping took [round(pingfromtime(time), 1)]ms</span>")


/client/verb/ping()
	set name = "Ping"
	set category = "OOC"
	winset(src, null, "command=.display_ping+[world.time + world.tick_lag * TICK_USAGE_REAL / 100]")