/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if(!msg)
		return

	if(usr.client.prefs.muted & MUTE_PRAY)
		to_chat(usr, "<span class='warning'>You cannot pray (muted).</span>")
		return

	if(client.handle_spam_prevention(msg, MUTE_PRAY))
		return

	var/mentor_msg = msg
	var/liaison = FALSE

	if(mind?.assigned_role && mind.assigned_role == "Corporate Liaison")
		liaison = TRUE

	msg = "<b><font color=purple>[liaison ? "LIAISON " : ""]PRAY:</font> <span class='notice'>[ADMIN_FULLMONTY(usr)] [ADMIN_SC(usr)] [ADMIN_SFC(usr)]: [msg]</b></span>"
	mentor_msg = "<b><font color=purple>[liaison ? "LIAISON " : ""]PRAY:</font> <span class='notice'>[ADMIN_TPMONTY(usr)]:</b> [mentor_msg]</span>"


	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ADMIN, FALSE) && (C.prefs.toggles_chat & CHAT_PRAYER))
			to_chat(C, msg)
		else if(C.mob.stat == DEAD && (C.prefs.toggles_chat & CHAT_PRAYER))
			to_chat(C, mentor_msg)

	if(liaison)
		to_chat(usr, "Your corporate overlords at Nanotrasen have received your message.")
	else
		to_chat(usr, "Your prayers have been received by the gods.")


/proc/tgmc_message(text, mob/sender)
	text = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ADMIN, FALSE))
			to_chat(C, "<span class='notice'><b><font color='purple'>TGMC:</font>[ADMIN_FULLMONTY(usr)] (<a HREF='?src=[REF(C.holder)];[HrefToken(TRUE)];reply=[REF(sender)]'>REPLY</a>): [text]</b></span>")
			SEND_SOUND(C, 'sound/effects/sos-morse-code.ogg')