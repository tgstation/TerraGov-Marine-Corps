/client/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if(!msg)
		return
	mob.log_talk(msg, LOG_PRAYER)

	if(usr.client.prefs.muted & MUTE_PRAY)
		to_chat(usr, span_warning("You cannot pray (muted)."))
		return

	if(handle_spam_prevention(msg, MUTE_PRAY))
		return

	var/mentor_msg = msg
	var/liaison = FALSE

	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		liaison = iscorporateliaisonjob(H.job)

	msg = "<b><font color=purple>[liaison ? "LIAISON " : ""]PRAY:</font> <span class='notice linkify'>[ADMIN_FULLMONTY(usr)] [ADMIN_SC(usr)] [ADMIN_SFC(usr)]: [msg]</b></span>"
	mentor_msg = "<b><font color=purple>[liaison ? "LIAISON " : ""]PRAY:</font> <span class='notice linkify'>[ADMIN_TPMONTY(usr)]:</b> [mentor_msg]</span>"


	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ADMIN, FALSE) && (C.prefs.toggles_chat & CHAT_PRAYER))
			to_chat(C,
				type = MESSAGE_TYPE_PRAYER,
				html = msg)
		else if(C.mob.stat == DEAD && (C.prefs.toggles_chat & CHAT_PRAYER))
			to_chat(C,
				type = MESSAGE_TYPE_PRAYER,
				html = mentor_msg)

	if(liaison)
		to_chat(usr, "Your corporate overlords at Nanotrasen have received your message.")
	else
		to_chat(usr, "Your prayers have been received by the gods.")


/proc/tgmc_message(text, mob/sender)
	text = copytext_char(sanitize(text), 1, MAX_MESSAGE_LEN)
	var/sound/S = sound('sound/effects/sos-morse-code.ogg', channel = CHANNEL_ADMIN)
	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ADMIN, FALSE))
			to_chat(C, span_notice("<b><font color='purple'>TGMC:</font>[ADMIN_FULLMONTY(usr)] (<a HREF='?src=[REF(C.holder)];[HrefToken(TRUE)];reply=[REF(sender)]'>REPLY</a>): [text]</b>"))
			SEND_SOUND(C, S)
