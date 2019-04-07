var/global/normal_ooc_colour = "#002eb8"

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
			log_admin("[key_name(usr)] has attempted to advertise in OOC: [msg]")
			message_admins("[ADMIN_TPMONTY(usr)] has attempted to advertise in OOC: [msg]")
			return

	if(is_banned_from(ckey, "OOC"))
		to_chat(src, "<span class='warning'>You have been banned from OOC.</span>")
		return

	mob.log_talk(msg, LOG_OOC)

	var/display_colour = normal_ooc_colour
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
			log_admin("[key_name(usr)] has attempted to advertise in LOOC: [msg]")
			message_admins("[ADMIN_TPMONTY(usr)] has attempted to advertise in LOOC: [msg]")
			return

	if(is_banned_from(ckey, "LOOC"))
		to_chat(src, "<span class='warning'>You have been banned from LOOC.</span>")
		return

	mob.log_talk("LOOC: [msg]", LOG_LOOC)

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


/client/verb/setup_character()
	set name = "Game Preferences"
	set category = "OOC"
	set desc = "Allows you to access the Setup Character screen. Changes to your character won't take effect until next round, but other changes will."
	prefs.ShowChoices(usr)


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