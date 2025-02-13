/mob/dead/observer/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message)
		return

	var/list/filter_result = CAN_BYPASS_FILTER(src) ? null : is_ooc_filtered(message)
	if (filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		log_filter("OOC", message, filter_result)
		return

	var/list/soft_filter_result = CAN_BYPASS_FILTER(src) ? null : is_soft_ooc_filtered(message)
	if (soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[message]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[message]\"")

	if(check_emote(message))
		return

	. = say_dead(message)


/mob/dead/observer/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()

	if(client?.prefs.chat_on_map && (client.prefs.see_chat_non_mob || ismob(speaker)))
		create_chat_message(speaker, message_language, raw_message, spans, message_mode)

	var/atom/movable/to_follow = speaker
	if(radio_freq)
		var/atom/movable/virtualspeaker/V = speaker
		if(isAI(V.source))
			var/mob/living/silicon/ai/S = V.source
			to_follow = S.eyeobj
		else
			to_follow = V.source

	else if(client && in_view_range(src, to_follow))
		raw_message = "<b>[raw_message]</b>"
	// Recompose the message, because it's scrambled by default
	var/link = FOLLOW_LINK(src, to_follow)
	message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mode)
	to_chat(src, "[link] [message]")


/mob/dead/observer/compose_name_href(name)
	if(!check_other_rights(client, R_ADMIN, FALSE))
		return name
	return "<a class='hidelink' href='byond://?_src_=holder;[HrefToken(TRUE)];playerpanel=[REF(usr)]'>[name]</a>"
