/client/verb/xmooc_wrapper()
	set hidden = TRUE
	var/message = input("", "XMOOC \"text\"") as null|text
	xmooc(message)

/client/verb/xmooc(msg as text)
	set name = "XMOOC"
	set category = "OOC"

	if(!msg)
		return

	var/admin = check_rights(R_ADMIN, FALSE)

	if(!mob)
		return
	if(mob.stat == DEAD && !admin)
		to_chat(src, span_warning("You must be alive to use XMOOC."))
		return
	if(IsGuestKey(key))
		to_chat(src, "Guests may not use XMOOC.")
		return
	if(!((mob in GLOB.xeno_mob_list) || (mob in GLOB.ai_list) || (mob in GLOB.human_mob_list)) && !admin)
		to_chat(src, span_warning("You must be a xeno/living mob to use XMOOC."))
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
		log_filter("XMOOC", msg, filter_result)
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

	mob.log_talk(msg, LOG_XMOOC)

	// Send chat message to non-admins
	for(var/client/C AS in GLOB.clients)
		if(!(C.prefs.toggles_chat & CHAT_OOC))
			continue
		if(!((C.mob in GLOB.xeno_mob_list) || (C.mob in GLOB.observer_list) || (C.mob in GLOB.ai_list) || (C.mob in GLOB.human_mob_list)) || check_other_rights(C, R_ADMIN, FALSE))
			continue

		var/display_name = mob.name
		var/display_key = (holder?.fakekey ? "Administrator" : mob.key)
		if(!((mob in GLOB.xeno_mob_list) || (mob in GLOB.ai_list) || (mob in GLOB.human_mob_list)) && admin)
			display_name = display_key

		var/avoid_highlight = C == src
		to_chat(C, "<font color='#6D2A6D'>[span_ooc("<span class='prefix'>XMOOC: [display_name]")]: <span class='message linkify'>[msg]</span></span></font>", avoid_highlighting = avoid_highlight)

	// Send chat message to admins
	for(var/client/C AS in GLOB.admins)
		if(!(C.prefs.toggles_chat & CHAT_OOC))
			continue
		if(!check_other_rights(C, R_ADMIN, FALSE)) // Check if the client is still an admin.
			continue

		var/display_name = mob.name
		var/display_key = (holder?.fakekey ? "Administrator" : mob.key)
		if(!((mob in GLOB.xeno_mob_list) || (mob in GLOB.ai_list) || (mob in GLOB.human_mob_list)) && admin)
			display_name = display_key
		display_name = "<a class='hidelink' href='?_src_=holder;[HrefToken(TRUE)];playerpanel=[REF(usr)]'>[display_name]</a>" // Admins get a clickable player panel.
		if(!holder?.fakekey) // Show their key and their fakekey if they have one.
			display_name = "[mob.key]/([display_name])"
		else
			display_name = "[holder.fakekey]/([mob.key]/[display_name])"

		var/avoid_highlight = C == src
		to_chat(C, "<font color='#6D2A6D'>[span_ooc("<span class='prefix'>XMOOC: [display_name]")]: <span class='message linkify'>[msg]</span></span></font>", avoid_highlighting = avoid_highlight)
