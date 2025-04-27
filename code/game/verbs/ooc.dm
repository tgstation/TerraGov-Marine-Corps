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
	if(NON_ASCII_CHECK(msg))
		return

	msg = emoji_parse(msg)

	if(!(prefs.toggles_chat & CHAT_OOC))
		to_chat(src, span_warning("You have OOC muted."))
		return

	if(!check_rights(R_ADMIN, FALSE))
		if(!GLOB.ooc_allowed)
			to_chat(src, span_warning("OOC is globally muted"))
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, span_warning("OOC for dead mobs has been turned off."))
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, span_warning("You cannot use OOC (muted)."))
			return
		if(handle_spam_prevention(msg, MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, span_danger("Advertising other servers is not allowed."))
			log_admin_private("[key_name(usr)] has attempted to advertise in OOC: [msg]")
			message_admins("[ADMIN_TPMONTY(usr)] has attempted to advertise in OOC: [msg]")
			return

	if(is_banned_from(ckey, "OOC"))
		to_chat(src, span_warning("You have been banned from OOC."))
		return

	var/list/filter_result = is_ooc_filtered(msg)
	if(!CAN_BYPASS_FILTER(usr) && filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		log_filter("OOC", msg, filter_result)
		return

	// Protect filter bypassers from themselves.
	// Demote hard filter results to soft filter results if necessary due to the danger of accidentally speaking in OOC.
	var/list/soft_filter_result = filter_result || is_soft_ooc_filtered(msg)

	if(soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[msg]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[msg]\"")

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
			if("Senior Admin")
				display_class = "senioradminooc"
			if("Admin")
				display_class = "adminooc"
			if("Trial Admin")
				display_class = "trialminooc"
			if("Admin Candidate", "Admin Observer")
				display_class = "candiminooc"
			if("Event Admin", "Event Staff")
				display_class = "eventminooc"
			if("Mentor")
				display_class = "mentorooc"
			if("Maintainer")
				display_class = "maintainerooc"
			if("Art Maintainer")
				display_class = "maintainerooc"
			if("Debugger", "Contributor")
				display_class = "contributorooc"
			else
				display_class = "otherooc"


		if(CONFIG_GET(flag/allow_admin_ooccolor) && check_rights(R_COLOR, FALSE))
			display_colour = prefs.ooccolor

	for(var/client/C AS in GLOB.clients)
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
		var/avoid_highlight = C == src
		if(display_colour)
			to_chat(C, "<font color='[display_colour]'>[span_ooc("<span class='prefix'>OOC: [display_name]")]: <span class='message linkify'>[msg]</span></span></font>", avoid_highlighting = avoid_highlight)
		else
			to_chat(C, "<span class='[display_class]'>[span_prefix("OOC: [display_name]")]: <span class='message linkify'>[msg]</span></span>", avoid_highlighting = avoid_highlight)


/client/verb/xooc_wrapper()
	set hidden = TRUE
	var/message = input("", "XOOC \"text\"") as null|text
	xooc(message)


/client/verb/xooc(msg as text) // Same as MOOC, but for xenos.
	set name = "XOOC"
	set category = "OOC"

	if(!msg)
		return

	var/admin = check_rights(R_ADMIN, FALSE)

	if(!mob)
		return
	if(IsGuestKey(key))
		to_chat(src, "Guests may not use XOOC.")
		return
	if(mob.stat == DEAD && !admin)
		to_chat(src, span_warning("You must be alive to use XOOC."))
		return
	if(!(mob in GLOB.xeno_mob_list) && !admin)
		to_chat(src, span_warning("You must be a xeno to use XOOC."))
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if(!msg)
		return
	if(NON_ASCII_CHECK(msg))
		return

	msg = emoji_parse(msg)

	if(!(prefs.toggles_chat & CHAT_OOC))
		to_chat(src, span_warning("You have OOC muted."))
		return

	if(!check_rights(R_ADMIN, FALSE))
		if(!GLOB.ooc_allowed)
			to_chat(src, span_warning("OOC is globally muted"))
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, span_warning("You cannot use OOC (muted)."))
			return
		if(handle_spam_prevention(msg, MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, span_danger("Advertising other servers is not allowed."))
			log_admin_private("[key_name(usr)] has attempted to advertise in OOC: [msg]")
			message_admins("[ADMIN_TPMONTY(usr)] has attempted to advertise in OOC: [msg]")
			return

	var/list/filter_result = is_ooc_filtered(msg)
	if(!CAN_BYPASS_FILTER(usr) && filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		log_filter("XOOC", msg, filter_result)
		return

	// Protect filter bypassers from themselves.
	// Demote hard filter results to soft filter results if necessary due to the danger of accidentally speaking in OOC.
	var/list/soft_filter_result = filter_result || is_soft_ooc_filtered(msg)

	if(soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[msg]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[msg]\"")

	if(is_banned_from(ckey, "OOC"))
		to_chat(src, span_warning("You have been banned from OOC."))
		return

	mob.log_talk(msg, LOG_XOOC)

	// Send chat message to non-admins
	for(var/client/C AS in GLOB.clients)
		if(!(C.prefs.toggles_chat & CHAT_OOC))
			continue
		if(!(C.mob in GLOB.xeno_mob_list) && !(C.mob in GLOB.observer_list) || check_other_rights(C, R_ADMIN, FALSE)) // If the client is a xeno, an observer, and not an admin.
			continue

		var/display_name = mob.name
		var/display_key = (holder?.fakekey ? "Administrator" : mob.key)
		if(!(mob in GLOB.xeno_mob_list) && admin) // If the verb caller is an admin and not a xeno mob, use their fakekey or key instead.
			display_name = display_key

		var/avoid_highlight = C == src
		to_chat(C, "<font color='#6D2A6D'>[span_ooc("<span class='prefix'>XOOC: [display_name]")]: <span class='message linkify'>[msg]</span></span></font>", avoid_highlighting = avoid_highlight)

	// Send chat message to admins
	for(var/client/C AS in GLOB.admins)
		if(!(C.prefs.toggles_chat & CHAT_OOC))
			continue
		if(!check_other_rights(C, R_ADMIN, FALSE)) // Check if the client is still an admin.
			continue

		var/display_name = mob.name
		var/display_key = (holder?.fakekey ? "Administrator" : mob.key)
		if(!(mob in GLOB.xeno_mob_list) && admin) // If the verb caller is an admin and not a xeno mob, use their fakekey or key instead.
			display_name = display_key
		display_name = "<a class='hidelink' href='?_src_=holder;[HrefToken(TRUE)];playerpanel=[REF(usr)]'>[display_name]</a>" // Admins get a clickable player panel.
		if(!holder?.fakekey) // Show their key and their fakekey if they have one.
			display_name = "[mob.key]/([display_name])"
		else
			display_name = "[holder.fakekey]/([mob.key]/[display_name])"

		var/avoid_highlight = C == src
		to_chat(C, "<font color='#6D2A6D'>[span_ooc("<span class='prefix'>XOOC: [display_name]")]: <span class='message linkify'>[msg]</span></span></font>", avoid_highlighting = avoid_highlight)


/client/verb/mooc_wrapper()
	set hidden = TRUE
	var/message = input("", "MOOC \"text\"") as null|text
	mooc(message)


/client/verb/mooc(msg as text) // Same as XOOC, but for humans.
	set name = "MOOC"
	set category = "OOC"

	var/admin = check_rights(R_ADMIN, FALSE)

	if(!mob)
		return
	if(IsGuestKey(key))
		to_chat(src, "Guests may not use MOOC.")
		return
	if(mob.stat == DEAD && !admin)
		to_chat(src, span_warning("You must be alive to use MOOC."))
		return
	if(!((mob in GLOB.human_mob_list) || (mob in GLOB.ai_list)) && !admin)
		to_chat(src, span_warning("You must be a human to use MOOC."))
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if(!msg)
		return
	if(NON_ASCII_CHECK(msg))
		return

	msg = emoji_parse(msg)

	if(!(prefs.toggles_chat & CHAT_OOC))
		to_chat(src, span_warning("You have OOC muted."))
		return

	if(!check_rights(R_ADMIN, FALSE))
		if(!GLOB.ooc_allowed)
			to_chat(src, span_warning("OOC is globally muted"))
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, span_warning("You cannot use OOC (muted)."))
			return
		if(handle_spam_prevention(msg, MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, span_danger("Advertising other servers is not allowed."))
			log_admin_private("[key_name(usr)] has attempted to advertise in OOC: [msg]")
			message_admins("[ADMIN_TPMONTY(usr)] has attempted to advertise in OOC: [msg]")
			return

	if(is_banned_from(ckey, "OOC"))
		to_chat(src, span_warning("You have been banned from OOC."))
		return

	var/list/filter_result = is_ooc_filtered(msg)
	if(!CAN_BYPASS_FILTER(usr) && filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		log_filter("MOOC", msg, filter_result)
		return

	// Protect filter bypassers from themselves.
	// Demote hard filter results to soft filter results if necessary due to the danger of accidentally speaking in OOC.
	var/list/soft_filter_result = filter_result || is_soft_ooc_filtered(msg)

	if(soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[msg]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[msg]\"")

	mob.log_talk(msg, LOG_MOOC)

	// Send chat message to non-admins
	for(var/client/C AS in GLOB.clients)
		if(!(C.prefs.toggles_chat & CHAT_OOC))
			continue
		if(!(C.mob in GLOB.human_mob_list) && !(C.mob in GLOB.observer_list) && !(C.mob in GLOB.ai_list) || check_other_rights(C, R_ADMIN, FALSE)) // If the client is a human, an observer, and not an admin.
			continue

		// If the verb caller is an admin and not a human mob, use their key, or if they're stealthmode, hide their key instead.
		var/display_name = mob.name
		var/display_key = (holder?.fakekey ? "Administrator" : mob.key)
		if(!((mob in GLOB.human_mob_list) || (mob in GLOB.ai_list)) && admin)  // If the verb caller is an admin and not a human mob, use their fakekey or key instead.
			display_name = display_key

		var/avoid_highlight = C == src
		to_chat(C, "<font color='#B75800'>[span_ooc("<span class='prefix'>MOOC: [display_name]")]: <span class='message linkify'>[msg]</span></span></font>", avoid_highlighting = avoid_highlight)

	// Send chat message to admins
	for(var/client/C AS in GLOB.admins)
		if(!(C.prefs.toggles_chat & CHAT_OOC))
			continue
		if(!check_other_rights(C, R_ADMIN, FALSE)) // Check if the client is still an admin.
			continue

		var/display_name = mob.name
		var/display_key = (holder?.fakekey ? "Administrator" : mob.key)
		if(!((mob in GLOB.human_mob_list) || (mob in GLOB.ai_list)) && admin) // If the verb caller is an admin and not a human mob, use their fakekey or key instead.
			display_name = display_key
		display_name = "<a class='hidelink' href='?_src_=holder;[HrefToken(TRUE)];playerpanel=[REF(usr)]'>[display_name]</a>" // Admins get a clickable player panel.
		if(!holder?.fakekey) // Show their key and their fakekey if they have one.
			display_name = "[mob.key]/([display_name])"
		else
			display_name = "[holder.fakekey]/([mob.key]/[display_name])"

		var/avoid_highlight = C == src
		to_chat(C, "<font color='#B75800'>[span_ooc("<span class='prefix'>MOOC: [display_name]")]: <span class='message linkify'>[msg]</span></span></font>", avoid_highlighting = avoid_highlight)


/client/verb/looc_wrapper()
	set hidden = TRUE
	var/message = input("", "LOOC \"text\"") as null|text
	looc(message)


/client/verb/looc(msg as text)
	set name = "LOOC"
	set category = "OOC"

	if(!msg)
		return
	var/admin = check_rights(R_ADMIN, FALSE)

	if(!mob)
		return

/*
	if(mob.stat == DEAD && !admin)
		to_chat(src, span_warning("You must be alive to use LOOC."))
		return
*/

	if(IsGuestKey(key))
		to_chat(src, "Guests may not use LOOC.")
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if(!msg)
		return

	if(!(prefs.toggles_chat & CHAT_LOOC))
		to_chat(src, span_warning("You have LOOC muted."))
		return

	if(!admin)
		if(!CONFIG_GET(flag/looc_enabled))
			to_chat(src, span_warning("LOOC is globally muted"))
			return
		if(prefs.muted & MUTE_LOOC)
			to_chat(src, span_warning("You cannot use LOOC (muted)."))
			return
		if(handle_spam_prevention(msg, MUTE_LOOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin_private("[key_name(usr)] has attempted to advertise in LOOC: [msg]")
			message_admins("[ADMIN_TPMONTY(usr)] has attempted to advertise in LOOC: [msg]")
			return

	var/list/filter_result = is_ooc_filtered(msg)
	if(!CAN_BYPASS_FILTER(usr) && filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		log_filter("LOOC", msg, filter_result)
		return

	// Protect filter bypassers from themselves.
	// Demote hard filter results to soft filter results if necessary due to the danger of accidentally speaking in OOC.
	var/list/soft_filter_result = filter_result || is_soft_ooc_filtered(msg)

	if(soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[msg]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[msg]\"")

	if(is_banned_from(ckey, "LOOC"))
		to_chat(src, span_warning("You have been banned from LOOC."))
		return

	mob.log_talk(msg, LOG_LOOC)

	var/message

	if(admin && isobserver(mob))
		message = span_looc("[span_prefix("LOOC:")] [usr.client.holder.fakekey ? "Administrator" : usr.client.key]: [span_message("[msg]")]")
		for(var/mob/M in range(mob))
			to_chat(M, message)
	else
		message = span_looc("[span_prefix("LOOC:")] [mob.name]: [span_message("[msg]")]")
		var/turf/mobturf = get_turf(mob)
		for(var/mob/M in GLOB.player_list)
			var/turf/Mturf = get_turf(M)
			if(mobturf.z == Mturf.z && get_dist(Mturf,mobturf) <= world.view)
				to_chat(M, message)

	for(var/client/C AS in GLOB.admins)
		if(!check_other_rights(C, R_ADMIN, FALSE) || C.mob == mob)
			continue
		if(C.prefs.toggles_chat & CHAT_LOOC)
			to_chat(C, "<font color='#6699CC'>[span_ooc("<span class='prefix'>LOOC: [ADMIN_TPMONTY(mob)]")]: [span_message("[msg]")]</span></font>")


/client/verb/motd()
	set name = "MOTD"
	set category = "OOC"
	set desc ="Check the Message of the Day"

	if(GLOB.motd)
		to_chat(src, span_motd("[GLOB.motd]"))
	else
		to_chat(src, span_warning("The motd is not set in the server configuration."))


/client/verb/stop_sounds()
	set name = "Stop Sounds"
	set category = "OOC"
	set desc = "Stop Current Sounds"

	SEND_SOUND(src, sound(null))
	tgui_panel?.stop_music()


/client/verb/tracked_playtime()
	set category = "OOC"
	set name = "View Tracked Playtime"
	set desc = "View the amount of playtime for roles the server has tracked."

	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(usr, span_notice("Sorry, tracking is currently disabled."))
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
		to_chat(usr, span_notice("Sorry, that function is not enabled on this server."))
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

/// Attempt to automatically fit the viewport, assuming the user wants it
/client/proc/attempt_auto_fit_viewport()
	if (!prefs.auto_fit_viewport)
		return
	if(fully_created)
		INVOKE_ASYNC(src, VERB_REF(fit_viewport))
	else //Delayed to avoid wingets from Login calls.
		addtimer(CALLBACK(src, VERB_REF(fit_viewport)), 1 SECONDS)

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
	to_chat(src, span_notice("Round trip ping took [round(pingfromtime(time), 1)]ms"))


/client/verb/ping()
	set name = "Ping"
	set category = "OOC"
	winset(src, null, "command=.display_ping+[world.time + world.tick_lag * TICK_USAGE_REAL / 100]")

/client/verb/fix_stat_panel()
	set name = "Fix Stat Panel"
	set hidden = TRUE

	init_verbs()
