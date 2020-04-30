/client/verb/ooc_wrapper()
	set hidden = TRUE
	var/message = input("", "OOC \"text\"") as null|text
	ooc(message)


/client/verb/ooc(msg as text)
	set name = "OOC"
	set category = "OOC"

	if(!mob)
		return
	if(IsGuestKey(key))
		to_chat(src, "Guests may not use OOC.")
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if(!msg)
		return

	msg = emoji_parse(msg)
	
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

	var/display_colour
	var/display_class = "colorooc"
	if(holder?.rank && !holder.fakekey)
		switch(holder.rank.name)
			if("Host")
				display_class = "hostooc"
			if("Project Lead")
				display_class = "projleadooc"
			if("Headcoder")
				display_class = "headcoderooc"
			if("Headmin")
				display_class = "headminooc"
			if("Headmentor")
				display_class = "headmentorooc"
			if("Admin")
				display_class = "adminooc"
			if("Trial Admin")
				display_class = "trialminooc"
			if("Admin Candidate", "Admin Observer")
				display_class = "candiminooc"
			if("Mentor")
				display_class = "mentorooc"
			if("Maintainer")
				display_class = "maintainerooc"
			if("Debugger", "Contributor")
				display_class = "contributorooc"
			else
				display_class = "otherooc"

		if(check_rights(R_COLOR))
			if(CONFIG_GET(flag/allow_admin_ooccolor))
				display_colour = prefs.ooccolor

	for(var/client/C in GLOB.clients)
		if(!(C.prefs.toggles_chat & CHAT_OOC))
			continue

		var/display_name = key
		if(holder?.fakekey)
			if(check_other_rights(C, R_ADMIN, FALSE))
				display_name = "[holder.fakekey]/([key])"
			else
				display_name = holder.fakekey

		// Admins open straight to player panel
		if(check_other_rights(C, R_ADMIN, FALSE))
			display_name = "<a class='hidelink' href='?_src_=holder;[HrefToken(TRUE)];playerpanel=[REF(usr)]'>[display_name]</a>"

		if(display_colour)
			to_chat(C, "<font color='[display_colour]'><span class='ooc'><span class='prefix'>OOC: [display_name]</span>: <span class='message linkify'>[msg]</span></span></font>")
		else
			to_chat(C, "<span class='[display_class]'><span class='prefix'>OOC: [display_name]</span>: <span class='message linkify'>[msg]</span></span>")


/client/verb/looc_wrapper()
	set hidden = TRUE
	var/message = input("", "LOOC \"text\"") as null|text
	looc(message)


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

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)

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
		message = "<span class='looc'><span class='prefix'>LOOC:</span> [usr.client.holder.fakekey ? "Administrator" : usr.client.key]: <span class='message'>[msg]</span></span>"
		for(var/mob/M in range(mob))
			to_chat(M, message)
	else
		message = "<span class='looc'><span class='prefix'>LOOC:</span> [mob.name]: <span class='message'>[msg]</span></span>"
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
	if(chatOutput?.working && chatOutput.loaded)
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


/client/verb/policy()
	set name = "Show Policy"
	set desc = "Show special server rules related to your current character."
	set category = "OOC"

	//Collect keywords
	var/list/keywords = mob.get_policy_keywords()
	var/header = get_policy(POLICY_VERB_HEADER)
	var/list/policytext = list(header,"<hr>")
	var/anything = FALSE
	for(var/keyword in keywords)
		var/p = get_policy(keyword)
		if(p)
			policytext += p
			policytext += "<hr>"
			anything = TRUE
	if(!anything)
		policytext += "No related rules found."

	var/datum/browser/popup = new(usr, "policy")
	popup.set_content(policytext.Join(""))
	popup.open(FALSE)


/client/verb/fix_chat()
	set name = "Fix chat"
	set category = "OOC"

	var/action = alert(src, "Select desired action", "Options", "Troubleshoot Goonchat", "Revert to old chat", "Cancel")
	switch(action)
		if("Revert to old chat")
			winset(src, "output", "is-visible=true;is-disabled=false")
			winset(src, "browseroutput", "is-visible=false")
			return
		if("Cancel")
			return

	if(!istype(chatOutput))
		action = alert(src, "Invalid Chat Output data found!\nRecreate data?", "Recreate Chat Output data", "Yes", "Cancel")
		if(action != "Yes")
			return
		chatOutput = new /datum/chatOutput(src)
		chatOutput.start()
		action = alert(src, "Goon chat reloading, wait a bit and state if it's fixed", "Fixed", "Yes", "No")
		if(action == "Yes")
			log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by re-creating the chatOutput datum")
			return
		chatOutput.load()
		action = alert(src, "How about now? (give it a moment (it may also try to load twice))", "Loaded", "Yes", "No")
		if(action == "Yes")
			log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by re-creating the chatOutput datum and forcing a load()")
			return
		action = alert(src, "Reloading failed. Try closing the game, clearing the Internet Explorer and BYOND caches, and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "Close or Switch", "Close", "Switch to old chat")
		if(action == "Switch to old chat")
			winset(src, "output", "is-visible=true ; is-disabled=false")
			winset(src, "browseroutput", "is-visible=false")
		log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window after recreating the chatOutput and forcing a load()")
		return

	if(chatOutput.loaded)
		action = alert(src, "ChatOutput seems to be loaded\nForce a reload, wiping the chat log, or just refresh the chat window because it broke/went away?", "Reload or Refresh", "Force Reload", "Refresh", "Cancel")
		switch(action)
			if("Force Reload")
				chatOutput.loaded = FALSE
				chatOutput.start() //this is likely to fail since it asks , but we should try it anyways so we know.
				action = alert(src, "Goon chat reloading, wait a bit and state if it's fixed", "Fixed", "Yes", "No")
				if(action == "Yes")
					log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a start()")
					return
				chatOutput.load()
				action = alert(src, "How about now? (give it a moment (it may also try to load twice))", "Loaded", "Yes", "No")
				if(action == "Yes")
					log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a load()")
					return
				action = alert(src, "Reloading failed. Try closing the game, clearing the Internet Explorer and BYOND caches, and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "Close or Switch", "Close", "Switch to old chat")
				if(action == "Switch to old chat")
					winset(src, "output", "is-visible=true ; is-disabled=false")
					winset(src, "browseroutput", "is-visible=false")
				log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window forcing a start() and forcing a load()")
				return

			if("Refresh")
				chatOutput.showChat()
				action = alert(src, "Goon chat refreshing, wait a bit and state if it's fixed", "Fixed", "Yes", "No, force a reload")
				if(action == "Yes")
					log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a show()")
					return
				chatOutput.loaded = FALSE
				chatOutput.load()
				action = alert(src, "How about now? (give it a moment)", "Loaded", "Yes", "No")
				if(action == "Yes")
					log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a load()")
					return
				action = alert(src, "Reloading failed. Try closing the game, clearing the Internet Explorer and BYOND caches, and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "Close or Switch", "Close", "Switch to old chat")
				if(action == "Switch to old chat")
					winset(src, "output", "is-visible=true;is-disabled=false")
					winset(src, "browseroutput", "is-visible=false")
				log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window forcing a show() and forcing a load()")
		return

	chatOutput.start()
	action = alert(src, "Manually loading Chat, wait a bit and state if it's fixed", "Fixed", "Yes", "No")
	if(action == "Yes")
		log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by manually calling start()")
		return
	chatOutput.load()
	action = alert(src, "How about now? (give it a moment)", "Loaded", "Yes", "No")
	if(action == "Yes")
		log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by manually calling start() and forcing a load()")
		return
	action = alert(src, "Reloading failed. Try closing the game, clearing the Internet Explorer and BYOND caches, and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "Close or Switch", "Close", "Switch to old chat")
	if(action == "Switch to old chat")
		winset(src, "output", list2params(list("on-show" = "", "is-disabled" = "false", "is-visible" = "true")))
		winset(src, "browseroutput", "is-disabled=true;is-visible=false")
	log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window after manually calling start() and forcing a load()")


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
