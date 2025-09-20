/client/verb/ooc_wrapper()
	set hidden = TRUE
	var/message = input("", "OOC \"text\"") as null|text
	ooc(message)


/client/verb/ooc(msg as text)
	set name = "OOC"
	set category = "OOC.Communication"

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

	for(var/client/recv_client AS in GLOB.clients)
		if(!(recv_client.prefs.toggles_chat & CHAT_OOC))
			continue
		if(holder?.fakekey in recv_client.prefs.ignoring)
			continue
		if(key in recv_client.prefs.ignoring)
			continue

		var/display_name = key
		if(holder?.fakekey)
			if(check_other_rights(recv_client, R_ADMIN|R_MENTOR, FALSE))
				display_name = "[holder.fakekey]/([key])"
			else
				display_name = holder.fakekey

		// Admins open straight to player panel
		if(check_other_rights(recv_client, R_ADMIN, FALSE))
			display_name = "<a class='hidelink' href='byond://?_src_=holder;[HrefToken(TRUE)];playerpanel=[REF(usr)]'>[display_name]</a>"
		var/avoid_highlight = recv_client == src
		if(display_colour)
			to_chat(recv_client, "<font color='[display_colour]'>[span_ooc("<span class='prefix'>OOC: [display_name]")]: <span class='message linkify'>[msg]</span></span></font>", avoid_highlighting = avoid_highlight)
		else
			to_chat(recv_client, "<span class='[display_class]'>[span_prefix("OOC: [display_name]")]: <span class='message linkify'>[msg]</span></span>", avoid_highlighting = avoid_highlight)


/client/verb/xooc_wrapper()
	set hidden = TRUE
	var/message = input("", "XOOC \"text\"") as null|text
	xooc(message)


/client/verb/xooc(msg as text) // Same as MOOC, but for xenos.
	set name = "XOOC"
	set category = "OOC.Communication"

	if(!msg)
		return

	var/admin = check_rights(R_ADMIN|R_MENTOR, FALSE)

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
	for(var/client/recv_client AS in GLOB.clients)
		if(!(recv_client.prefs.toggles_chat & CHAT_OOC))
			continue
		if(!(recv_client.mob in GLOB.xeno_mob_list) && !(recv_client.mob in GLOB.observer_list) || check_other_rights(recv_client, R_ADMIN|R_MENTOR, FALSE)) // If the client is a xeno, an observer, and not staff.
			continue

		var/display_name = mob.name
		var/display_key = (holder?.fakekey ? "Administrator" : mob.key)
		if(!(mob in GLOB.xeno_mob_list) && admin) // If the verb caller is an admin and not a xeno mob, use their fakekey or key instead.
			display_name = display_key

		var/avoid_highlight = recv_client == src
		to_chat(recv_client, "<font color='#a330a7'>[span_ooc("<span class='prefix'>XOOC: [display_name]")]: <span class='message linkify'>[msg]</span></span></font>", avoid_highlighting = avoid_highlight)

	// Send chat message to admins
	for(var/client/recv_staff AS in GLOB.admins)
		if(!check_other_rights(recv_staff, R_ADMIN|R_MENTOR, FALSE)) // Check if the client is still staff.
			continue
		if(!recv_staff.prefs.hear_ooc_anywhere_as_staff)
			continue
		if(!(recv_staff.prefs.toggles_chat & CHAT_OOC))
			continue

		var/display_name = "[ADMIN_TPMONTY(mob)]"
		if(holder?.fakekey) // Show their fakekey in addition to real key + buttons if they have one
			display_name = "[span_tooltip("Stealth key", "'[holder.fakekey]'")] ([display_name])"

		var/avoid_highlight = recv_staff == src
		to_chat(recv_staff, "<font color='#a330a7'>[span_ooc("<span class='prefix'>[span_tooltip("You are seeing this because you are staff and have hearing OOC channels from anywhere enabled.", "XOOC")]: [display_name]")]: <span class='message linkify'>[msg]</span></span></font>", avoid_highlighting = avoid_highlight)


/client/verb/mooc_wrapper()
	set hidden = TRUE
	var/message = input("", "MOOC \"text\"") as null|text
	mooc(message)


/client/verb/mooc(msg as text) // Same as XOOC, but for humans.
	set name = "MOOC"
	set category = "OOC.Communication"

	var/admin = check_rights(R_ADMIN|R_MENTOR, FALSE)

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
	for(var/client/recv_client AS in GLOB.clients)
		if(!(recv_client.prefs.toggles_chat & CHAT_OOC))
			continue
		if(!(recv_client.mob in GLOB.human_mob_list) && !(recv_client.mob in GLOB.observer_list) && !(recv_client.mob in GLOB.ai_list) || check_other_rights(recv_client, R_ADMIN|R_MENTOR, FALSE)) // If the client is a human, an observer, and not staff.
			continue

		// If the verb caller is an admin and not a human mob, use their key, or if they're stealthmode, hide their key instead.
		var/display_name = mob.name
		var/display_key = (holder?.fakekey ? "Administrator" : mob.key)
		if(!((mob in GLOB.human_mob_list) || (mob in GLOB.ai_list)) && admin)  // If the verb caller is an admin and not a human mob, use their fakekey or key instead.
			display_name = display_key

		var/avoid_highlight = recv_client == src
		to_chat(recv_client, "<font color='#ca6200'>[span_ooc("<span class='prefix'>MOOC: [display_name]")]: <span class='message linkify'>[msg]</span></span></font>", avoid_highlighting = avoid_highlight)

	// Send chat message to admins
	for(var/client/recv_staff AS in GLOB.admins)
		if(!check_other_rights(recv_staff, R_ADMIN|R_MENTOR, FALSE)) // Check if the client is still staff.
			continue
		if(!recv_staff.prefs.hear_ooc_anywhere_as_staff)
			continue
		if(!(recv_staff.prefs.toggles_chat & CHAT_OOC))
			continue

		var/display_name = "[ADMIN_TPMONTY(mob)]"
		if(holder?.fakekey) // Show their fakekey in addition to real key + buttons if they have one
			display_name = "[span_tooltip("Stealth key", "'[holder.fakekey]'")] ([display_name])"

		var/avoid_highlight = recv_staff == src
		to_chat(recv_staff, "<font color='#ca6200'>[span_ooc("<span class='prefix'>[span_tooltip("You are seeing this because you are staff and have hearing OOC channels from anywhere enabled.", "MOOC")]: [display_name]")]: <span class='message linkify'>[msg]</span></span></font>", avoid_highlighting = avoid_highlight)

/client/verb/looc_wrapper()
	set hidden = TRUE
	var/message = input("", "LOOC \"text\"") as null|text
	looc(message)

/client/verb/looc(msg as text)
	set name = "LOOC"
	set category = "OOC.Communication"

	if(!msg)
		return
	var/admin = check_rights(R_ADMIN|R_MENTOR, FALSE)

	if(!mob)
		return

	if(mob.stat == DEAD && !admin)
		to_chat(src, span_warning("You must be alive to use LOOC."))
		return

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

	if(admin && isobserver(mob)) // LOOC speaker is a ghost and an admin, make that obvious
		message = span_looc("[span_prefix("LOOC:")] [usr.client.holder.fakekey ? "Administrator" : usr.client.key]: [span_message("[msg]")]")
		for(var/mob/in_range_mob in range(mob))
			to_chat(in_range_mob, message)
	else
		message = span_looc("[span_prefix("LOOC:")] [mob.name]: [span_message("[msg]")]")
		for(var/mob/in_range_mob in range(mob))
			to_chat(in_range_mob, message)
			if(in_range_mob.client?.prefs?.chat_on_map)
				in_range_mob.create_chat_message(mob, raw_message = "(LOOC: [msg])", runechat_flags = OOC_MESSAGE)

	for(var/client/recv_staff AS in GLOB.admins)
		if(!check_other_rights(recv_staff, R_ADMIN|R_MENTOR, FALSE))
			continue
		if(!recv_staff.prefs.hear_ooc_anywhere_as_staff)
			continue
		if(recv_staff.mob == mob)
			continue

		var/display_name = "[ADMIN_TPMONTY(mob)]"
		if(holder?.fakekey) // Show their fakekey in addition to real key + buttons if they have one
			display_name = "[span_tooltip("Stealth key", "'[holder.fakekey]'")] ([display_name])"

		if(recv_staff.prefs.toggles_chat & CHAT_LOOC)
			to_chat(recv_staff, span_looc_heard_staff("<span class='prefix'>[span_tooltip("You are seeing this because you are staff and have hearing OOC channels from anywhere enabled.", "LOOC")]: [display_name]: [span_message("[msg]")]"))

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
	set category = "OOC.Fix"
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
	set category = "OOC.Fix"
	set desc = "Fit the width of the map window to match the viewport"

	// Fetch aspect ratio
	var/view_size = getviewsize(view)
	var/aspect_ratio = view_size[1] / view_size[2]

	// Calculate desired pixel width using window size and aspect ratio
	var/list/sizes = params2list(winget(src, "mainwindow.split;mapwindow", "size"))

	// Client closed the window? Some other error? This is unexpected behaviour, let's
	// CRASH with some info.
	if(!sizes["mapwindow.size"])
		CRASH("sizes does not contain mapwindow.size key. This means a winget failed to return what we wanted. --- sizes var: [sizes] --- sizes length: [length(sizes)]")

	var/list/map_size = splittext(sizes["mapwindow.size"], "x")

	// Gets the type of zoom we're currently using from our view datum
	// If it's 0 we do our pixel calculations based off the size of the mapwindow
	// If it's not, we already know how big we want our window to be, since zoom is the exact pixel ratio of the map
	var/zoom_value = src.view_size?.zoom || 0

	var/desired_width = 0
	if(zoom_value)
		desired_width = round(view_size[1] * zoom_value * ICON_SIZE_X)
	else

		// Looks like we expect mapwindow.size to be "ixj" where i and j are numbers.
		// If we don't get our expected 2 outputs, let's give some useful error info.
		if(length(map_size) != 2)
			CRASH("map_size of incorrect length --- map_size var: [map_size] --- map_size length: [length(map_size)]")
		var/height = text2num(map_size[2])
		desired_width = round(height * aspect_ratio)

	if (text2num(map_size[1]) == desired_width)
		// Nothing to do
		return

	var/split_size = splittext(sizes["mainwindow.split.size"], "x")
	var/split_width = text2num(split_size[1])

	// Avoid auto-resizing the statpanel and chat into nothing.
	desired_width = min(desired_width, split_width - 300)

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
	set category = "OOC.Fix"
	winset(src, null, "command=.display_ping+[world.time + world.tick_lag * TICK_USAGE_REAL / 100]")

/client/verb/fix_stat_panel()
	set name = "Fix Stat Panel"
	set hidden = TRUE

	init_verbs()

/client/verb/select_ignore()
	set name = "Ignore"
	set category = "OOC"
	set desc ="Ignore a player's messages on the OOC channel"

	var/list/players = list()

	// Use keys and fakekeys for the same purpose
	var/displayed_key = ""

	for(var/client/C in GLOB.clients)
		if(C == src)
			continue
		if((C.key in prefs.ignoring) && !C.holder?.fakekey)
			continue
		if(C.holder?.fakekey in prefs.ignoring)
			continue
		if(C.holder?.fakekey)
			displayed_key = C.holder.fakekey
		else
			displayed_key = C.key

		// Check if both we and the player are ghosts and they're not using a fakekey
		if(isobserver(mob) && isobserver(C.mob) && !C.holder?.fakekey)
			players["[displayed_key](ghost)"] = displayed_key
		else
			players[displayed_key] = displayed_key

	if(!length(players))
		to_chat(src, span_infoplain("There are no other players you can ignore!"))
		return

	players = sort_list(players)

	var/selection = tgui_input_list(src, "Select a player", "Ignore", players)

	if(isnull(selection) || !(selection in players))
		return

	selection = players[selection]

	if(selection in prefs.ignoring)
		to_chat(src, span_infoplain("You are already ignoring [selection]!"))
		return

	prefs.ignoring.Add(selection)
	prefs.save_preferences()

	to_chat(src, span_info("You are now ignoring [selection] on the OOC channel."))

/client/verb/select_unignore()
	set name = "Unignore"
	set category = "OOC"
	set desc = "Stop ignoring a player's messages on the OOC channel"

	if(!length(prefs.ignoring))
		to_chat(src, span_infoplain("You haven't ignored any players!"))
		return

	var/selection = tgui_input_list(src, "Select a player", "Unignore", prefs.ignoring)

	if(isnull(selection))
		return

	if(!(selection in prefs.ignoring))
		to_chat(src, span_infoplain("You are not ignoring [selection]!"))
		return

	prefs.ignoring.Remove(selection)
	prefs.save_preferences()

	to_chat(src, span_info("You are no longer ignoring [selection] on the OOC channel."))

/client/verb/linkforumaccount()
	set category = "OOC"
	set name = "Link Forum Account"
	set desc = "Validates your byond account to your forum account. Required to post on the forums."

	var/uri = CONFIG_GET(string/forum_link_uri)
	if(!uri)
		to_chat(src, span_warning("This feature is disabled."))
		return

	if (!SSdbcore.Connect())
		to_chat(src, span_danger("No connection to the database."))
		return

	if  (IsGuestKey(ckey))
		to_chat(src, span_danger("Guests can not link accounts."))
		return

	var/token = generate_account_link_token()

	var/datum/db_query/query_set_token = SSdbcore.NewQuery("INSERT INTO phpbb.tg_byond_oauth_tokens (`token`, `key`) VALUES (:token, :key)", list("token" = token, "key" = key))
	if(!query_set_token.Execute())
		to_chat(src, span_danger("Failed to insert account link token into database, please try again later."))
		qdel(query_set_token)
		return

	qdel(query_set_token)

	to_chat(src, "Now opening a window to login to your forum account, your account will automatically be linked the moment you log in. If this window doesn't load, Please go to <a href=\"[uri]?token=[token]\">[uri]?token=[token]</a> - This link will expire in 30 minutes.")
	src << link("[uri]?token=[token]")

/client/proc/generate_account_link_token()
	var/static/entropychain
	if (!entropychain)
		if (fexists("data/entropychain.txt"))
			entropychain = file2text("entropychain.txt")
		else
			entropychain = "LOL THERE IS NO ENTROPY #HEATDEATH"
	else if (prob(rand(1,15)))
		text2file("data/entropychain.txt", entropychain)

	var/datum/db_query/query_get_token = SSdbcore.NewQuery("SELECT [random_string()], [random_string()]", list(random_string_args(entropychain), random_string_args(entropychain)))

	if(!query_get_token.Execute())
		to_chat(src, span_danger("Failed to get random string token from database. (Error #1)"))
		qdel(query_get_token)
		return

	if(!query_get_token.NextRow())
		to_chat(src, span_danger("Could not locate your token in the database. (Error #2)"))
		qdel(query_get_token)
		return

	entropychain = "[query_get_token.item[2]]"
	return query_get_token.item[1]


/client/proc/random_string()
	return "SHA2(CONCAT(RAND(),UUID(),?,RAND(),UUID()), 512)"

/client/proc/random_string_args(entropychain)
	return "[entropychain][GUID()][rand()*rand(999999)][world.time][GUID()][rand()*rand(999999)][world.timeofday][GUID()][rand()*rand(999999)][world.realtime][GUID()][rand()*rand(999999)][time2text(world.timeofday)][GUID()][rand()*rand(999999)][world.tick_usage][computer_id][address][ckey][key][GUID()][rand()*rand(999999)]"
